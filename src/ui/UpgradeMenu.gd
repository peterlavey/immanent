extends Control

signal upgrade_purchased(upgrade_id: String)

@onready var speed_button = $Panel/MarginContainer/VBoxContainer/SpeedButton
@onready var extraction_button = $Panel/MarginContainer/VBoxContainer/ExtractionButton
@onready var capacity_button = $Panel/MarginContainer/VBoxContainer/CapacityButton
@onready var fov_button = $Panel/MarginContainer/VBoxContainer/FOVButton
@onready var genezis_count_button = $Panel/MarginContainer/VBoxContainer/GenezisCountButton
@onready var fusion_button = Button.new()
@onready var evolution_button = Button.new()
@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title

enum Mode { CORE, GENEZIS }
var current_mode: Mode = Mode.CORE

const INITIAL_MAX_LEVEL = 5
const EVOLVED_MAX_LEVEL = 10

var core_node: Node3D = null

var upgrade_levels = {
	"speed": 0,
	"extraction": 0,
	"capacity": 0,
	"fov": 0,
	"genezis_count": 0,
	"evolution": 0,
	"fusion": 0
}

func _ready() -> void:
	core_node = get_tree().get_first_node_in_group("core")
	if core_node:
		core_node.data_changed.connect(_on_core_data_changed)
	
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager:
		world_manager.genezis_spawned.connect(_on_genezis_population_changed)
		world_manager.genezis_removed.connect(_on_genezis_population_changed)
	
	# Setup evolution button
	evolution_button.text = "Evolve Core"
	evolution_button.pressed.connect(_on_evolution_button_pressed)
	$Panel/MarginContainer/VBoxContainer.add_child(evolution_button)
	$Panel/MarginContainer/VBoxContainer.move_child(evolution_button, $Panel/MarginContainer/VBoxContainer.get_child_count() - 3) # Above spacer
	
	# Setup fusion button
	fusion_button.text = "Fuse Genezis (4 G1 -> 1 G2)"
	fusion_button.pressed.connect(_on_fusion_button_pressed)
	$Panel/MarginContainer/VBoxContainer.add_child(fusion_button)
	$Panel/MarginContainer/VBoxContainer.move_child(fusion_button, $Panel/MarginContainer/VBoxContainer.get_child_count() - 3)
	
	_update_buttons()

func set_mode(mode: Mode) -> void:
	current_mode = mode
	if title_label:
		match current_mode:
			Mode.CORE: title_label.text = "Core Upgrades"
			Mode.GENEZIS: title_label.text = "Genezis Upgrades"
	_update_buttons()

func _on_speed_button_pressed() -> void:
	if upgrade_levels["speed"] >= get_max_level(): return
	if core_node and core_node.spend_data(get_upgrade_cost("speed")):
		upgrade_levels["speed"] += 1
		upgrade_purchased.emit("speed")
		_update_buttons()

func _on_extraction_button_pressed() -> void:
	if upgrade_levels["extraction"] >= get_max_level(): return
	if core_node and core_node.spend_data(get_upgrade_cost("extraction")):
		upgrade_levels["extraction"] += 1
		upgrade_purchased.emit("extraction")
		_update_buttons()

func _on_capacity_button_pressed() -> void:
	if upgrade_levels["capacity"] >= get_max_level(): return
	if core_node and core_node.spend_data(get_upgrade_cost("capacity")):
		upgrade_levels["capacity"] += 1
		upgrade_purchased.emit("capacity")
		_update_buttons()

func _on_fov_button_pressed() -> void:
	if upgrade_levels["fov"] >= get_max_level(): return
	if core_node and core_node.spend_data(get_upgrade_cost("fov")):
		upgrade_levels["fov"] += 1
		upgrade_purchased.emit("fov")
		_update_buttons()

