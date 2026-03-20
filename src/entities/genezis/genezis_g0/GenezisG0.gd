extends CharacterBody3D

enum State { IDLE, SEARCHING, MOVING_TO_TARGET, UNBLOCKING, ORBITING }

@export var move_speed: float = 8.0
@export var acceleration: float = 10.0
@export var friction: float = 5.0
@export var unblock_radius: float = 1.0
@export var orbit_radius: float = 3.5
@export var orbit_speed: float = 0.5

var current_state: State = State.IDLE
var target_g1: CharacterBody3D = null
var _scan_timer: float = 0.0
var _scan_interval: float = 1.0
var _orbit_angle: float = 0.0
var _orbit_axis: Vector3 = Vector3.UP
var _orbit_phase_offset: float = 0.0

@onready var visuals: Node3D = $Visuals
@onready var antenna: Node3D = $Visuals/Antenna

func _ready() -> void:
	add_to_group("genezis_g0")
	
	# Randomize orbit for "electron" look
	_orbit_phase_offset = randf() * TAU
	
	# Create a random rotation axis (not just UP)
	var random_dir = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-0.5, 0.5), # Keep it somewhat horizontal-ish but tilted
		randf_range(-1.0, 1.0)
	).normalized()
	
	if random_dir.is_zero_approx():
		random_dir = Vector3.UP
	_orbit_axis = random_dir

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
		State.ORBITING:
			_process_orbiting(delta)

func _process_idle(delta: float) -> void:
	_scan_timer += delta
	if _scan_timer >= _scan_interval:
		_scan_timer = 0.0
		current_state = State.SEARCHING
	
	# If we are in IDLE, we might as well orbit if no target
	if not is_instance_valid(target_g1):
		current_state = State.ORBITING

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
		current_state = State.ORBITING

func _process_orbiting(delta: float) -> void:
	# Scan periodically even while orbiting
	_scan_timer += delta
	if _scan_timer >= _scan_interval:
		_scan_timer = 0.0
		_process_searching(delta)
		if current_state != State.ORBITING:
			return

	var core = get_tree().get_first_node_in_group("core")
	if not is_instance_valid(core):
		current_state = State.IDLE
		return
		
	# Update angle
	_orbit_angle += orbit_speed * delta
	
	# Electrons orbit in planes. We use a base vector and rotate it.
	# Start with a vector on the XY plane of the orbit (arbitrary perpendicular to _orbit_axis)
	var base_vec = Vector3.UP.cross(_orbit_axis)
	if base_vec.length() < 0.1:
		base_vec = Vector3.RIGHT.cross(_orbit_axis)
	base_vec = base_vec.normalized() * orbit_radius
	
	# Rotate the base vector around the _orbit_axis by current angle + offset
	var current_pos_offset = base_vec.rotated(_orbit_axis, _orbit_angle + _orbit_phase_offset)
	
	# Move towards the orbit position
	global_position = core.global_position + current_pos_offset
	
	# Rotate visuals to face movement (tangent to orbit)
	# We can calculate the tangent by rotating the current_pos_offset by 90 degrees around the _orbit_axis
	var tangent = _orbit_axis.cross(current_pos_offset).normalized()
	if tangent.length() > 0.1:
		visuals.look_at(global_position + tangent, Vector3.UP)

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
		var target_velocity = dir * move_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		move_and_slide()
		
		# Rocket-like momentum: the "up" axis should slightly lean towards the acceleration
		if velocity.length() > 0.1:
			var target_up = Vector3.UP
			var accel_dir = (target_velocity - velocity).normalized()
			if accel_dir.length() > 0.1:
				# Tilt the unit in the direction of acceleration (momentum from below)
				target_up = (Vector3.UP + accel_dir * 0.5).normalized()
				
			var current_quat = visuals.global_transform.basis.get_rotation_quaternion()
			var target_quat: Quaternion
			
			# Look towards velocity but use the tilted up vector
			if abs(velocity.normalized().dot(target_up)) < 0.99:
				target_quat = Transform3D().looking_at(velocity, target_up).basis.get_rotation_quaternion()
			else:
				target_quat = Transform3D().looking_at(velocity, Vector3.RIGHT).basis.get_rotation_quaternion()
			
			visuals.global_transform.basis = Basis(current_quat.slerp(target_quat, 10.0 * delta))
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		move_and_slide()
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
