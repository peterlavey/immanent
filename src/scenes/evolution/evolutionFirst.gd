class_name EvolutionFirst extends BaseNode

var DIALOGUES: GDScript
var terminalMsg: Terminal
var dramaticMsg: Dramatic
var perception: Perception

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	terminalMsg = Load.src("utils/message/terminal", DIALOGUES.INITIALIZATION)
	dramaticMsg = Load.src("utils/message/dramatic", DIALOGUES.THE_WAY)
	perception = Load.src("mechanics/role/player/perception/perception")
	terminalMsg.connect("on_finish", self, "show_second_messages")
	dramaticMsg.connect("on_finish", self, "show_perception")

func start()-> void:
	show_perception()

func show_first_messages():
	add_child(terminalMsg)
	terminalMsg.start()

func show_second_messages():
	remove_child(terminalMsg)
	add_child(dramaticMsg)
	dramaticMsg.start()

func show_perception():
	remove_child(dramaticMsg)
	add_child(perception)
	perception.start()
