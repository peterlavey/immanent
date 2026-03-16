extends Node

const SAVE_PATH = "user://savegame.json"

func save_game() -> void:
	var save_data = {
		"version": "1.0.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"core": _get_core_data(),
		"world": _get_world_data(),
		"missions": _get_mission_data(),
		"upgrades": _get_upgrade_data(),
		"time": _get_time_data()
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Game saved successfully to ", SAVE_PATH)
	else:
		printerr("Failed to open save file for writing: ", SAVE_PATH)

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("No save file found at ", SAVE_PATH)
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		printerr("Failed to open save file for reading: ", SAVE_PATH)
		return false
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return false
		
	var save_data = json.data
	
	# Apply data in order of dependency
	_apply_upgrade_data(save_data.get("upgrades", {}))
	_apply_core_data(save_data.get("core", {}))
	_apply_time_data(save_data.get("time", {}))
	_apply_world_data(save_data.get("world", {}))
	_apply_mission_data(save_data.get("missions", {}))
	
	print("Game loaded successfully from ", SAVE_PATH)
	return true

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("user://")
		if dir:
			dir.remove(SAVE_PATH.replace("user://", ""))
			print("Save file deleted: ", SAVE_PATH)
		else:
			printerr("Failed to open user directory to delete save.")
	else:
		print("No save file to delete at ", SAVE_PATH)

func _get_core_data() -> Dictionary:
	var core = get_tree().get_first_node_in_group("core")
	if core:
		return {
			"current_data": core.current_data,
			"evolution_level": core.evolution_level,
			"fov_radius": core.fov_radius
		}
	return {}

func _apply_core_data(data: Dictionary) -> void:
	var core = get_tree().get_first_node_in_group("core")
	if core and not data.is_empty():
		core.current_data = data.get("current_data", 0)
		core.evolution_level = data.get("evolution_level", 1) # Start new games at level 1
		core.fov_radius = data.get("fov_radius", 10.0)

func _get_world_data() -> Dictionary:
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	var data = {
		"genezis_g1": [],
		"genezis_g2": [],
		"data_spots": [],
		"enemies": [],
		"discovered_enemies": []
	}
	
	if world_manager:
		data["discovered_enemies"] = world_manager._discovered_enemies
		data["g2_spawn_count"] = world_manager._g2_spawn_count
	
	for g in get_tree().get_nodes_in_group("genezis_g1"):
		data["genezis_g1"].append({
			"pos": _vec3_to_dict(g.global_position),
			"load": g.current_load,
			"speed": g.move_speed,
			"capacity": g.carry_capacity,
			"extraction": g.extraction_rate,
			"conn_range": g.connection_range,
			"conn_boost": g.connection_boost
		})
		
	for g in get_tree().get_nodes_in_group("genezis_g2"):
		data["genezis_g2"].append({
			"pos": _vec3_to_dict(g.global_position)
		})
		
	for s in get_tree().get_nodes_in_group("data_spots"):
		data["data_spots"].append({
			"pos": _vec3_to_dict(s.global_position),
			"max_bytes": s.max_bytes,
			"current_bytes": s.current_bytes,
			"scale": _vec3_to_dict(s.scale)
		})
		
	for e in get_tree().get_nodes_in_group("enemies"):
		var type = "BitScrubber"
		if e is Defragmenter:
			type = "Defragmenter"
		data["enemies"].append({
			"type": type,
			"pos": _vec3_to_dict(e.global_position),
			"health": e.health
		})
		
	return data

func _apply_world_data(data: Dictionary) -> void:
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if not world_manager: return
	
	# Clear existing entities except Core
	for g in get_tree().get_nodes_in_group("genezis_g1"): g.queue_free()
	for g in get_tree().get_nodes_in_group("genezis_g2"): g.queue_free()
	for s in get_tree().get_nodes_in_group("data_spots"): s.queue_free()
	for e in get_tree().get_nodes_in_group("enemies"): e.queue_free()
	
	var discovered: Array[String] = []
	for type_name in data.get("discovered_enemies", []):
		discovered.append(str(type_name))
	world_manager._discovered_enemies = discovered
	
	# Restore Data Spots
	for s_data in data.get("data_spots", []):
		var spot = world_manager.data_spot_scene.instantiate()
		world_manager.add_child(spot)
		spot.global_position = _dict_to_vec3(s_data.pos)
		spot.max_bytes = s_data.max_bytes
		spot.current_bytes = s_data.current_bytes
		spot.scale = _dict_to_vec3(s_data.scale)
		
	# Restore Genezis G1
	for g_data in data.get("genezis_g1", []):
		var g = world_manager.genezis_g1_scene.instantiate()
		world_manager.add_child(g)
		g.global_position = _dict_to_vec3(g_data.pos)
		g.current_load = g_data.load
		g.move_speed = g_data.speed
		g.carry_capacity = g_data.capacity
		g.extraction_rate = g_data.extraction
		g.connection_range = g_data.get("conn_range", 0.0)
		g.connection_boost = g_data.get("conn_boost", 1.0)
		world_manager.genezis_spawned.emit(g)
		
	# Restore Genezis G2
	world_manager._g2_spawn_count = data.get("g2_spawn_count", 0)
	for g_data in data.get("genezis_g2", []):
		var g = world_manager.genezis_g2_scene.instantiate()
		world_manager.add_child(g)
		g.global_position = _dict_to_vec3(g_data.pos)
		world_manager.genezis_g2_spawned.emit(g)
		
	# Restore Enemies
	for e_data in data.get("enemies", []):
		var scene = world_manager.bit_scrubber_scene
		if e_data.type == "Defragmenter":
			scene = world_manager.defragmenter_scene
		
		if scene:
			var e = scene.instantiate()
			world_manager.add_child(e)
			e.global_position = _dict_to_vec3(e_data.pos)
			e.health = e_data.health

func _get_mission_data() -> Dictionary:
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if mission_manager:
		return {
			"current_mission_id": mission_manager.current_mission_id
		}
	return {}

func _apply_mission_data(data: Dictionary) -> void:
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if mission_manager and data.has("current_mission_id"):
		var mid = data.current_mission_id
		if mid != -1:
			mission_manager._start_mission(mid)
		else:
			mission_manager.current_mission_id = -1
			mission_manager.current_mission_name = "All missions completed"
			mission_manager.current_mission_description = "Wait for more updates."
			mission_manager.current_mission_progress = ""
			mission_manager.mission_updated.emit(mission_manager.current_mission_name, mission_manager.current_mission_description, mission_manager.current_mission_progress)

func _get_upgrade_data() -> Dictionary:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.upgrade_menu:
		return {
			"upgrade_levels": hud.upgrade_menu.upgrade_levels
		}
	return {}

func _apply_upgrade_data(data: Dictionary) -> void:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.upgrade_menu and data.has("upgrade_levels"):
		hud.upgrade_menu.upgrade_levels = data.upgrade_levels
		hud.upgrade_menu._update_buttons()

func _get_time_data() -> Dictionary:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		return {
			"current_iteration": time_manager.current_iteration,
			"remaining_time": time_manager.remaining_time
		}
	return {}

func _apply_time_data(data: Dictionary) -> void:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager and not data.is_empty():
		time_manager.current_iteration = data.get("current_iteration", 1)
		time_manager.remaining_time = data.get("remaining_time", time_manager.iteration_duration)
		time_manager.iteration_started.emit(time_manager.current_iteration)

func _vec3_to_dict(v: Vector3) -> Dictionary:
	return {"x": v.x, "y": v.y, "z": v.z}

func _dict_to_vec3(d: Dictionary) -> Vector3:
	return Vector3(d.get("x", 0), d.get("y", 0), d.get("z", 0))
