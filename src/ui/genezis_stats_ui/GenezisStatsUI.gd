extends Control

@onready var stats_label = $Panel/MarginContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	hide()

func display_stats(stats: Dictionary) -> void:
	show()
	var type_label = stats.get("type", "Genezis G1")
	var text = "%s Statistics\n" % type_label
	text += "------------------\n"
	text += "Status: %s\n" % stats.get("state", "UNKNOWN")
	text += "Speed: %.1f m/s\n" % stats.get("speed", 0.0)
	
	if type_label == "Genezis G2":
		text += "Role: Protection / Security\n"
	else:
		text += "Extraction: %d B/s\n" % stats.get("extraction", 0)
		text += "Load: %s / %s" % [format_bytes(stats.get("load", 0)), format_bytes(stats.get("capacity", 0))]
	
	stats_label.text = text

func format_bytes(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1048576:
		return "%.1f KB" % (bytes / 1024.0)
	else:
		return "%.1f MB" % (bytes / 1048576.0)

func _on_close_button_pressed() -> void:
	hide()
