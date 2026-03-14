extends Control

@onready var stats_label = $Panel/MarginContainer/VBoxContainer/StatsLabel

func _ready() -> void:
	hide()

func display_stats(stats: Dictionary) -> void:
	show()
	var text = "Genezis Statistics\n"
	text += "------------------\n"
	text += "Status: %s\n" % stats["state"]
	text += "Speed: %.1f m/s\n" % stats["speed"]
	text += "Extraction: %d B/s\n" % stats["extraction"]
	text += "Load: %s / %s" % [format_bytes(stats["load"]), format_bytes(stats["capacity"])]
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
