extends Control

@onready var data_label = $MarginContainer/VBoxContainer/DataLabel
@onready var iteration_label = $MarginContainer/VBoxContainer/IterationLabel
@onready var timer_label = $MarginContainer/VBoxContainer/TimerLabel

@onready var upgrade_menu = $UpgradeMenu

func _ready() -> void:
	# Connect to Core signals
	var core = get_tree().get_first_node_in_group("core")
	if core:
		core.data_changed.connect(_on_data_changed)
		_on_data_changed(core.current_data)
	
	# Connect to TimeManager signals
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		time_manager.time_updated.connect(_on_time_updated)
		time_manager.iteration_started.connect(_on_iteration_started)
		_on_iteration_started(time_manager.current_iteration)
	
	if upgrade_menu:
		upgrade_menu.upgrade_purchased.connect(_on_upgrade_purchased)

func _on_upgrade_button_pressed() -> void:
	if upgrade_menu:
		upgrade_menu.show()
		upgrade_menu._update_buttons()

func _on_upgrade_purchased(upgrade_id: String) -> void:
	# Inform all Genezis beings or Core about the upgrade
	match upgrade_id:
		"speed":
			get_tree().call_group("genezis", "upgrade_speed", 1.2)
		"extraction":
			get_tree().call_group("genezis", "upgrade_extraction", 1.2)
		"capacity":
			get_tree().call_group("genezis", "upgrade_capacity", 1.2)
		"fov":
			var core = get_tree().get_first_node_in_group("core")
			if core:
				core.fov_radius += 5.0
		"genezis_count":
			var world_manager = get_tree().get_first_node_in_group("world_manager")
			if world_manager:
				world_manager.spawn_extra_genezis()

func _on_data_changed(amount: int) -> void:
	data_label.text = "Data: " + format_bytes(amount)

func _on_time_updated(remaining: float) -> void:
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "Next Sync: %02d:%02d" % [minutes, seconds]

func _on_iteration_started(number: int) -> void:
	iteration_label.text = str(number) + " Hz"

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return "%.2f KB" % (bytes / 1024.0)
	elif bytes < 1024 * 1024 * 1024:
		return "%.2f MB" % (bytes / (1024.0 * 1024.0))
	else:
		return "%.2f GB" % (bytes / (1024.0 * 1024.0 * 1024.0))
