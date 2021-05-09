class_name Perception extends BaseNode

var DIALOGUES: GDScript
var dramaticMsg: Dramatic
var dangerParticle

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	dramaticMsg = Load.src("utils/message/dramatic")
	dangerParticle = Load.src("mechanics/role/player/perception/danger")
	#dramaticMsg.connect("on_finish", self, "show_perception")

func start()-> void:
	danger()
	add_child(dramaticMsg)

func danger():
	add_child(dangerParticle)
	dramaticMsg.set_dialogues(DIALOGUES.PERCEPTION.DANGER)
	dramaticMsg.start()
