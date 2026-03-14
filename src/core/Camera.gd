extends Camera3D

@export var zoom_speed: float = 0.5
@export var min_zoom: float = 5.0
@export var max_zoom: float = 20.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom(-zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom(zoom_speed)

func zoom(amount: float) -> void:
	var new_distance = global_position.length() + amount
	new_distance = clamp(new_distance, min_zoom, max_zoom)
	
	# The camera is always looking at the origin (0,0,0) and fixed at an angle
	# We adjust the distance along its current vector
	var direction = global_position.normalized()
	global_position = direction * new_distance
