class_name Game extends Node2D

var message = load("res://src/message/message.gd").new()
var delay = load("res://src/utils/delay.gd").new("show_next_message", 2)
var messages: Array = ["weeeena wenaaaaas", "este es un test de mensajes", "ha funcionado!"]

func _ready():
	init()

func init()-> void:
	add_child(message)
	add_child(delay)
	message.show_message(messages.pop_front())
	delay.start()
	

func show_next_message():
	if message.is_complete:
		var text = messages.pop_front()
		message.show_message(text)
	else:
		message.complete()
	
	if messages.empty():
		delay.stop()
