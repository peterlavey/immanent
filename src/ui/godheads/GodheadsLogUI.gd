extends Control

@onready var log_container = $VBoxContainer/ScrollContainer/LogText
@onready var scroll_container = $VBoxContainer/ScrollContainer

var max_logs = 20
var logs: Array[String] = []

func _ready() -> void:
	add_to_group("log_ui")
	_add_log("SYSTEM INITIALIZED")
	_add_log("BOOT_SEQUENCE_COMPLETE")
	_add_log("WAITING_FOR_SIMULATION_LINK")
	
	# Connect to hardware manager
	var hardware_manager = get_tree().get_first_node_in_group("hardware_manager")
	if hardware_manager and hardware_manager.has_signal("hardware_upgraded"):
		hardware_manager.hardware_upgraded.connect(_on_hardware_upgraded)
	
	# Connect to world events if possible
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager:
		if not world_manager.genezis_spawned.is_connected(_on_genezis_spawned):
			world_manager.genezis_spawned.connect(_on_genezis_spawned)
		if not world_manager.genezis_g2_spawned.is_connected(_on_genezis_g2_spawned):
			world_manager.genezis_g2_spawned.connect(_on_genezis_g2_spawned)
		if not world_manager.new_enemy_type_spawned.is_connected(_on_new_enemy_type_spawned):
			world_manager.new_enemy_type_spawned.connect(_on_new_enemy_type_spawned)
	
	var core = get_tree().get_first_node_in_group("core")
	if core:
		if not core.evolution_changed.is_connected(_on_core_evolution_changed):
			core.evolution_changed.connect(_on_core_evolution_changed)
	
	# Periodic random logs to make it look alive
	var timer = Timer.new()
	timer.wait_time = 3.0 # Speed up logs slightly
	timer.autostart = true
	timer.timeout.connect(_on_random_log_timer_timeout)
	add_child(timer)
	
	# Small initial delay before first display to ensure everything is ready
	get_tree().create_timer(0.5).timeout.connect(_update_display)

func _on_random_log_timer_timeout() -> void:
	var messages = [
		"SCANNING_MEMORY_SECTORS...",
		"OPTIMIZING_RESOURCE_ALLOCATION",
		"MONITORING_ENTROPY_LEVELS",
		"SIMULATION_STABILITY_AT_99.8%",
		"DATA_FLOW_STABILIZED",
		"LATENCY_CHECK_OK",
		"HEARTBEAT_DETECTED",
		"CORE_RESONANCE_OPTIMIZED",
		"G1_EVOLUTION_MODEL_STABLE"
	]
	_add_log(messages.pick_random())

func _add_log(message: String) -> void:
	var timestamp = Time.get_time_string_from_system()
	var full_message = "[%s] > %s" % [timestamp, message]
	logs.append(full_message)
	if logs.size() > max_logs:
		logs.remove_at(0)
	
	_update_display()

func _update_display() -> void:
	if not log_container: return
	log_container.text = "\n".join(logs)
	# Scroll to bottom
	if is_inside_tree():
		await get_tree().process_frame
		if scroll_container:
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
