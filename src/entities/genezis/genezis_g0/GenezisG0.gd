extends CharacterBody3D

enum State { IDLE, SEARCHING, MOVING_TO_TARGET, UNBLOCKING }

@export var move_speed: float = 8.0
@export var unblock_radius: float = 1.0

var current_state: State = State.IDLE
var target_g1: CharacterBody3D = null
var _scan_timer: float = 0.0
var _scan_interval: float = 1.0

@onready var visuals: Node3D = $Visuals
@onready var antenna: Node3D = $Visuals/Antenna

func _ready() -> void:
	add_to_group("genezis_g0")

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.SEARCHING:
			_process_searching(delta)
		State.MOVING_TO_TARGET:
			_process_moving(delta)
		State.UNBLOCKING:
			_process_unblocking(delta)

func _process_idle(delta: float) -> void:
	_scan_timer += delta
	if _scan_timer >= _scan_interval:
		_scan_timer = 0.0
		current_state = State.SEARCHING

func _process_searching(_delta: float) -> void:
	var stuck_g1s = []
	var g1s = get_tree().get_nodes_in_group("genezis_g1")
	
	for g1 in g1s:
		if is_instance_valid(g1):
			var state = g1.get("current_state")
			var inactivity = g1.get("inactivity_timer")
			# Check if idle (0) or if inactivity timer is too high (e.g. > 15 seconds)
			if state == 0 or (inactivity != null and inactivity > 15.0):
				stuck_g1s.append(g1)
	
	if stuck_g1s.size() > 0:
		# Pick the closest stuck/idle G1
		var closest = null
		var min_dist = INF
		for g1 in stuck_g1s:
			var d = global_position.distance_to(g1.global_position)
			if d < min_dist:
				min_dist = d
				closest = g1
		
		target_g1 = closest
		current_state = State.MOVING_TO_TARGET
	else:
		current_state = State.IDLE

func _process_moving(delta: float) -> void:
	if not is_instance_valid(target_g1):
		target_g1 = null
		current_state = State.IDLE
		return
		
	var state = target_g1.get("current_state")
	var inactivity = target_g1.get("inactivity_timer")
	var is_still_stuck = state == 0 or (inactivity != null and inactivity > 15.0)
	
	if not is_still_stuck:
		target_g1 = null
		current_state = State.IDLE
		return
		
	var target_pos = target_g1.global_position
	var dir = (target_pos - global_position).normalized()
	var dist = global_position.distance_to(target_pos)
	
	if dist > unblock_radius:
		velocity = dir * move_speed
		move_and_slide()
		
		# Rotate visuals to face movement
		if velocity.length() > 0.1:
			var look_target = global_position + velocity
			visuals.look_at(look_target, Vector3.UP)
	else:
		current_state = State.UNBLOCKING

func _process_unblocking(_delta: float) -> void:
	if is_instance_valid(target_g1):
		# Reset G1 inactivity and force state reset
		target_g1.set("inactivity_timer", 0.0)
		target_g1.set("current_state", 0) # Force to IDLE
		
		# Teleport G1 to the core
		var core = target_g1.get("core_node")
		if is_instance_valid(core):
			target_g1.global_position = core.global_position + Vector3(0, 1.0, 0) # Slightly above core
			print("[G0] Teleported G1 to Core: ", target_g1.get_instance_id())
		
		# Trigger unblock/re-evaluation
		if target_g1.has_method("force_search_data"):
			target_g1.call("force_search_data")
		
		# Visual feedback: pulse antenna
		var tween = create_tween()
		tween.tween_property(antenna, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
		tween.tween_property(antenna, "scale", Vector3.ONE, 0.1)
		
		print("[G0] Unblocked G1: ", target_g1.get_instance_id())
		
	target_g1 = null
	current_state = State.IDLE
