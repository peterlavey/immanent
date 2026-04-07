extends Control

@onready var processor_label = $VBoxContainer/ProcessorLevel
@onready var cost_label = $VBoxContainer/UpgradeCost
@onready var upgrade_button = $VBoxContainer/UpgradeButton

var hardware_manager = null

func _ready() -> void:
	hardware_manager = get_tree().get_first_node_in_group("hardware_manager")
	_update_display()

func _update_display() -> void:
	if hardware_manager:
		processor_label.text = tr("CPU LEVEL: %D") % hardware_manager.processor_level
		var cost = hardware_manager.get_upgrade_cost("processor", hardware_manager.processor_level)
		cost_label.text = tr("COST: %D BYTES") % cost
		
		var core = get_tree().get_first_node_in_group("core")
		if core:
			upgrade_button.disabled = core.current_data < cost
		else:
			upgrade_button.disabled = true

func _on_upgrade_button_pressed() -> void:
	if hardware_manager and hardware_manager.upgrade_processor():
		_update_display()
		_play_click_sfx()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
