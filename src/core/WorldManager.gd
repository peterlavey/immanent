extends Node3D

signal data_spot_spawned(spot: Node3D)
signal genezis_spawned(genezis: CharacterBody3D)

@export var data_spot_scene: PackedScene
@export var genezis_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var min_spawn_distance: float = 5.0
@export var initial_spots: int = 5

@onready var time_manager = $TimeManager

var core_node: Node3D = null

func _ready() -> void:
	core_node = get_tree().get_first_node_in_group("core")
	if core_node:
		core_node.evolution_changed.connect(_on_core_evolution_changed)
	
	time_manager.iteration_started.connect(_on_iteration_started)
	# Initial spawn: ensure at least 4 spots within FOV
	_spawn_initial_data_spots()
	# Initial genezis
	_spawn_genezis()

func _on_core_evolution_changed(new_level: int) -> void:
	if new_level == 1:
		# Immediate spawn some evolved spots
		_spawn_data_spots(5)
		print("Evolution 1: Evolving simulation environment.")

func _on_iteration_started(_number: int) -> void:
	_spawn_data_spots(5)

func spawn_extra_genezis() -> void:
	_spawn_genezis()

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
	
	# Random position within range [min_dist, max_dist]
	var angle = randf() * TAU
	var distance = randf_range(min_dist, max_dist)
	spot.global_position = Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _spawn_genezis() -> void:
	var genezis = genezis_scene.instantiate()
	add_child(genezis)
	genezis.global_position = Vector3(2, 0, 2)
	genezis_spawned.emit(genezis)
