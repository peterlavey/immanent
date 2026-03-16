extends StaticBody3D

signal selected
signal data_changed(new_amount: int)
signal fov_changed(new_radius: float)

signal evolution_changed(new_level: int)

@export var floating_text_scene: PackedScene = preload("res://src/ui/floating_text/FloatingText.tscn")
@export var current_data: int = 0: # Start with 0 data
	set(value):
		current_data = value
		data_changed.emit(current_data)

@export var evolution_level: int = 1:
	set(value):
		evolution_level = value
		evolution_changed.emit(evolution_level)
		_update_visual_for_evolution()

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
	if not is_node_ready():
		return
	if is_instance_valid(fov_visual):
		fov_visual.scale = Vector3(fov_radius * 2, fov_radius * 2, fov_radius * 2)

func _update_visual_for_evolution() -> void:
	if not is_node_ready():
		return
	# Evolve visual by changing color or adding effects, but keep scale constant
	# var scale_factor = 1.0 + (evolution_level * 0.5)
	# $Visuals.scale = Vector3(scale_factor, scale_factor, scale_factor)
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		# Use G2 sfx for evolution as it's more impactful
		audio_manager.play_sfx("res://assets/audio/sfx/G2.mp3", -5.0)
		
	print("Core evolved to level ", evolution_level)

func deposit_data(amount: int, position: Vector3 = Vector3.ZERO) -> void:
	current_data += amount
	_spawn_floating_text(amount, position)
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		# Use a subtle high-pitched beep for data deposition
		audio_manager.play_sfx("res://assets/audio/sfx/G1.mp3", -15.0)
	
	print("Data deposited. Total: ", current_data)

func _spawn_floating_text(amount: int, pos: Vector3) -> void:
	if floating_text_scene:
		var text_instance = floating_text_scene.instantiate()
		get_parent().add_child(text_instance)
		
		# If pos is zero (default), use Core's top as origin
		var spawn_pos = pos
		if spawn_pos == Vector3.ZERO:
			spawn_pos = global_position + Vector3(0, 2.5, 0)
		else:
			# Offset slightly from the exact deposition point to ensure visibility
			spawn_pos += Vector3(0, 0.5, 0)
			
		text_instance.global_position = spawn_pos
		text_instance.text = "+" + format_bytes(amount)

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)

func spend_data(amount: int) -> bool:
	if current_data >= amount:
		current_data -= amount
		return true
	return false

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			selected.emit()
			get_viewport().set_input_as_handled()
