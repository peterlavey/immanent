extends Label3D

@export var duration: float = 2.0
@export var travel_distance: float = 1.0

var elapsed_time: float = 0.0

func _ready() -> void:
	# Ensure the text is visible and centered
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true # Make it visible through objects if needed, or keep it false for realism

func _process(delta: float) -> void:
	elapsed_time += delta
	var progress = elapsed_time / duration
	
	if progress >= 1.0:
		queue_free()
		return
	
	# Move upwards
	global_position.y += (travel_distance / duration) * delta
	
	# Fade out
	modulate.a = 1.0 - progress
