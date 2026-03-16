extends Node3D

signal data_spot_spawned(spot: Node3D)
signal genezis_spawned(genezis: CharacterBody3D)
signal genezis_g2_spawned(genezis: CharacterBody3D)
signal genezis_removed
signal new_enemy_type_spawned(type_name: String)

@export var data_spot_scene: PackedScene
@export var genezis_g1_scene: PackedScene
@export var genezis_g2_scene: PackedScene
@export var bit_scrubber_scene: PackedScene
@export var defragmenter_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var min_spawn_distance: float = 5.0
@export var initial_spots: int = 5

@onready var time_manager = $TimeManager

var core_node: Node3D = null
var _g2_spawn_count: int = 0
var _discovered_enemies: Array[String] = []

func _ready() -> void:
	core_node = get_tree().get_first_node_in_group("core")
	if core_node:
		core_node.evolution_changed.connect(_on_core_evolution_changed)
	
	time_manager.iteration_started.connect(_on_iteration_started)
	
	# Skip initial spawn if we're loading a game
	# We check if there's any G1 already (SaveManager might have spawned them)
	await get_tree().process_frame
	if get_tree().get_nodes_in_group("genezis_g1").is_empty():
		# Initial spawn: ensure at least 4 spots within FOV
		_spawn_initial_data_spots()
		# Initial genezis
		_spawn_genezis_g1()

func _on_core_evolution_changed(new_level: int) -> void:
	if new_level == 1:
		# Immediate spawn some evolved spots
		_spawn_data_spots(5)
		print("Evolution 1: Evolving simulation environment.")

func _on_iteration_started(number: int) -> void:
	_spawn_data_spots(5)
	
	# Spawn enemies every 2 iterations after the first 3 iterations
	if number > 3 and number % 2 == 0:
		_spawn_enemies()

func _spawn_enemies() -> void:
	# Randomly spawn 1-2 BitScrubbers and 1 Defragmenter
	var num_scrubbers = randi_range(1, 2)
	for i in range(num_scrubbers):
		_spawn_single_enemy(bit_scrubber_scene)
	
	_spawn_single_enemy(defragmenter_scene)
	print("Enemies spawned!")

func _spawn_single_enemy(scene: PackedScene) -> void:
	if not scene: return
	var enemy = scene.instantiate()
	add_child(enemy)
	
	# Handle discovery
	var enemy_type = ""
	if enemy is BitScrubber: enemy_type = "BitScrubber"
	elif enemy is Defragmenter: enemy_type = "Defragmenter"
	
	if enemy_type != "" and not _discovered_enemies.has(enemy_type):
		_discovered_enemies.append(enemy_type)
		new_enemy_type_spawned.emit(enemy_type)
	
	# Spawn at edge of FOV or random distance
	var angle = randf() * TAU
	var elevation = randf_range(-PI/4, PI/4) # Spread vertically
	var distance = spawn_radius * 1.5 # Spawn outside initial view
	
	enemy.global_position = Vector3(
		cos(angle) * cos(elevation) * distance,
		sin(elevation) * distance,
		sin(angle) * cos(elevation) * distance
	)

func spawn_extra_genezis_g1() -> void:
	_spawn_genezis_g1()

func fuse_genezis() -> void:
	if core_node and core_node.evolution_level < 2:
		print("Fusion failed: Requires evolution level 2.")
		return
		
	var g1_beings = get_tree().get_nodes_in_group("genezis_g1")
	# Filter out G1s that are already merging
	var available_g1s = []
	for g in g1_beings:
		if g.current_state != 5: # 5 is State.MERGING in GenezisG1.gd
			available_g1s.append(g)
			
	if available_g1s.size() >= 5: # Require at least 5 G1s (4 to fuse, 1 to keep)
		# Take 4 G1s
		var to_fuse = []
		for i in range(4):
			to_fuse.append(available_g1s[i])
		
		# Average position
		var avg_pos = Vector3.ZERO
		for g in to_fuse:
			avg_pos += g.global_position
		avg_pos /= 4.0
		
		# Set G1s to merging state
		for g in to_fuse:
			g.current_state = 5 # State.MERGING
			g.merging_target_pos = avg_pos
		
		print("Fusion started: 4 G1s merging at ", avg_pos)
		
		# Create a timer to complete the fusion
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(func():
			# Re-calculate average position in case they moved significantly (though they should converge)
			var final_avg_pos = Vector3.ZERO
			var count = 0
			for g in to_fuse:
				if is_instance_valid(g):
					final_avg_pos += g.global_position
					count += 1
			
			if count > 0:
				final_avg_pos /= float(count)
				
				# Remove G1s
				for g in to_fuse:
					if is_instance_valid(g):
						g.remove_from_group("genezis_g1")
						g.queue_free()
				
				genezis_removed.emit()
				
				# Spawn G2
				_spawn_genezis_g2(final_avg_pos)
				print("Fusion complete: 4 G1 fused into 1 G2.")
		)

