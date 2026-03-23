extends Control

@onready var continue_button = $MenuContainer/VBoxContainer/ContinueButton
@onready var settings_panel = $SettingsPanel
@onready var menu_container = $MenuContainer
@onready var crt_effect = $CRTEffect

func _ready() -> void:
	# Initializing nodes with safety checks
	continue_button = get_node_or_null("MenuContainer/VBoxContainer/ContinueButton")
	settings_panel = get_node_or_null("SettingsPanel")
	menu_container = get_node_or_null("MenuContainer")
	crt_effect = get_node_or_null("CRTEffect")

	# Check for save file existence to enable/disable Continue button
	var save_exists = FileAccess.file_exists("user://savegame.json")
	if continue_button:
		continue_button.disabled = not save_exists
	
	# Initial settings sync
	var crt_toggle_node = get_node_or_null("SettingsPanel/VBoxContainer/CRTToggle")
	if crt_effect and crt_toggle_node:
		_sync_crt_deferred(crt_toggle_node)
	
	if settings_panel:
		settings_panel.hide()

func _sync_crt_deferred(crt_toggle_node: Node) -> void:
	await get_tree().process_frame
	if not is_inside_tree() or not is_instance_valid(crt_toggle_node): return
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and is_instance_valid(hud) and hud.has_node("CRTEffect"):
		var hud_crt = hud.get_node("CRTEffect")
		crt_toggle_node.button_pressed = hud_crt.visible
		crt_effect.visible = hud_crt.visible
	else:
		crt_effect.visible = crt_toggle_node.button_pressed

func _on_continue_button_pressed() -> void:
	_play_click_sfx()
	if SaveManager:
		SaveManager.load_game()
	
	var err = get_tree().change_scene_to_file("res://src/core/godheads/GodheadsWorld.tscn")
	if err != OK:
		printerr("[TitleScreen] Failed to change scene to GodheadsWorld.tscn: ", err)
		return

func _on_new_game_button_pressed() -> void:
	_play_click_sfx()
	if SaveManager:
		SaveManager.delete_save()
	
	var err = get_tree().change_scene_to_file("res://src/core/godheads/GodheadsWorld.tscn")
	if err != OK:
		printerr("[TitleScreen] Failed to change scene to GodheadsWorld.tscn: ", err)

func _on_settings_button_pressed() -> void:
	_play_click_sfx()
	menu_container.hide()
	settings_panel.show()

func _on_exit_button_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()

func _on_settings_back_button_pressed() -> void:
	_play_click_sfx()
	settings_panel.hide()
	menu_container.show()

func _on_crt_toggle_toggled(button_pressed: bool) -> void:
	_play_click_sfx()
	if crt_effect:
		crt_effect.visible = button_pressed
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and is_instance_valid(hud) and hud.has_node("CRTEffect"):
		hud.get_node("CRTEffect").visible = button_pressed

func _play_click_sfx() -> void:
	var audio_manager_node = get_tree().root.get_node_or_null("AudioManager")
	if is_instance_valid(audio_manager_node) and audio_manager_node.has_method("play_sfx"):
		audio_manager_node.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
