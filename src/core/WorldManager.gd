extends Node3D

signal data_spot_spawned(spot: Node3D)
signal genezis_spawned(genezis: CharacterBody3D)

@export var data_spot_scene: PackedScene
@export var genezis_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var min_spawn_distance: float = 5.0
@export var initial_spots: int = 5

@onready var time_manager = $TimeManager

func _ready() -> void:
	time_manager.iteration_started.connect(_on_iteration_started)
	# Initial spawn: ensure at least 4 spots within FOV
	_spawn_initial_data_spots()
	# Initial genezis
	_spawn_genezis()

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
	
	# Random position within range [min_dist, max_dist]
	var angle = randf() * TAU
	var distance = randf_range(min_dist, max_dist)
	spot.global_position = Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _spawn_genezis() -> void:
	var genezis = genezis_scene.instantiate()
	add_child(genezis)
	genezis.global_position = Vector3(2, 0, 2)
	genezis_spawned.emit(genezis)
