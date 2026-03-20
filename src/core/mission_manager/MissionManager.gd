extends Node

signal mission_updated(mission_name: String, mission_description: String, mission_progress: String)
signal mission_completed(mission_name: String)
signal mission_presented(mission_name: String, mission_description: String)

enum MissionID {
	EVOLVE_CORE,
	CREATE_G2,
	COLLECT_DATA,
	G0_MOBILIZATION
}

var current_mission_id = MissionID.EVOLVE_CORE
var current_mission_name = "Core Awakening"
var current_mission_description = "Awaken the Processor Core to Level 2 to establish a permanent anchor for our growing colony."
var current_mission_progress = "Initializing..."

var completed_mission_ids = []

var missions_data = {
	MissionID.EVOLVE_CORE: {
		"name": "Core Awakening",
		"description": "Awaken the Processor Core to Level 2 to establish a permanent anchor for our growing colony. Grants a 500-unit resource fragment."
	},
	MissionID.CREATE_G2: {
		"name": "Territorial Guardians",
		"description": "Our expansion requires protection. Forge 2 G2 Guardians to shield the core from hostile entities."
	},
	MissionID.COLLECT_DATA: {
		"name": "The Great Harvest",
		"description": "Gather 1 MB of raw resources to fuel our growth and stabilize our domain."
	},
	MissionID.G0_MOBILIZATION: {
		"name": "Colony Mobilization",
		"description": "Unblock the Genezis G0 Mobilizers by reaching 1.5 MB of resources. They will find and wake our sleeping brothers across the electronic void."
	}
}

func _enter_tree() -> void:
	add_to_group("mission_manager")

func _ready() -> void:
	var core = get_tree().get_first_node_in_group("core")
	if core:
		core.data_changed.connect(_on_data_changed)
		core.evolution_changed.connect(_on_evolution_changed)
	
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if world_manager:
		world_manager.genezis_g2_spawned.connect(_on_genezis_g2_spawned)

 # Start mission immediately to have initial state ready for HUD
	if current_mission_id != -1:
		_start_mission(current_mission_id)

func _start_mission(mission_id: MissionID) -> void:
	current_mission_id = mission_id
	print("Starting Mission: ", mission_id)
	match mission_id:
		MissionID.EVOLVE_CORE:
			current_mission_name = "Core Awakening"
			current_mission_description = "Awaken the Processor Core to Level 2 to establish a permanent anchor for our growing colony. Grants a 500-unit resource fragment."
			_update_progress_evolution()
		MissionID.CREATE_G2:
			current_mission_name = "Territorial Guardians"
			current_mission_description = "Our expansion requires protection. Forge 2 G2 Guardians to shield the core from hostile entities."
			_update_progress_g2()
		MissionID.COLLECT_DATA:
			current_mission_name = "The Great Harvest"
			current_mission_description = "Gather 1 MB of raw resources to fuel our growth and stabilize our domain."
			_update_progress_data(0)
		MissionID.G0_MOBILIZATION:
			current_mission_name = "Colony Mobilization"
			current_mission_description = "Unblock the Genezis G0 Mobilizers by reaching 1.5 MB of resources. They will find and wake our sleeping brothers across the electronic void."
			_update_progress_g0(0)
	
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	mission_presented.emit(current_mission_name, current_mission_description)

func _update_progress_evolution() -> void:
	var core = get_tree().get_first_node_in_group("core")
	if not core: return
	
	current_mission_progress = "Evolve Core to level 2 (Current: %d)" % core.evolution_level
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if core.evolution_level >= 2:
		_complete_current_mission()

func _update_progress_g2() -> void:
	var core = get_tree().get_first_node_in_group("core")
	var g2_count = get_tree().get_nodes_in_group("genezis_g2").size()
	
	if core and core.evolution_level < 2:
		current_mission_progress = "Evolve Core to level 2 (Current: %d)" % core.evolution_level
	else:
		current_mission_progress = "G2 Count: %d / 2" % g2_count
	
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if g2_count >= 2:
		_complete_current_mission()

