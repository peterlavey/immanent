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

@onready var visuals: Node3D = $Visuals
@onready var head: MeshInstance3D = $Visuals/Head
@onready var connection_beam: MeshInstance3D = $ConnectionBeam
@onready var data_particles: GPUParticles3D = $DataParticles

var _pulse_timer: float = 0.0

func _physics_process(delta: float) -> void:
	if current_state == State.EXTRACTING:
		if is_instance_valid(target_data_spot):
			_pulse_timer += delta * 10.0
			var s = 1.0 + sin(_pulse_timer) * 0.1
			head.scale = Vector3(s, s, s)
			_update_connection_visual(target_data_spot.global_position)
		else:
			current_state = State.RETURNING_TO_CORE
	elif current_state == State.DEPOSITING:
		if is_instance_valid(core_node):
			_update_connection_visual(core_node.global_position)
		else:
			current_state = State.IDLE
	else:
		head.scale = Vector3.ONE
		_pulse_timer = 0.0
		connection_beam.visible = false
		data_particles.emitting = false
		data_particles.visible = false
	
	match current_state:
		State.IDLE:
			find_data_spot()
		State.MOVING_TO_DATA:
			if is_instance_valid(target_data_spot):
				var target_pos = target_data_spot.global_position + target_offset
				move_towards(target_pos, delta)
				if global_position.distance_to(target_pos) < 0.5:
					current_state = State.EXTRACTING
					_extraction_accumulator = 0.0
					print("[G1] Started extracting")
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
				
				if current_load >= carry_capacity:
					current_state = State.RETURNING_TO_CORE
					print("[G1] Capacity reached, returning to core")
				elif not is_instance_valid(target_data_spot):
					current_state = State.RETURNING_TO_CORE
			else:
				current_state = State.RETURNING_TO_CORE
		State.RETURNING_TO_CORE:
			if is_instance_valid(core_node):
				move_towards(core_node.global_position, delta)
				if global_position.distance_to(core_node.global_position) < 2.5:
					current_state = State.DEPOSITING
					print("[G1] Started depositing")
		State.DEPOSITING:
			if is_instance_valid(core_node):
				core_node.deposit_data(current_load, global_position)
				print("[G1] Deposited ", current_load, " data")
				current_load = 0
				current_state = State.IDLE

func find_data_spot() -> void:
	if not is_instance_valid(core_node):
		var cores = get_tree().get_nodes_in_group("core")
		if cores.size() > 0:
			core_node = cores[0]
		else:
			return # No core yet, cannot find spots
			
	var spots = get_tree().get_nodes_in_group("data_spots")
	var closest_spot: Node3D = null
	var min_distance: float = INF
	
	for spot in spots:
		if is_instance_valid(spot) and is_instance_valid(core_node):
			var spot_pos = spot.global_position
			var dist_to_core = spot_pos.distance_to(core_node.global_position)
			# Add a small buffer (0.5) to FOV check to account for spot size and float precision
			if dist_to_core <= core_node.fov_radius + 0.5:
				var dist_to_me = global_position.distance_to(spot_pos)
				
				# Count how many other G1s are targeting this spot
				var targeting_count = 0
				var g1s = get_tree().get_nodes_in_group("genezis_g1")
				for g1 in g1s:
					if g1 != self and is_instance_valid(g1.target_data_spot) and g1.target_data_spot == spot and (g1.current_state == State.MOVING_TO_DATA or g1.current_state == State.EXTRACTING):
						targeting_count += 1
				
				# Preference for spots with fewer miners already targeting them
				# A spot with more miners is effectively 'further away'
				var score = dist_to_me + (targeting_count * 10.0) # Penalty of 10 units per miner
				
				if score < min_distance:
					min_distance = score
					closest_spot = spot
	
	if closest_spot and is_instance_valid(closest_spot) and is_instance_valid(core_node):
		var spot_pos = closest_spot.global_position
		print("[G1] ", get_instance_id(), " Found data spot at ", spot_pos, " (dist to core: ", spot_pos.distance_to(core_node.global_position), ") score: ", min_distance)
		target_data_spot = closest_spot
		# Calculate a surrounding offset in 3D
		var angle = (get_instance_id() % 360) * (PI / 180.0)
		var elevation = (get_instance_id() % 180 - 90) * (PI / 180.0)
		var radius = 1.2
		target_offset = Vector3(
			cos(angle) * cos(elevation) * radius,
			sin(elevation) * radius,
			sin(angle) * cos(elevation) * radius
		)
		current_state = State.MOVING_TO_DATA
	else:
		if spots.size() > 0:
			print("[G1] ", get_instance_id(), " FAILED to find data spot among ", spots.size(), " spots. FOV radius: ", core_node.fov_radius if core_node else "N/A")
		else:
			pass # Normal if no spots exist yet

func move_towards(target_pos: Vector3, delta: float) -> void:
	var direction = (target_pos - global_position).normalized()
	velocity = direction * move_speed
	# Simple look at
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		# Check if the target is not exactly above or below to avoid look_at error
		if abs(direction.dot(Vector3.UP)) < 0.99:
			look_at(look_target, Vector3.UP)
		else:
			look_at(look_target, Vector3.RIGHT)
	move_and_slide()

func _update_connection_visual(target_pos: Vector3) -> void:
	if not connection_beam or not data_particles:
		return
		
	var start_pos = head.global_position
	var end_pos = target_pos
	
	var diff = end_pos - start_pos
	var distance = diff.length()
	
	connection_beam.visible = true
	connection_beam.global_position = start_pos + diff * 0.5
	
	# Rotate the cylinder to point from start to end
	if diff.length() > 0.001:
		connection_beam.look_at(end_pos, Vector3.UP)
		connection_beam.rotate_object_local(Vector3.RIGHT, PI/2.0)
		
	# Scale the cylinder mesh height
	connection_beam.scale.y = distance
	
	# Pulse the beam width slightly
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.02) * 0.2
	connection_beam.scale.x = pulse
	connection_beam.scale.z = pulse
	
	# Update particles
	data_particles.visible = true
	data_particles.emitting = true
	data_particles.global_position = end_pos

func reset_load() -> void:
	current_load = 0
	# Brief visual feedback or state reset if needed
	current_state = State.RETURNING_TO_CORE

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
