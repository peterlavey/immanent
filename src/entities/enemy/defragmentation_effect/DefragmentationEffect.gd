extends GPUParticles3D

func _ready() -> void:
	emitting = true
	# Wait for lifetime + some buffer before cleaning up
	var timer = get_tree().create_timer(lifetime + 0.5)
	timer.timeout.connect(queue_free)
