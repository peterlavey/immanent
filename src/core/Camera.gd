extends Camera3D

@export var zoom_speed: float = 0.5
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0
@export var rotation_speed: float = 0.005

var orbit_distance: float = 35.0
var target: Vector3 = Vector3.ZERO
var rotation_angles: Vector2 = Vector2(0.7, 0.7) # X: vertical, Y: horizontal

func _ready() -> void:
	# Set target to origin where Core is located
	target = Vector3.ZERO
	_update_camera_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom(-zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom(zoom_speed)
	
	if event is InputEventMouseMotion:
		# Use right-click or middle-click for orbiting
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT or event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			rotation_angles.y -= event.relative.x * rotation_speed
			rotation_angles.x -= event.relative.y * rotation_speed
			# Clamp vertical rotation to avoid flipping or going underground
			rotation_angles.x = clamp(rotation_angles.x, 0.2, PI/2 - 0.1)
			_update_camera_position()

func zoom(amount: float) -> void:
	orbit_distance += amount
	orbit_distance = clamp(orbit_distance, min_zoom, max_zoom)
	_update_camera_position()

func _update_camera_position() -> void:
	var pos = Vector3.ZERO
	pos.z = orbit_distance * cos(rotation_angles.x) * cos(rotation_angles.y)
	pos.x = orbit_distance * cos(rotation_angles.x) * sin(rotation_angles.y)
	pos.y = orbit_distance * sin(rotation_angles.x)
	
	global_position = target + pos
	look_at(target, Vector3.UP)
