extends Control

signal description_closed

@onready var title_label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var description_label = $Panel/MarginContainer/VBoxContainer/DescriptionLabel

var descriptions = {
	"BitScrubber": "BIT-SCRUBBER\n\nA FAST, AGGRESSIVE VIRUS THAT SEEKS OUT GENEZIS G1 UNITS AND RESETS THEIR DATA LOAD UPON CONTACT. PROTECT YOUR GATHERERS!",
	"Defragmenter": "DEFRAGMENTER\n\nA SLOW-MOVING THREAT THAT TARGETS DATA SPOTS DIRECTLY, CONSUMING THE RESOURCES BEFORE YOU CAN COLLECT THEM. DISPERSE IT QUICKLY!"
}

func show_enemy_description(enemy_type: String) -> void:
	if descriptions.has(enemy_type):
		title_label.text = tr("NEW THREAT DETECTED!")
		description_label.text = tr(descriptions[enemy_type])
		show()
		get_tree().paused = true
	else:
		# If unknown type, just don't show or show a generic one
		push_warning("Unknown enemy type: " + enemy_type)

func _on_close_button_pressed() -> void:
	_play_click_sfx()
	print("EnemyDescriptionUI: Close button pressed.")
	hide()
	get_tree().paused = false
	description_closed.emit()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)

func _input(event: InputEvent) -> void:
	# If we use _input, we intercept everything before the Button gets it.
	# The CloseButton is a child of this node.
	# If we want to block interaction with the world behind, 
	# we should rely on a background Panel with mouse_filter = STOP.
	pass