func _on_genezis_count_button_pressed() -> void:
	var g1_count = get_tree().get_nodes_in_group("genezis").size()
	if g1_count >= (1 + get_max_level()): return
	if core_node and core_node.spend_data(get_upgrade_cost("genezis_count")):
		upgrade_purchased.emit("genezis_count")
		_update_buttons()

func _on_evolution_button_pressed() -> void:
	if upgrade_levels["evolution"] >= 1: return # Limit to 1 evolution for now
	if core_node and core_node.spend_data(get_upgrade_cost("evolution")):
		upgrade_levels["evolution"] += 1
		core_node.evolution_level = upgrade_levels["evolution"]
		upgrade_purchased.emit("evolution")
		_update_buttons()

func _on_fusion_button_pressed() -> void:
	var g1_count = get_tree().get_nodes_in_group("genezis").size()
	if g1_count < 5: return
	
	if core_node and core_node.spend_data(get_upgrade_cost("fusion")):
		upgrade_purchased.emit("fusion")
		_update_buttons()

func _update_buttons() -> void:
	if not core_node: return
	
	speed_button.visible = current_mode == Mode.GENEZIS
	extraction_button.visible = current_mode == Mode.GENEZIS
	capacity_button.visible = current_mode == Mode.GENEZIS
	fov_button.visible = current_mode == Mode.CORE
	genezis_count_button.visible = current_mode == Mode.CORE
	evolution_button.visible = current_mode == Mode.CORE
	fusion_button.visible = current_mode == Mode.CORE
	
	_update_button_text(speed_button, "speed", "Upgrade Speed")
	_update_button_text(extraction_button, "extraction", "Upgrade Extraction")
	_update_button_text(capacity_button, "capacity", "Upgrade Capacity")
	_update_button_text(fov_button, "fov", "Upgrade FOV")
	_update_button_text(genezis_count_button, "genezis_count", "Spawn Genezis")
	_update_button_text(evolution_button, "evolution", "Evolve Core")
	_update_button_text(fusion_button, "fusion", "Fuse Genezis")

func _on_core_data_changed(_new_data: int) -> void:
	_update_buttons()

func _on_genezis_population_changed(_genezis = null) -> void:
	_update_buttons()

func _update_button_text(button: Button, type: String, label: String) -> void:
	if not button.visible: return
	
	var level = upgrade_levels[type]
	if type == "genezis_count":
		level = max(0, get_tree().get_nodes_in_group("genezis").size() - 1)
		
	var max_level = get_max_level()
	if type == "evolution":
		max_level = 1 # Only one evolution stage for now
		
	if level >= max_level:
		button.text = "%s (MAXED)" % label
		button.disabled = true
	else:
		var cost = get_upgrade_cost(type)
		button.text = "%s (Cost: %s)" % [label, format_bytes(cost)]
		
		var can_afford = core_node.current_data >= cost
		var requirements_met = true
		if type == "fusion":
			var g1_count = get_tree().get_nodes_in_group("genezis").size()
			requirements_met = g1_count >= 5
			if not requirements_met:
				button.text = "%s (Requires 5 G1)" % label
		
		button.disabled = not (can_afford and requirements_met)

func get_max_level() -> int:
	if upgrade_levels["evolution"] > 0:
		return EVOLVED_MAX_LEVEL
	return INITIAL_MAX_LEVEL

func get_upgrade_cost(type: String) -> int:
	var base_cost = 0
	var multiplier = 1.5
	
	match type:
		"speed": base_cost = 50
		"extraction": base_cost = 75
		"capacity": base_cost = 60
		"fov": base_cost = 100
		"genezis_count": base_cost = 250
		"evolution": base_cost = 1048576 # 1 MB to evolve
		"fusion": base_cost = 524288 # 512 KB to fuse
	
	var level = upgrade_levels.get(type, 0)
	if type == "genezis_count":
		level = max(0, get_tree().get_nodes_in_group("genezis").size() - 1)
		
	if type == "fusion":
		# Fusion cost also depends on how many G2s we already have? 
		# For now just use base_cost * multiplier^level
		pass
		
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
