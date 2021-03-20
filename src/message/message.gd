class_name Message extends Node2D

var label: Label
var delay = load("res://src/utils/delay.gd").new("show_next_char")
var split_message: Array
var text: String
var is_complete: bool

func _init():
	config_label()
	config_delay()

func show_message(message: String):
	clean()
	is_complete = false
	split_message(message)
	delay.start()

func split_message(message: String)-> void:
	for i in message.length():
		split_message.append(message[i])

func show_next_char()-> void:
	text += split_message.pop_front()
	label.set_text(text)
	
	if split_message.empty():
		is_complete = true
		delay.stop()

func complete()-> void:
	delay.stop()
	text += PoolStringArray(split_message).join("")
	label.set_text(text)
	is_complete = true

func clean()-> void:
	text = ""
	delay.stop()
	split_message = []

func config_delay()-> void:
	add_child(delay)

func config_label()-> void:
	label = Label.new()
	add_child(label)
