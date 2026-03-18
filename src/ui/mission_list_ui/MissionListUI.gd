extends Control

signal closed

@onready var mission_list = $Panel/MarginContainer/VBoxContainer/ScrollContainer/MissionList
@onready var close_button = $Panel/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func show_missions() -> void:
	# Clear existing
	for child in mission_list.get_children():
		child.queue_free()
	
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if not mission_manager:
		return
		
	var missions = mission_manager.get_all_missions_status()
	
	for mission in missions:
		var container = VBoxContainer.new()
		
		var name_label = Label.new()
		name_label.text = mission["name"]
		
		var desc_label = Label.new()
		desc_label.text = mission["description"]
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.add_theme_font_size_override("font_size", 14)
		
		match mission["status"]:
			"completed":
				name_label.text = "[DONE] " + name_label.text
				name_label.add_theme_color_override("font_color", Color.GREEN)
				desc_label.add_theme_color_override("font_color", Color.GRAY)
			"current":
				name_label.text = ">>> " + name_label.text
				name_label.add_theme_color_override("font_color", Color.YELLOW)
				
				if mission["progress"] != "":
					var prog_label = Label.new()
					prog_label.text = "Progress: " + mission["progress"]
					prog_label.add_theme_color_override("font_color", Color.CYAN)
					prog_label.add_theme_font_size_override("font_size", 12)
					container.add_child(prog_label)
			"locked":
				name_label.add_theme_color_override("font_color", Color.DARK_GRAY)
				desc_label.add_theme_color_override("font_color", Color.DARK_GRAY)
				desc_label.text = "???"
		
		container.add_child(name_label)
		container.add_child(desc_label)
		
		# Add a separator
		var sep = HSeparator.new()
		container.add_child(sep)
		
		mission_list.add_child(container)
	
	show()
	get_tree().paused = true

func _on_close_button_pressed() -> void:
	_play_click_sfx()
	hide()
	get_tree().paused = false
	closed.emit()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
