extends Control

@onready var data_label = $MarginContainer/VBoxContainer/DataLabel
@onready var iteration_label = $MarginContainer/VBoxContainer/IterationLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel
@onready var genezis_count_label = $MarginContainer/VBoxContainer/GenezisCountLabel

@onready var upgrade_menu = $UpgradeMenu
@onready var genezis_stats_ui = $GenezisStatsUI
@onready var enemy_description_ui = $EnemyDescriptionUI
@onready var mission_name_label = $MarginContainer/MissionContainer/MissionName
@onready var mission_description_label = $MarginContainer/MissionContainer/MissionDescription
@onready var mission_progress_label = $MarginContainer/MissionContainer/MissionProgress
@onready var mission_list_button = $MarginContainer/MissionContainer/MissionListButton
@onready var mission_list_ui = $MissionListUI
@onready var mission_presentation_ui = $MissionPresentationUI

@onready var save_button = $MarginContainer/SaveLoadContainer/SaveButton
@onready var load_button = $MarginContainer/SaveLoadContainer/LoadButton
@onready var delete_button = $MarginContainer/SaveLoadContainer/DeleteButton

var selected_genezis: CharacterBody3D = null

func _ready() -> void:
	add_to_group("hud")
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
		world_manager.new_enemy_type_spawned.connect(_on_new_enemy_type_spawned)
	
	# Connect to MissionManager
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if not mission_manager:
		mission_manager = get_parent().get_node_or_null("MissionManager")
		
	if mission_manager:
		if not mission_manager.mission_updated.is_connected(_on_mission_updated):
			mission_manager.mission_updated.connect(_on_mission_updated)
		
		if not mission_manager.mission_presented.is_connected(_on_mission_presented):
			mission_manager.mission_presented.connect(_on_mission_presented)
		
		# Initialize mission display with the latest data from the manager
		_on_mission_updated(
			mission_manager.current_mission_name, 
			mission_manager.current_mission_description, 
			mission_manager.current_mission_progress
		)
		print("HUD: Connected to MissionManager")
	else:
		printerr("HUD: MissionManager not found in group or at parent level")
	
	if save_button:
		save_button.pressed.connect(_on_save_button_pressed)
	if load_button:
		load_button.pressed.connect(_on_load_button_pressed)
		# Only enable load button if save file exists
		load_button.disabled = not FileAccess.file_exists("user://savegame.json")
	
	if delete_button:
		delete_button.pressed.connect(_on_delete_button_pressed)
		delete_button.disabled = not FileAccess.file_exists("user://savegame.json")
	
	if mission_list_button:
		mission_list_button.pressed.connect(_on_mission_list_button_pressed)
	
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
			get_tree().call_group("genezis_g1", "upgrade_speed", 1.2)
		"extraction":
			get_tree().call_group("genezis_g1", "upgrade_extraction", 1.2)
		"capacity":
			get_tree().call_group("genezis_g1", "upgrade_capacity", 1.2)
		"fov":
			var core = get_tree().get_first_node_in_group("core")
			if core:
				core.fov_radius += 5.0
		"genezis_count":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.spawn_extra_genezis_g1()
		"genezis_g0_count":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.spawn_extra_genezis_g0()
		"fusion":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.fuse_genezis()
		"psinergy":
			var level = upgrade_menu.upgrade_levels.get("psinergy", 0)
			get_tree().call_group("genezis_g1", "upgrade_psinergy", level)
	
	# Refresh UI if a Genezis G1 is selected
	if selected_genezis and is_instance_valid(selected_genezis):
		genezis_stats_ui.display_stats(selected_genezis.get_stats())

func _update_genezis_count() -> void:
	var count = get_tree().get_nodes_in_group("genezis_g1").size()
	var g2_count = get_tree().get_nodes_in_group("genezis_g2").size()
	
	if g2_count > 0:
		genezis_count_label.text = "Genezis: %d G1, %d G2" % [count, g2_count]
	else:
		genezis_count_label.text = "Genezis G1: %d" % count
	
	# Re-connect signals for all Genezis beings to ensure new ones are included
	for genezis in get_tree().get_nodes_in_group("genezis_g1"):
		if not genezis.selected.is_connected(_on_genezis_selected):
			genezis.selected.connect(_on_genezis_selected)
			
	for g2 in get_tree().get_nodes_in_group("genezis_g2"):
		if not g2.selected.is_connected(_on_genezis_g2_selected):
			g2.selected.connect(_on_genezis_g2_selected)

func _on_genezis_spawned(_genezis: CharacterBody3D) -> void:
	_update_genezis_count()

func _on_genezis_g2_spawned(_genezis: CharacterBody3D) -> void:
	_update_genezis_count()

func _on_new_enemy_type_spawned(type_name: String) -> void:
	# Hide all other menus to avoid overlapping and blocking input
	if upgrade_menu:
		upgrade_menu.hide()
	if genezis_stats_ui:
		genezis_stats_ui.hide()
	
	if enemy_description_ui:
		enemy_description_ui.show_enemy_description(type_name)

func _on_genezis_selected(genezis: CharacterBody3D) -> void:
	selected_genezis = genezis
	if genezis_stats_ui:
		genezis_stats_ui.display_stats(genezis.get_stats())
	if upgrade_menu:
		upgrade_menu.set_mode(upgrade_menu.Mode.GENEZIS_G1)
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

func _on_mission_updated(m_name: String, m_desc: String, m_prog: String) -> void:
	mission_name_label.text = m_name
	mission_description_label.text = m_desc
	mission_progress_label.text = m_prog

func _on_mission_presented(m_name: String, m_desc: String) -> void:
	# Hide all other menus to avoid overlapping
	if upgrade_menu:
		upgrade_menu.hide()
	if genezis_stats_ui:
		genezis_stats_ui.hide()
	if mission_list_ui:
		mission_list_ui.hide()
	
	if mission_presentation_ui:
		mission_presentation_ui.present_mission(m_name, m_desc)

func _on_mission_list_button_pressed() -> void:
	# Hide all other menus to avoid overlapping and blocking input
	if upgrade_menu:
		upgrade_menu.hide()
	if genezis_stats_ui:
		genezis_stats_ui.hide()
	
	if mission_list_ui:
		mission_list_ui.show_missions()
		_play_click_sfx()

func _on_save_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
		if load_button:
			load_button.disabled = false
		if delete_button:
			delete_button.disabled = false
		_play_click_sfx()

func _on_load_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		if get_node("/root/SaveManager").load_game():
			# Close menus after load
			if upgrade_menu: upgrade_menu.hide()
			if genezis_stats_ui: genezis_stats_ui.hide()
			_play_click_sfx()

func _on_delete_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").delete_save()
		if load_button:
			load_button.disabled = true
		if delete_button:
			delete_button.disabled = true
		_play_click_sfx()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/G1.mp3", -10.0)

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576: # 1024 * 1024
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1073741824: # 1024 * 1024 * 1024
		return "%.2f MB" % (bytes / 1048576.0)
	else:
		return "%.2f GB" % (bytes / 1073741824.0)
