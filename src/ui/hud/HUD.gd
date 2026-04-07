extends CanvasLayer

@onready var cycle_label = $MarginContainer/VBoxContainer/CycleLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel
@onready var genezis_count_label = $MarginContainer/VBoxContainer/GenezisCountLabel

@onready var upgrade_menu = $UpgradeMenu
@onready var genezis_stats_ui = $GenezisStatsUI
@onready var enemy_description_ui = $EnemyDescriptionUI
@onready var mission_name_label = $MarginContainer/MissionContainer/MissionName
@onready var mission_description_label = $MarginContainer/MissionContainer/MissionDescription
@onready var mission_progress_label = $MarginContainer/MissionContainer/MissionProgress
@onready var mission_list_button = $MarginContainer/MissionContainer/MissionListButton
@onready var exit_button = $MarginContainer/MissionContainer/ExitButton
@onready var mission_list_ui = $MissionListUI
@onready var mission_presentation_ui = $MissionPresentationUI
@onready var crt_effect = $CRTEffect
@onready var pause_menu = $PauseMenu
@onready var save_spinner = $SaveSpinner
@onready var save_delta_label = $SaveDelta

@onready var theophania_ui_scene = preload("res://src/ui/theophania_ui/TheophaniaUI.tscn")

var selected_genezis: CharacterBody3D = null

func _ready() -> void:
	add_to_group("hud")
	# Connect to Core signals
	var core = get_tree().get_first_node_in_group("core")
	if core:
		core.selected.connect(_on_core_selected)
	
	# Connect to TimeManager signals
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_updated.connect(_on_time_updated)
		time_manager.cycle_started.connect(_on_cycle_started)
		if not time_manager.theophania_requested.is_connected(_on_theophania_requested):
			time_manager.theophania_requested.connect(_on_theophania_requested)
		_on_cycle_started(time_manager.current_cycle)
	
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
		# Fallback to searching the tree if group is not populated yet
		mission_manager = get_tree().root.find_child("MissionManager", true, false)
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
	
	if mission_list_button:
		mission_list_button.pressed.connect(_on_mission_list_button_pressed)
	
	if exit_button:
		exit_button.pressed.connect(_on_exit_button_pressed)
	
	# Connect to SaveManager
	if SaveManager:
		SaveManager.save_started.connect(_on_save_started)
		SaveManager.save_finished.connect(_on_save_finished)
	
	if save_spinner:
		save_spinner.hide()
	
	if save_delta_label:
		save_delta_label.hide()
	
	# Initial count
	_update_genezis_count()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		if pause_menu:
			pause_menu.toggle()
			get_viewport().set_input_as_handled()
			return

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
		genezis_count_label.text = tr("GENEZIS: %D G1, %D G2") % [count, g2_count]
	else:
		genezis_count_label.text = tr("GENEZIS G1: %D") % count
	
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

func _on_theophania_requested() -> void:
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if not world_manager: return
	
	var scenario = world_manager.get_next_theophania_scenario()
	if scenario.is_empty(): return
	
	if theophania_ui_scene:
		var theophania_ui = theophania_ui_scene.instantiate()
		add_child(theophania_ui)
		theophania_ui.setup_scenario(scenario)
		theophania_ui.choice_made.connect(world_manager.apply_theophania_choice)
		
		get_tree().paused = true
		theophania_ui.tree_exited.connect(func(): get_tree().paused = false)

func _on_time_updated(remaining: float) -> void:
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = tr("SYNC: %02D:%02D") % [minutes, seconds]

func _on_cycle_started(number: int) -> void:
	cycle_label.text = tr("CYCLE: %S") % str(number)
	var hardware_manager = get_tree().get_first_node_in_group("hardware_manager")
	if hardware_manager and hardware_manager.has_method("get_hertz_display"):
		cycle_label.text += " (" + hardware_manager.get_hertz_display() + ")"
	else:
		var time_manager = get_tree().get_first_node_in_group("time_manager")
		if time_manager:
			cycle_label.text += " (" + time_manager.get_hertz_display() + ")"

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

func _on_exit_button_pressed() -> void:
	_play_click_sfx()
	if SaveManager:
		SaveManager.save_game()
	
	# Try to find the camera and trigger zoom-out transition
	var camera = get_tree().get_first_node_in_group("main_camera")
	if not camera:
		camera = get_viewport().get_camera_3d()
	
	if camera and camera.has_method("zoom_out_and_exit"):
		camera.zoom_out_and_exit()
	else:
		# Fallback if no camera or method found
		get_tree().change_scene_to_file("res://src/core/godheads/GodheadsWorld.tscn")

func _on_save_started() -> void:
	if save_spinner:
		var anim = save_spinner.get_node_or_null("AnimationPlayer")
		if anim:
			anim.play("spin")
		
		# Ensure it's not hidden by other UI elements by raising it to the top of the HUD
		save_spinner.get_parent().move_child(save_spinner, -1)
		
		# Let's use a Tween for fade to allow simultaneous rotation.
		var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		save_spinner.modulate.a = 0.0
		save_spinner.show()
		# Increase target opacity to 1.0 for better visibility
		tween.tween_property(save_spinner, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE)

func _on_save_finished(bytes: int) -> void:
	if save_spinner:
		# Wait for at least 0.5s total before fading out to ensure visibility
		# even for near-instant save processes.
		get_tree().create_timer(0.5, true).timeout.connect(func():
			var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			tween.tween_property(save_spinner, "modulate:a", 0.0, 0.1).set_trans(Tween.TRANS_SINE)
			tween.finished.connect(func(): 
				save_spinner.hide()
				var anim = save_spinner.get_node_or_null("AnimationPlayer")
				if anim:
					anim.stop()
			)
		)
	
	if save_delta_label:
		# Show delta 0.5 seconds after saving is complete
		get_tree().create_timer(0.5, true).timeout.connect(func():
			save_delta_label.text = tr("SAVED: %S") % format_bytes(bytes)
			save_delta_label.modulate.a = 0.0
			save_delta_label.show()
			
			var delta_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			delta_tween.tween_property(save_delta_label, "modulate:a", 1.0, 0.2).set_trans(Tween.TRANS_SINE)
			delta_tween.tween_interval(2.0)
			delta_tween.tween_property(save_delta_label, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
			delta_tween.finished.connect(func(): save_delta_label.hide())
		)

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576: # 1024 * 1024
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1073741824: # 1024 * 1024 * 1024
		return "%.2f MB" % (bytes / 1048576.0)
	else:
		return "%.2f GB" % (bytes / 1073741824.0)
