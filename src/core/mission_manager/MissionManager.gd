extends Node

signal mission_updated(mission_name: String, mission_description: String, mission_progress: String)
signal mission_completed(mission_name: String)

enum MissionID {
	EVOLVE_CORE,
	CREATE_G2,
	COLLECT_DATA
}

var current_mission_id = MissionID.EVOLVE_CORE
var current_mission_name = "Core Optimization"
var current_mission_description = "Optimize the Processor Core to Level 1. Completion grants a 500-byte data packet."
var current_mission_progress = "Initializing..."

func _ready() -> void:
	add_to_group("mission_manager")
	# Start mission immediately to have initial state ready for HUD
	_start_mission(MissionID.EVOLVE_CORE)

func _start_mission(mission_id: MissionID) -> void:
	current_mission_id = mission_id
	match mission_id:
		MissionID.EVOLVE_CORE:
			current_mission_name = "Core Optimization"
			current_mission_description = "Optimize the Processor Core to Level 1. Completion grants a 500-byte data packet."
			_update_progress_evolution()
		MissionID.CREATE_G2:
			current_mission_name = "Security Protocol"
			current_mission_description = "Fuse 4 G1 units into a G2 Guardian to establish a defense perimeter."
			_update_progress_g2()
		MissionID.COLLECT_DATA:
			current_mission_name = "Data Harvest"
			current_mission_description = "Accumulate a total of 1 MB of data to stabilize the digital biome."
			_update_progress_data(0)
	
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)

func _update_progress_evolution() -> void:
	var core = get_tree().get_first_node_in_group("core")
	if not core: return
	
	current_mission_progress = "Evolve Core to level 1 (Current: %d)" % core.evolution_level
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if core.evolution_level >= 1:
		_complete_current_mission()

func _update_progress_g2() -> void:
	var core = get_tree().get_first_node_in_group("core")
	var g2_count = get_tree().get_nodes_in_group("genezis_g2").size()
	
	if core and core.evolution_level < 2:
		current_mission_progress = "Evolve Core to level 2 (Current: %d)" % core.evolution_level
	else:
		current_mission_progress = "G2 Count: %d / 1" % g2_count
	
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if g2_count >= 1:
		_complete_current_mission()

func _update_progress_data(current: int) -> void:
	var target = 1048576 # 1 MB
	current_mission_progress = "Data: %s / %s" % [format_bytes(current), format_bytes(target)]
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if current >= target:
		_complete_current_mission()

func _complete_current_mission() -> void:
	mission_completed.emit(current_mission_name)
	print("Mission Completed: ", current_mission_name)
	
	# Grant reward for Mission 1
	if current_mission_id == MissionID.EVOLVE_CORE:
		var core = get_tree().get_first_node_in_group("core")
		if core:
			core.deposit_data(500)
			print("Reward of 500 bytes granted for Mission 1.")
	
	# Transition to next mission
	match current_mission_id:
		MissionID.EVOLVE_CORE:
			_start_mission(MissionID.CREATE_G2)
		MissionID.CREATE_G2:
			_start_mission(MissionID.COLLECT_DATA)
		MissionID.COLLECT_DATA:
			# More missions can be added here
			current_mission_name = "All missions completed"
			current_mission_description = "Wait for more updates."
			current_mission_progress = ""
			mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)

func _on_genezis_g2_spawned(_genezis) -> void:
	if current_mission_id == MissionID.CREATE_G2:
		_update_progress_g2()

func _on_data_changed(new_amount: int) -> void:
	if current_mission_id == MissionID.EVOLVE_CORE:
		_update_progress_evolution()
	elif current_mission_id == MissionID.CREATE_G2:
		_update_progress_g2()
	elif current_mission_id == MissionID.COLLECT_DATA:
		_update_progress_data(new_amount)

func _on_evolution_changed(_new_level: int) -> void:
	if current_mission_id == MissionID.EVOLVE_CORE:
		_update_progress_evolution()
	elif current_mission_id == MissionID.CREATE_G2:
		_update_progress_g2()

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)
