extends Node3D

@export var data_spot_scene: PackedScene
@export var genezis_scene: PackedScene
@export var spawn_radius: float = 20.0
@export var min_spawn_distance: float = 5.0
@export var initial_spots: int = 5

@onready var time_manager = $TimeManager

func _ready() -> void:
	time_manager.iteration_started.connect(_on_iteration_started)
	# Initial spawn
	_spawn_data_spots(initial_spots)
	# Initial genezis
	_spawn_genezis()

func _on_iteration_started(_number: int) -> void:
	_spawn_data_spots(5)

func spawn_extra_genezis() -> void:
	_spawn_genezis()

func _spawn_data_spots(count: int) -> void:
	for i in range(count):
		var spot = data_spot_scene.instantiate()
		add_child(spot)
		
		# Random position within range [min_spawn_distance, spawn_radius]
		var angle = randf() * TAU
		var distance = randf_range(min_spawn_distance, spawn_radius)
		spot.global_position = Vector3(cos(angle) * distance, 0, sin(angle) * distance)

func _spawn_genezis() -> void:
	var genezis = genezis_scene.instantiate()
	add_child(genezis)
	genezis.global_position = Vector3(2, 0, 2)
