extends CharacterBody3D

signal selected(genezis: CharacterBody3D)

enum State { PATROL, PROTECT_CORE, PROTECT_G1, INTERCEPT_THREAT }

@export var move_speed: float = 8.0
@export var patrol_radius: float = 15.0

var current_state: State = State.PATROL
var core_node: Node3D = null
var target_to_protect: Node3D = null
var patrol_target: Vector3 = Vector3.ZERO
var _wait_timer: float = 0.0

func _ready() -> void:
	add_to_group("genezis_g2")
	# Find core
	var cores = get_tree().get_nodes_in_group("core")
	if cores.size() > 0:
		core_node = cores[0]
	
	_set_new_patrol_target()

func _physics_process(delta: float) -> void:
	match current_state:
		State.PATROL:
			if global_position.distance_to(patrol_target) < 1.0:
				_wait_timer += delta
				if _wait_timer > 2.0:
					_set_new_patrol_target()
					_wait_timer = 0.0
			else:
				move_towards(patrol_target, delta)
		
		State.PROTECT_CORE:
			if is_instance_valid(core_node):
				var target_pos = core_node.global_position + Vector3(0, 2, 0)
				move_towards(target_pos, delta)
		
		State.PROTECT_G1:
			if is_instance_valid(target_to_protect):
				var target_pos = target_to_protect.global_position + Vector3(0, 1.5, 0)
				move_towards(target_pos, delta)
			else:
				current_state = State.PATROL

func _set_new_patrol_target() -> void:
	var center = Vector3.ZERO
	if is_instance_valid(core_node):
		center = core_node.global_position
	
	var angle = randf() * TAU
	var dist = randf() * patrol_radius
	patrol_target = center + Vector3(cos(angle) * dist, 2.0, sin(angle) * dist)

func move_towards(target_pos: Vector3, delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	move_and_slide()

func get_stats() -> Dictionary:
	return {
		"type": "Genezis G2",
		"speed": move_speed,
		"extraction": 0,
		"capacity": 0,
		"load": 0,
		"state": State.keys()[current_state]
	}

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
			get_viewport().set_input_as_handled()
