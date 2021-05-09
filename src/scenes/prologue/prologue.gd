class_name Prologue extends BaseNode

signal next
var DIALOGUES: GDScript
var IMG_PATH = "prologue/images"
var SONGS: Array = ["res://assets/prologue/music/prologue.ogg"]
var sequenceMsg: Sequence

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	sequenceMsg = Load.src("utils/message/sequence", DIALOGUES.PROLOGUE, IMG_PATH, SONGS)
	sequenceMsg.connect("on_finish", self, "next_scene")

func start()-> void:
	show_messages()

func show_messages():
	add_child(sequenceMsg)
	sequenceMsg.start()

func next_scene():
	emit_signal("next")
