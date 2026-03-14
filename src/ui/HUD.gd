extends Control

@onready var data_label = $MarginContainer/VBoxContainer/DataLabel
@onready var iteration_label = $MarginContainer/VBoxContainer/IterationLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel
@onready var genezis_count_label = $MarginContainer/VBoxContainer/GenezisCountLabel

@onready var upgrade_menu = $UpgradeMenu
@onready var genezis_stats_ui = $GenezisStatsUI

var selected_genezis: CharacterBody3D = null

func _ready() -> void:
	# Connect to Core signals
	var core = get_tree().get_first_node_in_group("core")
	if core:
		core.data_changed.connect(_on_data_changed)
		core.selected.connect(_on_core_selected)
		_on_data_changed(core.current_data)
	
	# Connect to TimeManager signals
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_updated.connect(_on_time_updated)
		time_manager.iteration_started.connect(_on_iteration_started)
		_on_iteration_started(time_manager.current_iteration)
	
	if upgrade_menu:
		upgrade_menu.upgrade_purchased.connect(_on_upgrade_purchased)
	
	# Connect to WorldManager for genezis spawning
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager:
		world_manager.genezis_spawned.connect(_on_genezis_spawned)
		world_manager.genezis_g2_spawned.connect(_on_genezis_g2_spawned)
	
	# Initial count
	_update_genezis_count()

func _unhandled_input(event: InputEvent) -> void:
	# Close menus if clicking on empty space
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# If the click was not handled by any entity (which calls set_input_as_handled)
			# and it's not over some UI element, we can hide the menus
			if genezis_stats_ui and genezis_stats_ui.visible:
				genezis_stats_ui.hide()
				selected_genezis = null
			if upgrade_menu and upgrade_menu.visible:
				upgrade_menu.hide()

func _on_core_selected() -> void:
	if genezis_stats_ui:
		genezis_stats_ui.hide()
		selected_genezis = null
	if upgrade_menu:
		upgrade_menu.set_mode(upgrade_menu.Mode.CORE)
		upgrade_menu.show()

func _on_upgrade_purchased(upgrade_id: String) -> void:
	# Inform all Genezis beings or Core about the upgrade
	match upgrade_id:
		"speed":
			get_tree().call_group("genezis", "upgrade_speed", 1.2)
		"extraction":
			get_tree().call_group("genezis", "upgrade_extraction", 1.2)
		"capacity":
			get_tree().call_group("genezis", "upgrade_capacity", 1.2)
		"fov":
			var core = get_tree().get_first_node_in_group("core")
			if core:
				core.fov_radius += 5.0
		"genezis_count":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.spawn_extra_genezis()
		"fusion":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.fuse_genezis()
	
	# Refresh UI if a Genezis is selected
	if selected_genezis and is_instance_valid(selected_genezis):
		genezis_stats_ui.display_stats(selected_genezis.get_stats())

func _update_genezis_count() -> void:
	var count = get_tree().get_nodes_in_group("genezis").size()
	var g2_count = get_tree().get_nodes_in_group("genezis_g2").size()
	
	if g2_count > 0:
		genezis_count_label.text = "Genezis: %d G1, %d G2" % [count, g2_count]
	else:
		genezis_count_label.text = "Genezis: %d" % count
	
	# Re-connect signals for all Genezis beings to ensure new ones are included
	for genezis in get_tree().get_nodes_in_group("genezis"):
		if not genezis.selected.is_connected(_on_genezis_selected):
			genezis.selected.connect(_on_genezis_selected)
			
	for g2 in get_tree().get_nodes_in_group("genezis_g2"):
		if not g2.selected.is_connected(_on_genezis_g2_selected):
			g2.selected.connect(_on_genezis_g2_selected)

func _on_genezis_spawned(_genezis: CharacterBody3D) -> void:
	_update_genezis_count()

func _on_genezis_g2_spawned(_genezis: CharacterBody3D) -> void:
	_update_genezis_count()

func _on_genezis_selected(genezis: CharacterBody3D) -> void:
	selected_genezis = genezis
	if genezis_stats_ui:
		genezis_stats_ui.display_stats(genezis.get_stats())
	if upgrade_menu:
		upgrade_menu.set_mode(upgrade_menu.Mode.GENEZIS)
		upgrade_menu.show()

func _on_genezis_g2_selected(genezis: CharacterBody3D) -> void:
	selected_genezis = genezis
	if genezis_stats_ui:
		genezis_stats_ui.display_stats(genezis.get_stats())
	# G2 might have its own upgrade mode later, but for now Core mode is fine or just hide menu
	if upgrade_menu:
		upgrade_menu.hide()

func _on_data_changed(amount: int) -> void:
	data_label.text = "Data: " + format_bytes(amount)

func _on_time_updated(remaining: float) -> void:
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "Next Sync: %02d:%02d" % [minutes, seconds]

func _on_iteration_started(number: int) -> void:
	iteration_label.text = str(number) + " Hz"

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576: # 1024 * 1024
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1073741824: # 1024 * 1024 * 1024
		return "%.2f MB" % (bytes / 1048576.0)
	else:
		return "%.2f GB" % (bytes / 1073741824.0)
