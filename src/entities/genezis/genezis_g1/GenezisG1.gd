extends CharacterBody3D

signal selected(genezis: CharacterBody3D)

enum State { IDLE, MOVING_TO_DATA, EXTRACTING, RETURNING_TO_CORE, DEPOSITING, MERGING }

@export var move_speed: float = 5.0
@export var carry_capacity: int = 100 # Capacity in bytes
@export var extraction_rate: int = 10 # Bytes per second

# Psinergy upgrade variables
@export var connection_range: float = 0.0 # Disabled by default (0.0)
@export var connection_boost: float = 1.0 # Multiplier (1.0 = no boost)

var current_state: State = State.IDLE
var target_data_spot: Node3D = null
var target_offset: Vector3 = Vector3.ZERO
var current_load: int = 0
var core_node: Node3D = null
var merging_target_pos: Vector3 = Vector3.ZERO
var _extraction_accumulator: float = 0.0

var connected_g1: CharacterBody3D = null

# Stuck detection variables
var _stuck_timer: float = 0.0
var _last_position: Vector3 = Vector3.ZERO
var _last_load: int = 0
var _stuck_threshold: float = 8.0 # Seconds before declaring stuck
var _position_threshold: float = 0.1 # Minimum movement in 1 second
var _stuck_reset_count: int = 0
var inactivity_timer: float = 0.0 # Time since last data extraction/deposit

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

func force_search_data() -> void:
	if current_state == State.IDLE:
		target_data_spot = null # Clear any potential invalid target
		find_data_spot()

@onready var visuals: Node3D = $Visuals
@onready var head: MeshInstance3D = $Visuals/Head
@onready var connection_beam: MeshInstance3D = $ConnectionBeam
@onready var psinergy_beam: MeshInstance3D = $PsinergyBeam
@onready var data_particles: GPUParticles3D = $DataParticles

var _pulse_timer: float = 0.0

func _physics_process(delta: float) -> void:
	inactivity_timer += delta
	# Stuck detection logic
	if current_state != State.IDLE:
		_stuck_timer += delta
		
		# Check if we've moved significantly or changed load (if extracting)
		var distance_moved = global_position.distance_to(_last_position)
		if distance_moved > _position_threshold * delta or current_load != _last_load:
			_stuck_timer = 0.0
			_last_position = global_position
			_last_load = current_load
			
		# If we've been stuck too long, force idle and reset
		if _stuck_timer >= _stuck_threshold:
			print("[G1] ", get_instance_id(), " declared stuck in state ", State.keys()[current_state], ". Resetting to IDLE.")
			current_state = State.IDLE
			_stuck_timer = 0.0
			target_data_spot = null
			_stuck_reset_count += 1
	else:
		_stuck_timer = 0.0
		_last_position = global_position
		_last_load = current_load

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
		
		# Show G1 connection beam at all times when not mining or depositing
		# Only the G1 with the smaller instance ID shows the beam to avoid double lines
		if connected_g1 and is_instance_valid(connected_g1) and get_instance_id() < connected_g1.get_instance_id():
			_update_psinergy_visual(connected_g1.global_position)
		else:
			psinergy_beam.visible = false
		
		connection_beam.visible = false
		data_particles.emitting = false
		data_particles.visible = false
	
	# Connection logic
	_update_g1_connection(delta)
	
	# If we are currently extracting or depositing, we should ALSO show the psinergy beam if connected
	# and we are the designated G1 for visuals (smaller instance ID)
	if (current_state == State.EXTRACTING or current_state == State.DEPOSITING) and \
	   connected_g1 and is_instance_valid(connected_g1) and \
	   get_instance_id() < connected_g1.get_instance_id():
		_update_psinergy_visual(connected_g1.global_position)
	elif current_state == State.EXTRACTING or current_state == State.DEPOSITING:
		psinergy_beam.visible = false

	match current_state:
		State.IDLE:
			find_data_spot()
		State.MOVING_TO_DATA:
			if is_instance_valid(target_data_spot):
				var target_pos = target_data_spot.global_position + target_offset
				move_towards(target_pos, delta)
				
				var dist = global_position.distance_to(target_pos)
				# If we are close enough OR we are stuck but very close to the data spot itself
				if dist < 0.6 or (dist < 1.0 and velocity.length() < 0.1):
					current_state = State.EXTRACTING
					_extraction_accumulator = 0.0
					print("[G1] Started extracting")
			else:
				current_state = State.IDLE
		State.EXTRACTING:
			if is_instance_valid(target_data_spot):
				var effective_extraction_rate = extraction_rate
				if connected_g1 and is_instance_valid(connected_g1):
					effective_extraction_rate *= connection_boost
					
				_extraction_accumulator += effective_extraction_rate * delta
				var to_extract = int(_extraction_accumulator)
				if to_extract > 0:
					var space_left = carry_capacity - current_load
					var can_extract = min(to_extract, space_left)
					
					var extracted = target_data_spot.extract_data(can_extract)
					if extracted > 0:
						inactivity_timer = 0.0
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
				inactivity_timer = 0.0
				current_state = State.IDLE
		State.MERGING:
			move_towards(merging_target_pos, delta)
			# Rotation is handled in move_towards

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
		# Use _stuck_reset_count to vary the offset if we were stuck
		var seed_val = get_instance_id() + _stuck_reset_count * 12345
		var angle = (seed_val % 360) * (PI / 180.0)
		var elevation = (seed_val % 180 - 90) * (PI / 180.0)
		var radius = 1.6 # Increased from 1.2 to be safely outside DataSpot's 1.2x1.2x1.2 box
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
	# Add slight random jitter to prevent being perfectly stuck in local minima/collisions
	var jitter = Vector3(
		randf_range(-0.1, 0.1),
		randf_range(-0.1, 0.1),
		randf_range(-0.1, 0.1)
	)
	var direction = (target_pos - global_position).normalized()
	velocity = (direction + jitter * 0.1).normalized() * move_speed
	# Simple look at
	if direction != Vector3.ZERO:
		var look_target = global_position + direction
		# Check if the target is not exactly above or below to avoid look_at error
		if abs(direction.dot(Vector3.UP)) < 0.99:
			look_at(look_target, Vector3.UP)
		else:
			look_at(look_target, Vector3.RIGHT)
	move_and_slide()

