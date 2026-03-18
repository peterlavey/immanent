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
	get_tree().paused = true

func _on_start_button_pressed() -> void:
	hide()
	get_tree().paused = false
	presentation_closed.emit()
