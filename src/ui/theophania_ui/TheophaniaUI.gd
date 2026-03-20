extends Control

signal choice_made(choice_id: String)

@onready var description_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var options_container: HBoxContainer = $DialoguePanel/MarginContainer/VBoxContainer/OptionsContainer

var current_scenario: Dictionary = {}

func _ready() -> void:
	# Add a slight animation or sound when appearing
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/victory.mp3", -10.0)

func setup_scenario(scenario: Dictionary) -> void:
	current_scenario = scenario
	description_label.text = scenario.description
	
	# Clear existing options
	for child in options_container.get_children():
		child.queue_free()
	
	# Add new options
	for choice in scenario.choices:
		var button = Button.new()
		button.text = choice.text
		button.pressed.connect(_on_choice_selected.bind(choice.id))
		options_container.add_child(button)
		
		# Set button style or minimum size if needed
		button.custom_minimum_size = Vector2(150, 40)

func _on_choice_selected(choice_id: String) -> void:
	choice_made.emit(choice_id)
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3")
	
	queue_free()
