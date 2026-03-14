extends Control

signal upgrade_purchased(upgrade_id: String)

@onready var speed_button = $Panel/MarginContainer/VBoxContainer/SpeedButton
@onready var extraction_button = $Panel/MarginContainer/VBoxContainer/ExtractionButton
@onready var capacity_button = $Panel/MarginContainer/VBoxContainer/CapacityButton
@onready var fov_button = $Panel/MarginContainer/VBoxContainer/FOVButton
@onready var genezis_count_button = $Panel/MarginContainer/VBoxContainer/GenezisCountButton

var core_node: Node3D = null

func _ready() -> void:
	core_node = get_tree().get_first_node_in_group("core")
	_update_buttons()

func _on_speed_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("speed")):
		upgrade_purchased.emit("speed")
		_update_buttons()

func _on_extraction_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("extraction")):
		upgrade_purchased.emit("extraction")
		_update_buttons()

func _on_capacity_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("capacity")):
		upgrade_purchased.emit("capacity")
		_update_buttons()

func _on_fov_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("fov")):
		upgrade_purchased.emit("fov")
		_update_buttons()

func _on_genezis_count_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("genezis_count")):
		upgrade_purchased.emit("genezis_count")
		_update_buttons()

func _update_buttons() -> void:
	if not core_node: return
	
	speed_button.text = "Upgrade Speed (Cost: %s)" % format_bytes(get_upgrade_cost("speed"))
	extraction_button.text = "Upgrade Extraction (Cost: %s)" % format_bytes(get_upgrade_cost("extraction"))
	capacity_button.text = "Upgrade Capacity (Cost: %s)" % format_bytes(get_upgrade_cost("capacity"))
	fov_button.text = "Upgrade FOV (Cost: %s)" % format_bytes(get_upgrade_cost("fov"))
	genezis_count_button.text = "Spawn Genezis (Cost: %s)" % format_bytes(get_upgrade_cost("genezis_count"))

func get_upgrade_cost(type: String) -> int:
	# Placeholder cost logic, could be more complex later
	match type:
		"speed": return 10 * 1024 * 1024 # 10 MB
		"extraction": return 15 * 1024 * 1024 # 15 MB
		"capacity": return 12 * 1024 * 1024 # 12 MB
		"fov": return 20 * 1024 * 1024 # 20 MB
		"genezis_count": return 50 * 1024 * 1024 # 50 MB
	return 0

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / (1024.0 * 1024.0))

func _on_close_button_pressed() -> void:
	hide()
