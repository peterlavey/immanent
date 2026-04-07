extends Control

@onready var stats_label = $Panel/MarginContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	hide()

func display_stats(stats: Dictionary) -> void:
	show()
	var type_label = stats.get("type", "Genezis G1")
	var text = tr("%S STATISTICS") % type_label + "\n"
	text += "------------------\n"
	text += tr("STATUS: %S") % tr(stats.get("state", "UNKNOWN").to_upper()) + "\n"
	text += tr("SPEED: %.1F M/S") % stats.get("speed", 0.0) + "\n"
	
	if type_label == "Genezis G2":
		text += tr("ROLE: PROTECTION / SECURITY") + "\n"
	else:
		var extraction = stats.get("extraction", 0)
		var is_connected = stats.get("is_connected", false)
		var boost = stats.get("conn_boost", 1.0)
		
		if is_connected:
			text += tr("EXTRACTION: %D B/S (X%.1F BOOST!)") % [extraction, boost] + "\n"
		else:
			text += tr("EXTRACTION: %D B/S") % extraction + "\n"
			
		text += tr("LOAD: %S / %S") % [format_bytes(stats.get("load", 0)), format_bytes(stats.get("capacity", 0))] + "\n"
		
		var conn_range = stats.get("conn_range", 0.0)
		if conn_range > 0:
			text += tr("PSINERGY: %S") % tr("ACTIVE" if is_connected else "SCANNING...")
	
	stats_label.text = text

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)

func _on_close_button_pressed() -> void:
	_play_click_sfx()
	hide()

func _play_click_sfx() -> void:
	var audio_manager = get_tree().root.get_node_or_null("AudioManager")
	if audio_manager:
		audio_manager.play_sfx("res://assets/audio/sfx/selected.mp3", -10.0)
