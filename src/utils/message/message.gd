class_name Message extends BaseNode

var label: RichTextLabel
var delay: Delay
var split_message: Array
var text: String
var font: DynamicFont
var font_size: int
var is_complete: bool

func _init():
	font = Load.font("Ubuntu-Regular")
	delay = Load.src("utils/timer/delay", "show_next_char")
	
	config_label()
	config_delay()

func show_message(message: String):
	clean()
	is_complete = false
	split_message(message)
	delay.start()

func split_message(message: String)-> void:
	var tag = ""
	for i in message.length():
		if message[i] == "[" || tag != "":
			tag += message[i]
			if message[i] == "]":
				split_message.append(tag)
				tag = ""
		elif tag == "":
			split_message.append(message[i])

func show_next_char()-> void:
	text += split_message.pop_front()
	label.set_bbcode(text)
	
	if split_message.empty():
		is_complete = true
		delay.stop()

func complete()-> void:
	delay.stop()
	text += PoolStringArray(split_message).join("")
	label.set_bbcode(text)
	is_complete = true

func clean()-> void:
	text = ""
	delay.stop()
	split_message = []

func config_delay()-> void:
	add_child(delay)

func config_label()-> void:
	label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.set("custom_fonts/normal_font", font)
	label.set("custom_colors/default_color", Color.white)
	add_child(label)
