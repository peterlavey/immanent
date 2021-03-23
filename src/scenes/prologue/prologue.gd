class_name Prologue extends BaseNode

var image_manager: ImageManager
var message: Message
var images: Array = [
	"res://assets/prologue/1.png",
	"res://assets/prologue/2.png",
	"res://assets/prologue/3.png",
	"res://assets/prologue/4.png",
]
var DIALOGUES: GDScript

func _init():
	DIALOGUES = Load.src("resources/dialogues")
	image_manager = Load.src("utils/image_manager/image_manager", images)
	message = Load.src("utils/message/message")

func _process(delta):
	listen_start_button()

func listen_start_button()-> void:
	if Input.is_action_just_released("ui_accept"):
		show_next_message()

func start()-> void:
	show_images()
	show_messages()

func show_images()-> void:
	add_child(image_manager)

func show_messages():
	add_child(message)
	message.show_message(DIALOGUES.PROLOGUE.pop_front())

func show_next_message():
	if message.is_complete:
		if DIALOGUES.PROLOGUE.empty():
			#iniciar juego o siguiente secuencia
			pass
		else:
			var text = DIALOGUES.PROLOGUE.pop_front()
			if text == DIALOGUES.NEXT:
				image_manager.next()
				message.show_message(DIALOGUES.PROLOGUE.pop_front())
			else:
				message.show_message(text)
	else:
		message.complete()
