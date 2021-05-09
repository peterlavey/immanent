class_name EvolutionFirst extends BaseNode

var DIALOGUES: GDScript
var terminalMsg: Terminal
var dramaticMsg: Dramatic

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	terminalMsg = Load.src("utils/message/terminal", DIALOGUES.INITIALIZATION)
	dramaticMsg = Load.src("utils/message/dramatic", DIALOGUES.THE_WAY)
	terminalMsg.connect("on_finish", self, "show_second_messages")
	dramaticMsg.connect("on_finish", self, "test")

func start()-> void:
	show_first_messages()

func show_first_messages():
	add_child(terminalMsg)
	terminalMsg.start()

func show_second_messages():
	remove_child(terminalMsg)
	add_child(dramaticMsg)
	dramaticMsg.start()

func test():
	print("on finish")
