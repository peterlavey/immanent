class_name Prologue extends BaseNode

var image_manager: ImageManager
var message: Message
var delay: Delay
var images: Array = [
	"res://assets/prologue/1.png",
	"res://assets/prologue/2.png",
	"res://assets/prologue/3.png",
	"res://assets/prologue/4.png",
]
var messages: Array = [
	"weeeena wenaaaaas",
	"este es un test de mensajes",
	"ha funcionado!"
]

func _init():
	image_manager = Load.src("utils/image_manager/image_manager", images)
	message = Load.src("utils/message/message")
	delay = Load.src("utils/timer/delay", "show_next_message", 2)

func start()-> void:
	show_images()
	show_messages()

func show_images()-> void:
	add_child(image_manager)

func show_messages():
	add_child(message)
	add_child(delay)
	message.show_message(messages.pop_front())
	delay.start()

func show_next_message():
	if message.is_complete:
		var text = messages.pop_front()
		message.show_message(text)
		image_manager.next()
	else:
		message.complete()
	
	if messages.empty():
		delay.stop()

