extends Control

@onready var log_container = $VBoxContainer/ScrollContainer/LogText
@onready var scroll_container = $VBoxContainer/ScrollContainer

var max_logs = 20
var logs: Array[String] = []

func _ready() -> void:
	add_to_group("log_ui")
	_add_log("SYSTEM INITIALIZED")
	_add_log("WAITING FOR USER INTERFACE")
	
	# Connect to world events if possible
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager:
		world_manager.genezis_spawned.connect(_on_genezis_spawned)
		world_manager.genezis_g2_spawned.connect(_on_genezis_g2_spawned)
		world_manager.new_enemy_type_spawned.connect(_on_new_enemy_type_spawned)
	
	var core = get_tree().get_first_node_in_group("core")
	if core:
		core.evolution_changed.connect(_on_core_evolution_changed)

func _add_log(message: String) -> void:
	var timestamp = Time.get_time_string_from_system()
	var full_message = "[%s] %s" % [timestamp, message]
	logs.append(full_message)
	if logs.size() > max_logs:
		logs.remove_at(0)
	
	_update_display()

func _update_display() -> void:
	log_container.text = "\n".join(logs)
	# Scroll to bottom
	await get_tree().process_frame
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _on_genezis_spawned(_genezis) -> void:
	_add_log("NEW UNIT_G1 INITIALIZED")

func _on_genezis_g2_spawned(_genezis) -> void:
	_add_log("NEW UNIT_G2 INITIALIZED")

func _on_new_enemy_type_spawned(type_name: String) -> void:
	_add_log("WARNING: UNKNOWN PROCESS DETECTED: %s" % type_name.to_upper())

func _on_core_evolution_changed(level: int) -> void:
	_add_log("SYSTEM EVOLUTION REACHED LEVEL %d" % level)

func _on_hardware_upgraded(type: String, level: int) -> void:
	_add_log("HARDWARE UPGRADE: %s TO LEVEL %d" % [type.to_upper(), level])
