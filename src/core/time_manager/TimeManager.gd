extends Node

signal cycle_started(number: int)
signal cycle_ended(number: int)
signal time_updated(remaining_seconds: float)
signal theophania_requested()

@export var cycle_duration: float = 120.0 # 2 minutes
@export var theophania_frequency: int = 4 # Every 4 cycles
var current_cycle: int = 1
var remaining_time: float = cycle_duration
var is_running: bool = true

func _process(delta: float) -> void:
	if is_running:
		remaining_time -= delta
		time_updated.emit(remaining_time)
		
		if remaining_time <= 0:
			end_cycle()

func end_cycle() -> void:
	cycle_ended.emit(current_cycle)
	
	if current_cycle == 1 or current_cycle % theophania_frequency == 0:
		theophania_requested.emit()
		
	current_cycle += 1
	remaining_time = cycle_duration
	cycle_started.emit(current_cycle)
	print("Cycle started: ", current_cycle)

func get_hertz_display() -> String:
	# Speed in Hz = 1 / cycle_duration (if 1 cycle is the base unit)
	# But requirement says "speed at which these cycles occur"
	# If 1 cycle is 120s, then speed is 1/120 Hz = 0.0083 Hz
	# Maybe we can simulate a higher clock speed for visual immersion
	# For now, let's use a base speed that scales slightly?
	# Or just fixed 1024 Hz as a nod to the lore (1s = 1024 years)
	return "1024 Hz"
