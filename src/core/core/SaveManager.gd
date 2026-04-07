extends Node

signal save_started
signal save_finished(bytes: int)
signal show_units_labels_changed(show: bool)
signal show_spots_labels_changed(show: bool)
signal show_enemies_labels_changed(show: bool)
signal show_core_labels_changed(show: bool)

const SAVE_PATH = "user://savegame.json"
const SETTINGS_PATH = "user://settings.json"

var show_units_labels: bool = true:
	set(value):
		show_units_labels = value
		show_units_labels_changed.emit(show_units_labels)
		_save_settings()

var show_spots_labels: bool = true:
	set(value):
		show_spots_labels = value
		show_spots_labels_changed.emit(show_spots_labels)
		_save_settings()

var show_enemies_labels: bool = true:
	set(value):
		show_enemies_labels = value
		show_enemies_labels_changed.emit(show_enemies_labels)
		_save_settings()

var show_core_labels: bool = true:
	set(value):
		show_core_labels = value
		show_core_labels_changed.emit(show_core_labels)
		_save_settings()

func _ready() -> void:
	_load_settings()

func _save_settings() -> void:
	var settings = {
		"show_units_labels": show_units_labels,
		"show_spots_labels": show_spots_labels,
		"show_enemies_labels": show_enemies_labels,
		"show_core_labels": show_core_labels
	}
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(settings))
		file.close()

func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			var error = json.parse(file.get_as_text())
			if error == OK:
				var data = json.data
				show_units_labels = data.get("show_units_labels", true)
				show_spots_labels = data.get("show_spots_labels", true)
				show_enemies_labels = data.get("show_enemies_labels", true)
				show_core_labels = data.get("show_core_labels", true)
			file.close()

func save_game() -> void:
	save_started.emit()
	
	# Load current save data if it exists to merge/preserve data 
	# that might not be in the current scene (e.g. World or Mission data)
	var current_save = _load_raw_save_data()
	
	var save_data = {
		"version": "1.0.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"core": _get_core_data(),
		"world": _get_world_data(),
		"missions": _get_mission_data(),
		"upgrades": _get_upgrade_data(),
		"time": _get_time_data()
	}
	
	# If we are NOT in the world scene, we should NOT overwrite world and mission data
	# if they were already present in a previous save.
	var is_in_world = get_tree().current_scene.scene_file_path == "res://src/core/world/World.tscn"
	
	if not is_in_world and not current_save.is_empty():
		# Preserve world data if it's missing in current scene but exists in save
		if save_data.world.is_empty() or (save_data.world.get("genezis_g1", []).is_empty() and save_data.world.get("data_spots", []).is_empty()):
			if current_save.has("world"):
				print("[SaveManager] Preserving world data from previous save (not in World scene)")
				save_data["world"] = current_save["world"]
		
		# Preserve mission data if it's missing or default in current scene
		if current_save.has("missions"):
			var mission_manager = get_tree().get_first_node_in_group("mission_manager")
			if not mission_manager:
				print("[SaveManager] Preserving mission data from previous save (MissionManager not found)")
				save_data["missions"] = current_save["missions"]
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var bytes_saved = 0
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		bytes_saved = json_string.length()
		file.close()
		print("Game saved successfully to ", SAVE_PATH)
	else:
		printerr("Failed to open save file for writing: ", SAVE_PATH)
	
	save_finished.emit(bytes_saved)

func _load_raw_save_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}
		
	return json.data

func load_game() -> bool:
	print("[SaveManager] load_game() starting")
	if not FileAccess.file_exists(SAVE_PATH):
		print("[SaveManager] No save file found at ", SAVE_PATH)
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		printerr("[SaveManager] Failed to open save file for reading: ", SAVE_PATH)
		return false
		
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("[SaveManager] JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		return false
		
	var save_data = json.data
	
	# Check if we are in the simulation world
	var is_in_world = get_tree().current_scene.scene_file_path == "res://src/core/world/World.tscn"
	
	# Apply data in order of dependency
	print("[SaveManager] Applying save data...")
	_apply_upgrade_data(save_data.get("upgrades", {}))
	_apply_core_data(save_data.get("core", {}), true)
	_apply_time_data(save_data.get("time", {}), true)
	
	# For world and mission, we only apply if we are in the simulation scene
	# or if we are loading into the Godheads view (which is the main entry)
	if is_in_world:
		_apply_world_data(save_data.get("world", {}), true)
		_apply_mission_data(save_data.get("missions", {}), true)
	else:
		# If we're not in the world, just ensure world-related managers are updated if they exist
		_apply_mission_data(save_data.get("missions", {}), true)
		
		# If we are NOT in the world, we still want to make sure the WorldManager 
		# will NOT perform initial spawn when it eventually loads.
		# We can't easily set a flag on a non-existent node, but we can rely on 
		# SaveManager state if needed, or just let WorldManager check the file itself.
	
	print("[SaveManager] Game loaded successfully from ", SAVE_PATH)
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
			"total_accumulated_data": core.total_accumulated_data,
			"evolution_level": core.evolution_level,
			"fov_radius": core.fov_radius
		}
	return {}

