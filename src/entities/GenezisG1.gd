extends CharacterBody3D

signal selected(genezis: CharacterBody3D)

enum State { IDLE, MOVING_TO_DATA, EXTRACTING, RETURNING_TO_CORE, DEPOSITING }

@export var move_speed: float = 5.0
@export var carry_capacity: int = 100 # Capacity in bytes
@export var extraction_rate: int = 10 # Bytes per second

var current_state: State = State.IDLE
var target_data_spot: Node3D = null
var target_offset: Vector3 = Vector3.ZERO
var current_load: int = 0
var core_node: Node3D = null
var _extraction_accumulator: float = 0.0

func _ready() -> void:
	add_to_group("genezis_g1")
	# Find core in group if not assigned
	var cores = get_tree().get_nodes_in_group("core")
	if cores.size() > 0:
		core_node = cores[0]

func upgrade_speed(multiplier: float) -> void:
	move_speed *= multiplier

func upgrade_extraction(multiplier: float) -> void:
	extraction_rate = int(extraction_rate * multiplier)

func upgrade_capacity(multiplier: float) -> void:
	carry_capacity = int(carry_capacity * multiplier)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			find_data_spot()
		State.MOVING_TO_DATA:
			if is_instance_valid(target_data_spot):
				var target_pos = target_data_spot.global_position + target_offset
				move_towards(target_pos, delta)
				if global_position.distance_to(target_pos) < 0.2:
					current_state = State.EXTRACTING
					_extraction_accumulator = 0.0
			else:
				current_state = State.IDLE
		State.EXTRACTING:
			if is_instance_valid(target_data_spot):
				_extraction_accumulator += extraction_rate * delta
				var to_extract = int(_extraction_accumulator)
				if to_extract > 0:
					var space_left = carry_capacity - current_load
					var can_extract = min(to_extract, space_left)
					
					var extracted = target_data_spot.extract_data(can_extract)
					current_load += extracted
					_extraction_accumulator -= extracted
				
				if current_load >= carry_capacity or not is_instance_valid(target_data_spot):
					current_state = State.RETURNING_TO_CORE
			else:
				current_state = State.RETURNING_TO_CORE
		State.RETURNING_TO_CORE:
			if is_instance_valid(core_node):
				move_towards(core_node.global_position, delta)
				if global_position.distance_to(core_node.global_position) < 2.0:
					current_state = State.DEPOSITING
		State.DEPOSITING:
			if is_instance_valid(core_node):
				core_node.deposit_data(current_load, global_position)
				current_load = 0
				current_state = State.IDLE

func find_data_spot() -> void:
	var spots = get_tree().get_nodes_in_group("data_spots")
	var closest_spot: Node3D = null
	var min_distance: float = INF
	
	for spot in spots:
		if is_instance_valid(core_node):
			var dist_to_core = spot.global_position.distance_to(core_node.global_position)
			if dist_to_core <= core_node.fov_radius:
				var dist_to_me = global_position.distance_to(spot.global_position)
				if dist_to_me < min_distance:
					min_distance = dist_to_me
					closest_spot = spot
	
	if closest_spot:
		target_data_spot = closest_spot
		# Calculate a surrounding offset based on instance ID to keep it stable
		var angle = (get_instance_id() % 360) * (PI / 180.0)
		var radius = 1.2 # Distance from the data spot center
		target_offset = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
		current_state = State.MOVING_TO_DATA

func move_towards(target_pos: Vector3, delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	# Simple look at
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	move_and_slide()

func get_stats() -> Dictionary:
	return {
		"type": "Genezis G1",
		"speed": move_speed,
		"capacity": carry_capacity,
		"extraction": extraction_rate,
		"load": current_load,
		"state": State.keys()[current_state]
	}

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
			get_viewport().set_input_as_handled()
