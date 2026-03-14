extends Node

signal iteration_started(number: int)
signal iteration_ended(number: int)
signal time_updated(remaining_seconds: float)

@export var iteration_duration: float = 120.0 # 2 minutes
var current_iteration: int = 1
var remaining_time: float = iteration_duration
var is_running: bool = true

func _process(delta: float) -> void:
	if is_running:
		remaining_time -= delta
		time_updated.emit(remaining_time)
		
		if remaining_time <= 0:
			end_iteration()

func end_iteration() -> void:
	iteration_ended.emit(current_iteration)
	current_iteration += 1
	remaining_time = iteration_duration
	iteration_started.emit(current_iteration)
	print("Iteration started: ", current_iteration)

func get_hertz_display() -> String:
	# Just a placeholder for "Hertz" based representation
	# In a digital simulation, time can be seen as cycles
	return str(current_iteration) + " Hz"