func _update_progress_data(current: int) -> void:
	var target = 1048576 # 1 MB
	current_mission_progress = "Resources: %s / %s" % [format_bytes(current), format_bytes(target)]
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if current >= target:
		_complete_current_mission()

func _update_progress_g0(current: int) -> void:
	var target = 1572864 # 1.5 MB
	current_mission_progress = "Resources: %s / %s" % [format_bytes(current), format_bytes(target)]
	mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
	
	if current >= target:
		_complete_current_mission()

func _complete_current_mission() -> void:
	var completed_mission_id = current_mission_id
	var completed_mission_name = current_mission_name
	
	if not completed_mission_ids.has(completed_mission_id):
		completed_mission_ids.append(completed_mission_id)
	
	# Transition to next mission FIRST to prevent recursion
	match completed_mission_id:
		MissionID.EVOLVE_CORE:
			_start_mission(MissionID.CREATE_G2)
		MissionID.CREATE_G2:
			_start_mission(MissionID.COLLECT_DATA)
		MissionID.COLLECT_DATA:
			_start_mission(MissionID.G0_MOBILIZATION)
		MissionID.G0_MOBILIZATION:
			# More missions can be added here
			current_mission_id = -1 # No more missions
			current_mission_name = "All missions completed"
			current_mission_description = "Wait for more updates."
			current_mission_progress = ""
			mission_updated.emit(current_mission_name, current_mission_description, current_mission_progress)
			mission_presented.emit(current_mission_name, current_mission_description)

	mission_completed.emit(completed_mission_name)
	print("Mission Completed: ", completed_mission_name)
	
	# Autosave on mission completion
	if has_node("/root/SaveManager"):
		get_node("/root/SaveManager").save_game()
		print("Autosave triggered after completing mission: ", completed_mission_name)
	
	# Grant reward for Mission 1 AFTER state transition
	if completed_mission_id == MissionID.EVOLVE_CORE:
		var core = get_tree().get_first_node_in_group("core")
		if core:
			core.deposit_data(500)
			print("Reward of 500 units granted for Mission 1.")
	
	if completed_mission_id == MissionID.G0_MOBILIZATION:
		var world_manager = get_tree().get_first_node_in_group("world_manager")
		if world_manager and world_manager.has_method("_spawn_genezis_g0"):
			world_manager.call("_spawn_genezis_g0")
			print("Genezis G0 spawned as a reward for G0 Mobilization mission.")

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
	elif current_mission_id == MissionID.G0_MOBILIZATION:
		_update_progress_g0(new_amount)

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

func get_all_missions_status() -> Array:
	var result = []
	var ids = [MissionID.EVOLVE_CORE, MissionID.CREATE_G2, MissionID.COLLECT_DATA, MissionID.G0_MOBILIZATION]
	
	for id in ids:
		var status = "locked"
		if id == current_mission_id:
			status = "current"
		elif completed_mission_ids.has(id):
			status = "completed"
		elif _is_mission_unlocked(id):
			status = "available" # Should not happen with current linear progression
			
		result.append({
			"id": id,
			"name": missions_data[id]["name"],
			"description": missions_data[id]["description"],
			"status": status,
			"progress": current_mission_progress if id == current_mission_id else ""
		})
	return result

func _is_mission_unlocked(id: MissionID) -> bool:
	match id:
		MissionID.EVOLVE_CORE:
			return true
		MissionID.CREATE_G2:
			return completed_mission_ids.has(MissionID.EVOLVE_CORE)
		MissionID.COLLECT_DATA:
			return completed_mission_ids.has(MissionID.CREATE_G2)
		MissionID.G0_MOBILIZATION:
			return completed_mission_ids.has(MissionID.COLLECT_DATA)
	return false
