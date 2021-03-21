class_name Game extends Node2D

var images: Array = [
	"res://assets/prologue/1.png",
	"res://assets/prologue/2.png",
	"res://assets/prologue/3.png",
	"res://assets/prologue/4.png",
]
var image_manager = load("res://src/utils/image_manager/image_manager.gd").new(images)

var message = load("res://src/utils/message/message.gd").new()
var delay = load("res://src/utils/timer/delay.gd").new("show_next_message", 2)
var messages: Array = [
	"weeeena wenaaaaas",
	"este es un test de mensajes",
	"ha funcionado!"
]


func _ready():
	init()

func init()-> void:
	show_prologue()
	show_messages()

func show_prologue()-> void:
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
