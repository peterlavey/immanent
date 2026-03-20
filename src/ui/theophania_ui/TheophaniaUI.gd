extends Control

signal choice_made(choice_id: String)

@onready var description_label: Label = $DialoguePanel/MarginContainer/VBoxContainer/DescriptionLabel
@onready var options_container: HBoxContainer = $DialoguePanel/MarginContainer/VBoxContainer/OptionsContainer
@onready var scanline_overlay: ColorRect = $G1Camera/ScanlineOverlay

var current_scenario: Dictionary = {}
var typing_speed: float = 0.03
var is_typing: bool = false
var full_text: String = ""

func _ready() -> void:
	# Add a slight animation or sound when appearing
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/victory.mp3", -10.0)
	
	# Initial state
	options_container.modulate.a = 0.0
	scanline_overlay.show()

func _process(delta: float) -> void:
	# Subtle flicker for the scanline overlay
	if scanline_overlay.visible:
		scanline_overlay.color.a = randf_range(0.03, 0.08)

func setup_scenario(scenario: Dictionary) -> void:
	current_scenario = scenario
	full_text = scenario.description
	description_label.text = ""
	
	# Clear existing options
	for child in options_container.get_children():
		child.queue_free()
	
	# Add new options (but keep them hidden initially)
	for choice in scenario.choices:
		var button = Button.new()
		button.text = choice.text
		button.pressed.connect(_on_choice_selected.bind(choice.id))
		options_container.add_child(button)
		button.custom_minimum_size = Vector2(180, 45)
		button.disabled = true
	
	start_typing()

func start_typing() -> void:
	is_typing = true
	description_label.text = ""
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	
	for i in range(full_text.length()):
		if not is_inside_tree(): return
		await get_tree().create_timer(typing_speed).timeout
		if not is_inside_tree(): return
		description_label.text += full_text[i]
		
		# Play a subtle typing sound
		if audio_manager and i % 2 == 0:
			audio_manager.play_sfx("res://assets/audio/sfx/G1.mp3", -25.0)
	
	is_typing = false
	show_options()

func show_options() -> void:
	if not is_inside_tree(): return
	var tween = create_tween()
	tween.tween_property(options_container, "modulate:a", 1.0, 0.5)
	
	for child in options_container.get_children():
		if child is Button:
			child.disabled = false

func _on_choice_selected(choice_id: String) -> void:
	choice_made.emit(choice_id)
	
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3")
	
	queue_free()

func _exit_tree() -> void:
	# Ensure game is unpaused when UI is destroyed
	# (Though HUD.gd handles this too, it's good to be safe)
	pass
