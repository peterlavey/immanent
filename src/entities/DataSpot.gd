extends StaticBody3D

signal depleted(data_spot: Node3D)

@export var max_megabytes: float = 5.0
var current_megabytes: float = max_megabytes:
	set(value):
		current_megabytes = max(0, value)
		if current_megabytes <= 0:
			depleted.emit(self)
			queue_free()

func extract_data(amount: float) -> float:
	var actual_extracted = min(amount, current_megabytes)
	current_megabytes -= actual_extracted
	return actual_extracted
