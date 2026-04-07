extends Control

@onready var settings_panel = $SettingsPanel
@onready var main_panel = $MainPanel
@onready var load_button = $MainPanel/VBoxContainer/LoadButton
@onready var delete_button = $MainPanel/VBoxContainer/DeleteButton
@onready var show_units_checkbox = $SettingsPanel/VBoxContainer/ShowUnitsContainer/ShowUnitsCheckbox
@onready var show_spots_checkbox = $SettingsPanel/VBoxContainer/ShowSpotsContainer/ShowSpotsCheckbox
@onready var show_enemies_checkbox = $SettingsPanel/VBoxContainer/ShowEnemiesContainer/ShowEnemiesCheckbox
@onready var show_core_checkbox = $SettingsPanel/VBoxContainer/ShowCoreContainer/ShowCoreCheckbox

func _ready() -> void:
	hide()
	process_mode = PROCESS_MODE_ALWAYS
	
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
	
	if has_node("/root/SaveManager"):
		var sm = get_node("/root/SaveManager")
		show_units_checkbox.button_pressed = sm.show_units_labels
		show_spots_checkbox.button_pressed = sm.show_spots_labels
		show_enemies_checkbox.button_pressed = sm.show_enemies_labels
		show_core_checkbox.button_pressed = sm.show_core_labels
		
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

func _on_show_units_checkbox_toggled(toggled_on: bool) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").show_units_labels = toggled_on
	_play_click_sfx()

func _on_show_spots_checkbox_toggled(toggled_on: bool) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").show_spots_labels = toggled_on
	_play_click_sfx()

func _on_show_enemies_checkbox_toggled(toggled_on: bool) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").show_enemies_labels = toggled_on
	_play_click_sfx()

func _on_show_core_checkbox_toggled(toggled_on: bool) -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").show_core_labels = toggled_on
	_play_click_sfx()

func _on_save_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
		_update_save_buttons()
		_play_click_sfx()

func _on_load_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		# Instead of just calling load_game, reload the scene to ensure clean state
		get_tree().paused = false
		get_tree().reload_current_scene()

func _on_delete_button_pressed() -> void:
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").delete_save()
		_update_save_buttons()
		_play_click_sfx()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/title_screen/TitleScreen.tscn")

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
