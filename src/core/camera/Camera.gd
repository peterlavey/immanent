extends Camera3D

@export var zoom_speed: float = 0.5
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0
@export var rotation_speed: float = 0.005
@export var gesture_zoom_speed: float = 1.0
@export var parallax_factor: float = 0.05

var orbit_distance: float = 20.0
var target: Vector3 = Vector3.ZERO
var rotation_angles: Vector2 = Vector2(0.7, 0.7) # X: vertical, Y: horizontal

func _ready() -> void:
	# Set target to origin where Core is located
	target = Vector3.ZERO
	_update_camera_position()

func _unhandled_input(event: InputEvent) -> void:
	if event.get_class() == "InputEventMagnificationGesture":
		# gesture zoom: factor > 1 means zoom in, < 1 means zoom out
		# orbit_distance: zoom in means decrease distance
		var magnification = event.get("magnification")
		if magnification == null:
			magnification = 1.0
		
		# Some macOS versions might report 1.0 + delta, others 1.0 * factor.
		# If magnification is very close to 1.0 but not 1.0, we treat it as delta.
		# However, usually 1.1 = 10% zoom.
		var zoom_delta = (1.0 - magnification) * orbit_distance * gesture_zoom_speed * 10.0
		zoom(zoom_delta)
		return

	if event.get_class() == "InputEventPanGesture":
		# Trackpad pan gestures
		var delta = event.get("delta")
		if delta == null:
			delta = Vector2.ZERO
		
		# Panning on trackpad usually means orbiting for a 3D camera
		_rotate_camera(delta.x * rotation_speed * 20.0, delta.y * rotation_speed * 20.0)
		return

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# macOS pinch-to-zoom is often sent as Ctrl + Wheel or Cmd + Wheel
				if event.ctrl_pressed or event.command_or_control_autoremap:
					zoom(-zoom_speed * 5.0)
				else:
					zoom(-zoom_speed)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				if event.ctrl_pressed or event.command_or_control_autoremap:
					zoom(zoom_speed * 5.0)
				else:
					zoom(zoom_speed)
		return
	
	if event is InputEventMouseMotion:
		# Standard mouse/trackpad drag orbiting
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT or event.button_mask & MOUSE_BUTTON_MASK_RIGHT or event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			_rotate_camera(event.relative.x * rotation_speed, event.relative.y * rotation_speed)
		
		# Some macOS trackpad "pan" can come as MouseMotion with specific pressure or flags, 
		# but standard drag handles it above.

func _rotate_camera(dx: float, dy: float) -> void:
	rotation_angles.y -= dx
	rotation_angles.x -= dy
	# Clamp vertical rotation to avoid being exactly at poles where look_at(Vector3.UP) fails
	rotation_angles.x = clamp(rotation_angles.x, -PI/2 + 0.1, PI/2 - 0.1)
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
	
	# Parallax effect: background follows camera position but at a fraction
	# and rotates slightly to create depth.
	var parallax_bg = get_node_or_null("../ParallaxBackground")
	if parallax_bg:
		# Follow camera but move less
		parallax_bg.global_position = global_position * parallax_factor
		# Slight rotation based on camera position
		parallax_bg.rotation.y = rotation_angles.y * 0.1
		parallax_bg.rotation.x = rotation_angles.x * 0.1
