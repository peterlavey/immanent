extends Node

# Hardware properties affecting Genezis world
var processor_level: int = 1: # Higher level = faster cycle duration (decreases cycle_duration)
	set(value):
		processor_level = value
		_update_time_manager()

var memory_level: int = 1: # Higher level = more units allowed (future implementation)
	set(value):
		memory_level = value

var cooling_level: int = 1: # Higher level = slower degradation or faster recovery?
	set(value):
		cooling_level = value

func _ready() -> void:
	add_to_group("hardware_manager")
	# Initial settings sync
	await get_tree().process_frame
	_update_time_manager()

func _update_time_manager() -> void:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if not time_manager:
		# Search as child of world if not in group
		var world = get_tree().get_first_node_in_group("world")
		if world:
			time_manager = world.get_node_or_null("TimeManager")
	
	if time_manager:
		# Level 1: 120s, Level 2: 100s, Level 3: 80s, etc.
		time_manager.cycle_duration = max(30.0, 120.0 - (processor_level - 1) * 20.0)
		print("[HardwareManager] Updated cycle_duration to ", time_manager.cycle_duration)

func upgrade_processor() -> bool:
	var core = get_tree().get_first_node_in_group("core")
	var cost = get_upgrade_cost("processor", processor_level)
	if core and core.spend_data(cost):
		processor_level += 1
		# Notify log UI
		var log_ui = get_tree().get_first_node_in_group("log_ui")
		if log_ui:
			log_ui._on_hardware_upgraded("Processor", processor_level)
		return true
	return false

func get_upgrade_cost(type: String, current_level: int) -> int:
	# Exponential growth of cost?
	# Level 1 to 2: 1000 Bytes
	# Level 2 to 3: 5000 Bytes
	# Level 3 to 4: 25000 Bytes
	return int(pow(5, current_level) * 200)

func get_hertz_display() -> String:
	# Visual Hz based on processor level
	# Base: 1024 Hz, then 2048 Hz, 4096 Hz, etc.
	return "%d Hz" % (1024 * pow(2, processor_level - 1))
