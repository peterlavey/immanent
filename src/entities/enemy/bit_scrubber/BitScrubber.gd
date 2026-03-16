extends Enemy

class_name BitScrubber

@export var floating_text_scene: PackedScene = preload("res://src/ui/floating_text/FloatingText.tscn")
@export var steal_cooldown: float = 3.0
@export var steal_duration: float = 1.0

@onready var connection_beam: MeshInstance3D = $ConnectionBeam
@onready var steal_particles: GPUParticles3D = $StealParticles

var _cooldown_timer: float = 0.0
var _stealing_timer: float = 0.0

func _ready() -> void:
	super._ready()
	move_speed = 7.0 # Fast scrubber
	health = 2.0

func _physics_process(delta: float) -> void:
	if _cooldown_timer > 0:
		_cooldown_timer -= delta
	
	super._physics_process(delta)

func _find_target() -> void:
	if _cooldown_timer > 0:
		return
		
	var g1_units = get_tree().get_nodes_in_group("genezis_g1")
	var closest: Node3D = null
	var min_dist = INF
	
	for g1 in g1_units:
		if is_instance_valid(g1) and not g1.is_queued_for_deletion():
			var g1_pos = g1.global_position
			var d = global_position.distance_to(g1_pos)
			if d < min_dist:
				min_dist = d
				closest = g1
	
	if closest:
		target = closest
		current_state = State.MOVING_TO_TARGET

func _perform_action(delta: float) -> void:
	if is_instance_valid(target) and target.has_method("reset_load"):
		if _stealing_timer <= 0:
			# Just started stealing
			_stealing_timer = steal_duration
			# Visual effect on
			connection_beam.visible = true
			steal_particles.visible = true
			steal_particles.emitting = true
			
		_stealing_timer -= delta
		_update_connection_visual(target.global_position)
		
		if _stealing_timer <= 0:
			# Finished stealing
			var stolen_amount = 0
			if target.get("current_load"):
				stolen_amount = target.current_load
			
			target.reset_load()
			
			if stolen_amount > 0:
				_spawn_floating_text(stolen_amount, target.global_position)
				
			_cooldown_timer = steal_cooldown
			_finish_action()
	else:
		_finish_action()

func _finish_action() -> void:
	current_state = State.IDLE
	target = null
	_stealing_timer = 0
	connection_beam.visible = false
	steal_particles.emitting = false
	steal_particles.visible = false

func _update_connection_visual(target_pos: Vector3) -> void:
	var start_pos = global_position
	var end_pos = target_pos
	
	var diff = end_pos - start_pos
	var distance = diff.length()
	
	connection_beam.global_position = start_pos + diff * 0.5
	
	if diff.length() > 0.001:
		connection_beam.look_at(end_pos, Vector3.UP)
		connection_beam.rotate_object_local(Vector3.RIGHT, PI/2.0)
		
	connection_beam.scale.y = distance
	
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.04) * 0.3
	connection_beam.scale.x = pulse
	connection_beam.scale.z = pulse
	
	steal_particles.global_position = end_pos

func _spawn_floating_text(amount: int, pos: Vector3) -> void:
	if floating_text_scene:
		var text_instance = floating_text_scene.instantiate()
		get_parent().add_child(text_instance)
		
		text_instance.global_position = pos + Vector3(0, 1.0, 0)
		text_instance.text = "-" + format_bytes(amount)
		text_instance.modulate = Color.RED

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)
