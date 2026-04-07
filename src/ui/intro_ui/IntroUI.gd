extends Control

signal intro_finished

@onready var texture_rect = $Background/TextureRect
@onready var label = $Background/MarginContainer/VBoxContainer/Label
@onready var typing_timer = $TypingTimer
@onready var black_screen = $BlackScreen
@onready var year_label = $BlackScreen/CenterContainer/VBoxContainer/YearLabel
@onready var world_label = $BlackScreen/CenterContainer/VBoxContainer/WorldLabel

var intro_steps = [
	{
		"texture": preload("res://assets/textures/intro-1.png"),
		"text_key": "INTRO_STEP_1"
	},
	{
		"texture": preload("res://assets/textures/intro-2.png"),
		"text_key": "INTRO_STEP_2"
	}
]

var current_step = 0
var displayed_text = ""
var full_text = ""
var char_index = 0
var is_typing = false
var intro_started = false
var is_black_screen = false

func _ready():
	process_mode = PROCESS_MODE_ALWAYS
	$BaseBackground.modulate.a = 0
	black_screen.modulate.a = 0
	$Background.modulate.a = 0
	
	# Ensure we stay on top
	z_index = 100
	
	# Delay start slightly to allow scene to settle
	await get_tree().create_timer(0.5).timeout
	start_intro()

func start_intro():
	intro_started = true
	current_step = 0
	show_step(current_step)
	
	var tween = create_tween()
	tween.tween_property($BaseBackground, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property($Background, "modulate:a", 1.0, 1.5)

func show_step(step_index):
	if step_index >= intro_steps.size():
		show_black_screen()
		return
	
	var step = intro_steps[step_index]
	texture_rect.texture = step.texture
	full_text = tr(step.text_key)
	displayed_text = ""
	char_index = 0
	label.text = ""
	is_typing = true
	typing_timer.start()

func _on_typing_timer_timeout():
	if char_index < full_text.length():
		displayed_text += full_text[char_index]
		label.text = displayed_text
		char_index += 1
		_play_type_sfx()
	else:
		typing_timer.stop()
		is_typing = false

func _play_type_sfx():
	# Subtle beep or typing sound
	var audio_manager_node = get_tree().root.get_node_or_null("AudioManager")
	if is_instance_valid(audio_manager_node) and audio_manager_node.has_method("play_sfx"):
		audio_manager_node.play_sfx("res://assets/audio/sfx/selected.mp3", -25.0, randf_range(1.5, 2.0))

func _input(event):
	if not intro_started and not is_black_screen: return
	
	if (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT) or \
	   (event is InputEventKey and event.pressed and not event.is_echo()):
		if is_black_screen:
			_finish_intro()
			return
		
		if is_typing:
			# Skip typing
			typing_timer.stop()
			label.text = full_text
			is_typing = false
		else:
			# Next step
			current_step += 1
			if current_step < intro_steps.size():
				# Fade transition between steps would be nice
				_fade_to_next_step()
			else:
				show_black_screen()

func _fade_to_next_step():
	var tween = create_tween()
	tween.tween_property($Background, "modulate:a", 0.0, 0.5)
	await tween.finished
	show_step(current_step)
	var tween_in = create_tween()
	tween_in.tween_property($Background, "modulate:a", 1.0, 0.5)

func show_black_screen():
	intro_started = false # Stop processing step input
	is_black_screen = true
	var tween = create_tween()
	tween.tween_property(black_screen, "modulate:a", 1.0, 1.5)
	tween.parallel().tween_property($Background, "modulate:a", 0.0, 1.5)
	tween.parallel().tween_property($BaseBackground, "modulate:a", 1.0, 1.5) # Ensure it stays visible
	
	await tween.finished
	
	# Set year and world text
	year_label.text = tr("YEAR: 0 (AEON ZERO)")
	world_label.text = tr("WORLD: DIGITAL BIOME - HUB 01")
	
	# Wait a bit or until clicked
	var timer = get_tree().create_timer(3.0)
	while timer.time_left > 0 and is_black_screen:
		await get_tree().process_frame
	
	if not is_black_screen: return # Already finished via click
	
	# Fade out everything
	_finish_intro()

func _finish_intro():
	if not is_instance_valid(self): return
	is_black_screen = false
	
	# Instead of fading out self (which reveals TitleScreen),
	# we just emit and let the next scene cover us, or we stay black.
	# But TitleScreen will change scene, which frees everything in the current scene.
	# If we fade out, we reveal what's behind us (TitleScreen menu/bg).
	
	intro_finished.emit()
	# We don't queue_free() here because we want to stay visible 
	# until the scene change actually happens.
	# The scene change will destroy this node anyway as it's a child of TitleScreen.
