extends Enemy

class_name BitScrubber

func _ready() -> void:
	super._ready()
	move_speed = 7.0 # Fast scrubber
	health = 2.0

func _find_target() -> void:
	var g1_units = get_tree().get_nodes_in_group("genezis_g1")
	var closest: Node3D = null
	var min_dist = INF
	
	for g1 in g1_units:
		if is_instance_valid(g1) and not g1.is_queued_for_deletion():
			var g1_pos = g1.global_position
			var d = global_position.distance_to(g1_pos)
			if d < min_dist:
				min_dist = d
				closest = g1
	
	if closest:
		target = closest
		current_state = State.MOVING_TO_TARGET

func _perform_action(_delta: float) -> void:
	if is_instance_valid(target) and target.has_method("reset_load"):
		target.reset_load()
		# After scrubbing, find a new target
		current_state = State.IDLE
		target = null
	else:
		current_state = State.IDLE