func _apply_core_data(data: Dictionary, silent: bool = false) -> void:
	print("[SaveManager] _apply_core_data starting")
	var core = get_tree().get_first_node_in_group("core")
	if not core:
		core = get_tree().root.find_child("Core", true, false)
		if not core:
			if not silent:
				printerr("[SaveManager] Warning: Core not found")
			return
			
	if not data.is_empty():
		core.current_data = data.get("current_data", 0)
		core.total_accumulated_data = data.get("total_accumulated_data", core.current_data)
		core.evolution_level = data.get("evolution_level", 1)
		core.fov_radius = data.get("fov_radius", 10.0)
	print("[SaveManager] _apply_core_data finished")

func _get_world_data() -> Dictionary:
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	var data = {
		"genezis_g1": [],
		"genezis_g2": [],
		"genezis_g0": [],
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
	
	for g in get_tree().get_nodes_in_group("genezis_g0"):
		data["genezis_g0"].append({
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
		if e.has_method("_perform_action") and not e.has_method("reset_load"):
			# Defragmenter targets DataSpots, BitScrubber targets GenezisG1
			# Since they both inherit from Enemy, we check for a specific method or property.
			# Defragmenter has a simpler _perform_action without stealing logic.
			# But a better way is to check the script path if class_name is failing.
			if "Defragmenter" in e.get_script().get_path():
				type = "Defragmenter"
		
		data["enemies"].append({
			"type": type,
			"pos": _vec3_to_dict(e.global_position),
			"health": e.health
		})
		
	return data

func _apply_world_data(data: Dictionary, silent: bool = false) -> void:
	print("[SaveManager] _apply_world_data starting")
	var world_manager = get_tree().get_first_node_in_group("world_manager")
	if not world_manager:
		# Fallback to direct search if group is not ready
		world_manager = get_tree().root.find_child("World", true, false)
		if not world_manager:
			if not silent:
				printerr("[SaveManager] Error: WorldManager not found in 'world_manager' group or root")
			return
	
	print("[SaveManager] WorldManager found, cleaning up existing entities...")
	# Clear existing entities except Core
	for g in get_tree().get_nodes_in_group("genezis_g1"): g.queue_free()
	for g in get_tree().get_nodes_in_group("genezis_g2"): g.queue_free()
	for g in get_tree().get_nodes_in_group("genezis_g0"): g.queue_free()
	# The group names were data_spots and enemies in some places, checking both
	for s in get_tree().get_nodes_in_group("data_spots"): s.queue_free()
	for s in get_tree().get_nodes_in_group("data_spot"): s.queue_free()
	for e in get_tree().get_nodes_in_group("enemies"): e.queue_free()
	for e in get_tree().get_nodes_in_group("enemy"): e.queue_free()
	
	print("[SaveManager] Restoring discovered enemies...")
	var discovered: Array[String] = []
	for type_name in data.get("discovered_enemies", []):
		discovered.append(str(type_name))
	world_manager._discovered_enemies = discovered
	
	# Restore Data Spots
	print("[SaveManager] Restoring Data Spots...")
	if world_manager.data_spot_scene:
		for s_data in data.get("data_spots", []):
			var spot = world_manager.data_spot_scene.instantiate()
			world_manager.add_child(spot)
			spot.global_position = _dict_to_vec3(s_data.pos)
			spot.max_bytes = s_data.max_bytes
			spot.current_bytes = s_data.current_bytes
			spot.scale = _dict_to_vec3(s_data.scale)
	
	# Restore Genezis G1
	print("[SaveManager] Restoring Genezis G1...")
	if world_manager.genezis_g1_scene:
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
			if world_manager.has_signal("genezis_spawned"):
				world_manager.genezis_spawned.emit(g)
		
	# Restore Genezis G2
	print("[SaveManager] Restoring Genezis G2...")
	world_manager._g2_spawn_count = data.get("g2_spawn_count", 0)
	if world_manager.genezis_g2_scene:
		for g_data in data.get("genezis_g2", []):
			var g = world_manager.genezis_g2_scene.instantiate()
			world_manager.add_child(g)
			g.global_position = _dict_to_vec3(g_data.pos)
			if world_manager.has_signal("genezis_g2_spawned"):
				world_manager.genezis_g2_spawned.emit(g)
		
	# Restore Genezis G0
	print("[SaveManager] Restoring Genezis G0...")
	if world_manager.genezis_g0_scene:
		for g_data in data.get("genezis_g0", []):
			var g = world_manager.genezis_g0_scene.instantiate()
			world_manager.add_child(g)
			g.global_position = _dict_to_vec3(g_data.pos)
		
	# Restore Enemies
	print("[SaveManager] Restoring Enemies...")
	for e_data in data.get("enemies", []):
		var scene = null
		if e_data.type == "Defragmenter":
			scene = world_manager.defragmenter_scene
		else:
			scene = world_manager.bit_scrubber_scene
		
		if scene:
			var e = scene.instantiate()
			world_manager.add_child(e)
			e.global_position = _dict_to_vec3(e_data.pos)
			e.health = e_data.health
	print("[SaveManager] _apply_world_data finished")

func _get_mission_data() -> Dictionary:
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if mission_manager:
		return {
			"current_mission_id": mission_manager.current_mission_id
		}
	return {}

func _apply_mission_data(data: Dictionary, silent: bool = false) -> void:
	print("[SaveManager] _apply_mission_data starting")
	var mission_manager = get_tree().get_first_node_in_group("mission_manager")
	if not mission_manager:
		# Fallback to direct search
		mission_manager = get_tree().root.find_child("MissionManager", true, false)
		if not mission_manager:
			if not silent:
				printerr("[SaveManager] Warning: MissionManager not found")
			return
			
	if data.has("current_mission_id"):
		var mid = data.current_mission_id
		if mid != -1:
			print("[SaveManager] Starting mission ID: ", mid)
			if mission_manager.has_method("_start_mission"):
				mission_manager._start_mission(mid)
			else:
				mission_manager.current_mission_id = mid
		else:
			print("[SaveManager] All missions completed")
			mission_manager.current_mission_id = -1
			mission_manager.current_mission_name = "All missions completed"
			mission_manager.current_mission_description = "Wait for more updates."
			mission_manager.current_mission_progress = ""
			if mission_manager.has_signal("mission_updated"):
				mission_manager.mission_updated.emit(mission_manager.current_mission_name, mission_manager.current_mission_description, mission_manager.current_mission_progress)
	print("[SaveManager] _apply_mission_data finished")

func _get_upgrade_data() -> Dictionary:
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.upgrade_menu:
		return {
			"upgrade_levels": hud.upgrade_menu.upgrade_levels
		}
	return {}

func _apply_upgrade_data(data: Dictionary) -> void:
	print("[SaveManager] _apply_upgrade_data starting")
	var hud = get_tree().get_first_node_in_group("hud")
	if not hud:
		hud = get_tree().root.find_child("HUD", true, false)
	
	if hud and is_instance_valid(hud) and hud.upgrade_menu and data.has("upgrade_levels"):
		var levels = data.upgrade_levels
		# Ensure levels is a dictionary before assignment
		if levels is Dictionary:
			hud.upgrade_menu.upgrade_levels = levels
			if hud.upgrade_menu.has_method("_update_buttons"):
				hud.upgrade_menu._update_buttons()
		else:
			printerr("SaveManager: upgrade_levels in save is not a Dictionary")
	print("[SaveManager] _apply_upgrade_data finished")

func _get_time_data() -> Dictionary:
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if time_manager:
		return {
			"current_cycle": time_manager.current_cycle,
			"remaining_time": time_manager.remaining_time
		}
	return {}

func _apply_time_data(data: Dictionary, silent: bool = false) -> void:
	print("[SaveManager] _apply_time_data starting")
	var time_manager = get_tree().get_first_node_in_group("time_manager")
	if not time_manager:
		time_manager = get_tree().root.find_child("TimeManager", true, false)
		if not time_manager:
			if not silent:
				printerr("[SaveManager] Warning: TimeManager not found")
			return
			
	if not data.is_empty():
		# Maintain backward compatibility with old saves if any
		if data.has("current_iteration"):
			time_manager.current_cycle = data.get("current_iteration", 1)
		else:
			time_manager.current_cycle = data.get("current_cycle", 1)
			
		time_manager.remaining_time = data.get("remaining_time", time_manager.cycle_duration)
		if time_manager.has_signal("cycle_started"):
			time_manager.cycle_started.emit(time_manager.current_cycle)
	print("[SaveManager] _apply_time_data finished")

func _vec3_to_dict(v: Vector3) -> Dictionary:
	return {"x": v.x, "y": v.y, "z": v.z}

func _dict_to_vec3(d: Dictionary) -> Vector3:
	return Vector3(d.get("x", 0), d.get("y", 0), d.get("z", 0))
