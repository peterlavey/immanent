class_name EvolutionFirst extends BaseNode

var DIALOGUES: GDScript
var terminalMsg: Terminal

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	terminalMsg = Load.src("utils/message/terminal", DIALOGUES.INITIALIZATION)
	terminalMsg.connect("on_finish", self, "test")

func start()-> void:
	show_messages()

func show_messages():
	add_child(terminalMsg)
	terminalMsg.start()

func test():
	print("on finish")