func _spawn_genezis_g2(pos: Vector3) -> void:
	if not genezis_g2_scene: return
	var g2 = genezis_g2_scene.instantiate()
	add_child(g2)
	g2.global_position = pos
	genezis_g2_spawned.emit(g2)
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/G2.mp3")
	
	_g2_spawn_count += 1
	
	if _g2_spawn_count == 1:
		_spawn_single_enemy(bit_scrubber_scene)
		print("First G2 created: Spawning Bit-Scrubber for discovery!")
	elif _g2_spawn_count == 2:
		_spawn_single_enemy(defragmenter_scene)
		print("Second G2 created: Spawning Defragmenter for discovery!")

func _spawn_initial_data_spots() -> void:
	var core = get_tree().get_first_node_in_group("core")
	var fov_radius = 10.0 # Default fallback
	if core:
		fov_radius = core.fov_radius
	
	# Spawn 4 spots within FOV [min_spawn_distance, fov_radius]
	for i in range(4):
		_spawn_single_data_spot(min_spawn_distance, fov_radius)
	
	# Spawn the rest normally (if initial_spots > 4)
	if initial_spots > 4:
		_spawn_data_spots(initial_spots - 4)

func _spawn_data_spots(count: int) -> void:
	for i in range(count):
		_spawn_single_data_spot(min_spawn_distance, spawn_radius)

func _spawn_single_data_spot(min_dist: float, max_dist: float) -> void:
	var spot = data_spot_scene.instantiate()
	add_child(spot)
	
	# Evolve data spot size based on Core evolution level
	if core_node and core_node.evolution_level > 0:
		# Randomly spawn a larger variant if evolved
		if randf() < 0.2: # 20% chance for a 50 MB spot
			spot.max_bytes = 52428800 # 50 MB
			spot.scale = Vector3(2, 2, 2)
		else:
			spot.max_bytes = 1048576 # 1 MB instead of 1 KB
			spot.scale = Vector3(1.2, 1.2, 1.2)
	
	# Random position within range [min_dist, max_dist] in 3D
	var angle = randf() * TAU
	var elevation = randf_range(-PI/2, PI/2)
	var distance = randf_range(min_dist, max_dist)
	spot.global_position = Vector3(
		cos(angle) * cos(elevation) * distance,
		sin(elevation) * distance,
		sin(angle) * cos(elevation) * distance
	)

func _spawn_genezis_g1() -> void:
	if not genezis_g1_scene: return
	var genezis = genezis_g1_scene.instantiate()
	add_child(genezis)
	# Apply current upgrades if any
	_apply_current_upgrades(genezis)
	# Random initial position in space
	var angle = randf() * TAU
	var elevation = randf_range(-PI/4, PI/4)
	var distance = 5.0
	genezis.global_position = Vector3(
		cos(angle) * cos(elevation) * distance,
		sin(elevation) * distance,
		sin(angle) * cos(elevation) * distance
	)
	genezis_spawned.emit(genezis)
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/G1.mp3")

func _apply_current_upgrades(genezis: CharacterBody3D) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("UpgradeMenu"):
		var menu = hud.get_node("UpgradeMenu")
		# Speed
		var speed_level = menu.upgrade_levels.get("speed", 0)
		if speed_level > 0:
			genezis.upgrade_speed(pow(1.2, speed_level))
		# Extraction
		var extraction_level = menu.upgrade_levels.get("extraction", 0)
		if extraction_level > 0:
			genezis.upgrade_extraction(pow(1.2, extraction_level))
		# Capacity
		var capacity_level = menu.upgrade_levels.get("capacity", 0)
		if capacity_level > 0:
			genezis.upgrade_capacity(pow(1.2, capacity_level))
