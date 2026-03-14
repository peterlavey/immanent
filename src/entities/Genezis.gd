extends CharacterBody3D

enum State { IDLE, MOVING_TO_DATA, EXTRACTING, RETURNING_TO_CORE, DEPOSITING }

@export var move_speed: float = 5.0
@export var carry_capacity: float = 1.0
@export var extraction_rate: float = 0.5 # MB per second

var current_state: State = State.IDLE
var target_data_spot: Node3D = null
var current_load: float = 0.0
var core_node: Node3D = null

func _ready() -> void:
	add_to_group("genezis")
	# Find core in group if not assigned
	var cores = get_tree().get_nodes_in_group("core")
	if cores.size() > 0:
		core_node = cores[0]

func upgrade_speed(multiplier: float) -> void:
	move_speed *= multiplier

func upgrade_extraction(multiplier: float) -> void:
	extraction_rate *= multiplier

func upgrade_capacity(multiplier: float) -> void:
	carry_capacity *= multiplier

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			find_data_spot()
		State.MOVING_TO_DATA:
			if is_instance_valid(target_data_spot):
				move_towards(target_data_spot.global_position, delta)
				if global_position.distance_to(target_data_spot.global_position) < 1.5:
					current_state = State.EXTRACTING
			else:
				current_state = State.IDLE
		State.EXTRACTING:
			if is_instance_valid(target_data_spot):
				var extracted = target_data_spot.extract_data(extraction_rate * delta)
				current_load += extracted
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
				core_node.deposit_data(int(current_load * 1024 * 1024)) # Convert MB to Bytes for core
				current_load = 0.0
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
		current_state = State.MOVING_TO_DATA

func move_towards(target_pos: Vector3, delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	# Simple look at
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		look_at(look_target, Vector3.UP)
	move_and_slide()
