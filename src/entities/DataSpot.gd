extends StaticBody3D

signal depleted(data_spot: Node3D)

@export var max_bytes: int = 1024: # 1 KB per spot initially
	set(value):
		max_bytes = value
		current_bytes = value

var current_bytes: int = max_bytes:
	set(value):
		current_bytes = max(0, value)
		if current_bytes <= 0:
			depleted.emit(self)
			queue_free()

func extract_data(amount: int) -> int:
	var actual_extracted = min(amount, current_bytes)
	current_bytes -= actual_extracted
	return actual_extracted
