extends StaticBody3D

signal depleted(data_spot: Node3D)

@export var max_bytes: int = 1024: # 1 KB per spot initially
	set(value):
		max_bytes = value
		current_bytes = value
		_update_world_space_label()

@export var world_space_ui_scene: PackedScene = preload("res://src/ui/hud/WorldSpaceUI.tscn")

var current_bytes: int = max_bytes:
	set(value):
		current_bytes = max(0, value)
		_update_world_space_label()
		if current_bytes <= 0:
			depleted.emit(self)
			queue_free()

var _world_space_label: Label3D

func _ready() -> void:
	add_to_group("data_spots")
	_setup_world_space_ui()
	
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").show_spots_labels_changed.connect(_on_show_labels_changed)
		_on_show_labels_changed(get_node("/root/SaveManager").show_spots_labels)

func _on_show_labels_changed(show: bool) -> void:
	if _world_space_label:
		_world_space_label.visible = show

func _setup_world_space_ui() -> void:
	if world_space_ui_scene:
		var ws_ui = world_space_ui_scene.instantiate()
		add_child(ws_ui)
		ws_ui.transform.origin = Vector3(0, 1.0, 0)
		_world_space_label = ws_ui.get_node("Label")
		_world_space_label.modulate = Color(0, 1, 0, 0.4) # Green for data
		_world_space_label.font_size = 6
		_update_world_space_label()

func _update_world_space_label() -> void:
	if _world_space_label:
		_world_space_label.text = "DATA_CACHE\nVAL: %s" % format_bytes(current_bytes)

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)

@onready var visuals: Node3D = $Visuals

func _process(delta: float) -> void:
	if is_instance_valid(visuals):
		visuals.rotate_y(delta * 0.5)
		visuals.position.y = sin(Time.get_ticks_msec() * 0.002) * 0.1

func extract_data(amount: int) -> int:
	var actual_extracted = min(amount, current_bytes)
	current_bytes -= actual_extracted
	return actual_extracted