func _update_g1_connection(_delta: float) -> void:
	if connection_range <= 0.0:
		connected_g1 = null
		return
		
	# Check if current connection is still valid and in range
	if connected_g1 and is_instance_valid(connected_g1):
		# If the other G1 is connected to someone else, we should drop it to avoid overlapping connections
		# or multiple connections to the same G1 (forming a triangle or line)
		if global_position.distance_to(connected_g1.global_position) > connection_range or \
		   (connected_g1.connected_g1 and connected_g1.connected_g1 != self):
			connected_g1 = null
	
	# If no connection, look for a new one
	if not connected_g1 or not is_instance_valid(connected_g1):
		var g1s = get_tree().get_nodes_in_group("genezis_g1")
		var closest_g1: CharacterBody3D = null
		var min_dist = connection_range
		
		for g in g1s:
			if g == self: continue
			# Don't connect to a G1 that is already connected to someone else
			if g.connected_g1 and g.connected_g1 != self: continue
			
			var dist = global_position.distance_to(g.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_g1 = g
		
		connected_g1 = closest_g1

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

func _update_psinergy_visual(target_pos: Vector3) -> void:
	if not psinergy_beam:
		return
		
	var start_pos = head.global_position
	var end_pos = target_pos
	
	var diff = end_pos - start_pos
	var distance = diff.length()
	
	psinergy_beam.visible = true
	psinergy_beam.global_position = start_pos + diff * 0.5
	
	# Rotate the cylinder to point from start to end
	if diff.length() > 0.001:
		psinergy_beam.look_at(end_pos, Vector3.UP)
		psinergy_beam.rotate_object_local(Vector3.RIGHT, PI/2.0)
		
	# Scale the cylinder mesh height
	psinergy_beam.scale.y = distance
	
	# Pulse the beam width slightly (different frequency than extraction beam)
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.15
	psinergy_beam.scale.x = pulse
	psinergy_beam.scale.z = pulse

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
		"state": State.keys()[current_state],
		"conn_range": connection_range,
		"conn_boost": connection_boost,
		"is_connected": connected_g1 != null and is_instance_valid(connected_g1)
	}

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit(self)
			get_viewport().set_input_as_handled()
