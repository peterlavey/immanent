extends Control

@onready var settings_panel = $SettingsPanel
@onready var main_panel = $MainPanel
@onready var crt_toggle = $SettingsPanel/VBoxContainer/CRTToggle
@onready var load_button = $MainPanel/VBoxContainer/LoadButton
@onready var delete_button = $MainPanel/VBoxContainer/DeleteButton

signal crt_toggled(pressed: bool)

func _ready() -> void:
	hide()
	process_mode = PROCESS_MODE_ALWAYS
	
	# Initial state for CRT toggle
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_node("CRTEffect"):
		crt_toggle.button_pressed = hud.get_node("CRTEffect").visible
	
	# Initial state for Save/Load buttons
	_update_save_buttons()

func _update_save_buttons() -> void:
	var save_exists = FileAccess.file_exists("user://savegame.json")
	if load_button:
		load_button.disabled = not save_exists
	if delete_button:
		delete_button.disabled = not save_exists

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func open() -> void:
	show()
	main_panel.show()
	settings_panel.hide()
	get_tree().paused = true
	_update_save_buttons()
	_play_click_sfx()

func close() -> void:
	hide()
	get_tree().paused = false
	_play_click_sfx()

func _on_resume_button_pressed() -> void:
	close()

func _on_settings_button_pressed() -> void:
	main_panel.hide()
	settings_panel.show()
	_play_click_sfx()

func _on_settings_back_button_pressed() -> void:
	settings_panel.hide()
	main_panel.show()
	_play_click_sfx()

func _on_crt_toggle_toggled(button_pressed: bool) -> void:
	crt_toggled.emit(button_pressed)
	_play_click_sfx()

func _on_save_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
		_update_save_buttons()
		_play_click_sfx()

func _on_load_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		if get_node("/root/SaveManager").load_game():
			close()

func _on_delete_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").delete_save()
		_update_save_buttons()
		_play_click_sfx()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
