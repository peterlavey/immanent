extends Enemy

class_name Defragmenter

func _ready() -> void:
	super._ready()
	move_speed = 2.0 # Slow
	health = 5.0

func _find_target() -> void:
	var data_spots = get_tree().get_nodes_in_group("data_spots")
	var closest: Node3D = null
	var min_dist = INF
	
	for spot in data_spots:
		if is_instance_valid(spot):
			var d = global_position.distance_to(spot.global_position)
			if d < min_dist:
				min_dist = d
				closest = spot
	
	if closest:
		target = closest
		current_state = State.MOVING_TO_TARGET

func _perform_action(delta: float) -> void:
	if is_instance_valid(target) and target.has_method("extract_data"):
		# Consumes 100 bytes per second
		target.extract_data(int(100 * delta))
		
		# If spot is empty, it will be queue_free by its own script, so target becomes invalid
		if not is_instance_valid(target) or target.current_bytes <= 0:
			target = null
			current_state = State.IDLE
	else:
		current_state = State.IDLE
