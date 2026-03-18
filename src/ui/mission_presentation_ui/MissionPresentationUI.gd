extends Control

signal presentation_closed

@onready var name_label = $Panel/MarginContainer/VBoxContainer/NameLabel
@onready var description_label = $Panel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var start_button = $Panel/MarginContainer/VBoxContainer/StartButton

func _ready() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_button_pressed)

func present_mission(m_name: String, m_desc: String) -> void:
	name_label.text = m_name
	description_label.text = m_desc
	show()
	_play_victory_sfx()
	get_tree().paused = true

func _on_start_button_pressed() -> void:
	_play_click_sfx()
	hide()
	get_tree().paused = false
	presentation_closed.emit()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)

func _play_victory_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/victory.mp3", 0.0)
