extends Control

signal upgrade_purchased(upgrade_id: String)

@onready var speed_button = $Panel/MarginContainer/VBoxContainer/SpeedButton
@onready var extraction_button = $Panel/MarginContainer/VBoxContainer/ExtractionButton
@onready var capacity_button = $Panel/MarginContainer/VBoxContainer/CapacityButton
@onready var fov_button = $Panel/MarginContainer/VBoxContainer/FOVButton
@onready var genezis_count_button = $Panel/MarginContainer/VBoxContainer/GenezisCountButton
@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title

enum Mode { CORE, GENEZIS }
var current_mode: Mode = Mode.CORE

var core_node: Node3D = null

var upgrade_levels = {
	"speed": 0,
	"extraction": 0,
	"capacity": 0,
	"fov": 0,
	"genezis_count": 0
}

func _ready() -> void:
	core_node = get_tree().get_first_node_in_group("core")
	_update_buttons()

func set_mode(mode: Mode) -> void:
	current_mode = mode
	if title_label:
		match current_mode:
			Mode.CORE: title_label.text = "Core Upgrades"
			Mode.GENEZIS: title_label.text = "Genezis Upgrades"
	_update_buttons()

func _on_speed_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("speed")):
		upgrade_levels["speed"] += 1
		upgrade_purchased.emit("speed")
		_update_buttons()

func _on_extraction_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("extraction")):
		upgrade_levels["extraction"] += 1
		upgrade_purchased.emit("extraction")
		_update_buttons()

func _on_capacity_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("capacity")):
		upgrade_levels["capacity"] += 1
		upgrade_purchased.emit("capacity")
		_update_buttons()

func _on_fov_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("fov")):
		upgrade_levels["fov"] += 1
		upgrade_purchased.emit("fov")
		_update_buttons()

func _on_genezis_count_button_pressed() -> void:
	if core_node and core_node.spend_data(get_upgrade_cost("genezis_count")):
		upgrade_levels["genezis_count"] += 1
		upgrade_purchased.emit("genezis_count")
		_update_buttons()

func _update_buttons() -> void:
	if not core_node: return
	
	speed_button.visible = current_mode == Mode.GENEZIS
	extraction_button.visible = current_mode == Mode.GENEZIS
	capacity_button.visible = current_mode == Mode.GENEZIS
	fov_button.visible = current_mode == Mode.CORE
	genezis_count_button.visible = current_mode == Mode.CORE
	
	if speed_button.visible:
		speed_button.text = "Upgrade Speed (Cost: %s)" % format_bytes(get_upgrade_cost("speed"))
	if extraction_button.visible:
		extraction_button.text = "Upgrade Extraction (Cost: %s)" % format_bytes(get_upgrade_cost("extraction"))
	if capacity_button.visible:
		capacity_button.text = "Upgrade Capacity (Cost: %s)" % format_bytes(get_upgrade_cost("capacity"))
	if fov_button.visible:
		fov_button.text = "Upgrade FOV (Cost: %s)" % format_bytes(get_upgrade_cost("fov"))
	if genezis_count_button.visible:
		genezis_count_button.text = "Spawn Genezis (Cost: %s)" % format_bytes(get_upgrade_cost("genezis_count"))

func get_upgrade_cost(type: String) -> int:
	var base_cost = 0
	var multiplier = 1.5
	
	match type:
		"speed": base_cost = 50
		"extraction": base_cost = 75
		"capacity": base_cost = 60
		"fov": base_cost = 100
		"genezis_count": base_cost = 250
	
	var level = upgrade_levels.get(type, 0)
	return int(base_cost * pow(multiplier, level))

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)

func _on_close_button_pressed() -> void:
	hide()
