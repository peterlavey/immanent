extends Node3D

signal data_changed(new_amount: int)
signal fov_changed(new_radius: float)

@export var current_data: int = 0:
	set(value):
		current_data = value
		data_changed.emit(current_data)

@export var fov_radius: float = 10.0:
	set(value):
		fov_radius = value
		fov_changed.emit(fov_radius)
		_update_fov_visual()

@onready var fov_visual: MeshInstance3D = $FOVVisual

func _ready() -> void:
	add_to_group("core")
	_update_fov_visual()

func _update_fov_visual() -> void:
	if is_instance_valid(fov_visual):
		fov_visual.scale = Vector3(fov_radius * 2, fov_radius * 2, fov_radius * 2)

func deposit_data(amount: int) -> void:
	current_data += amount
	print("Data deposited. Total: ", current_data)

func spend_data(amount: int) -> bool:
	if current_data >= amount:
		current_data -= amount
		return true
	return false
