class_name Message extends BaseNode

var label: RichTextLabel
var delay: Delay
var split_message: Array
var text: String
var font: DynamicFont
var font_size: int
var is_complete: bool
var transition: Transition
var type: int
const TYPE := {
	"TYPEWRITER": 1,
	"FADE": 2
}

func _init(type = 1):
	font = Load.font("Ubuntu-Regular")
	config_label()
	
	self.type = type

	if type == TYPE.TYPEWRITER:
		init_typewriter()
	elif type == TYPE.FADE:
		init_fade()

func show_message(message: String):
	is_complete = false

	if type == TYPE.TYPEWRITER:
		msg_typewriter(message)
	elif type == TYPE.FADE:
		msg_fade(message)

func complete()-> void:
	if type == TYPE.TYPEWRITER:
		complete_typewriter()
	elif type == TYPE.FADE:
		complete_fade()

func config_delay()-> void:
	add_child(delay)

func config_label()-> void:
	label = RichTextLabel.new()
	label.bbcode_enabled = true
	label.set("custom_fonts/normal_font", font)
	label.set("custom_colors/default_color", Color.white)
	add_child(label)

#Typewriter Mode: show message like a dialogue
func init_typewriter():
	delay = Load.src("utils/timer/delay", "show_next_char")
	add_child(delay)

func clean_typewriter():
	text = ""
	delay.stop()
	split_message = []

func msg_typewriter(message):
	clean_typewriter()
	split_message(message)
	delay.start()

func complete_typewriter()-> void:
	delay.stop()
	text += PoolStringArray(split_message).join("")
	label.set_bbcode(text)
	is_complete = true

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

#Fade Mode: show message with fade in & fade out effects
func init_fade():
	transition = Load.src("utils/image_manager/transition")
	transition.connect("on_blackout", self, "show_next_message")

func clean_fade():
	text = ""

func msg_fade(message):
	clean_fade()
	fade_effect(message)
	#show_next_message(message)

func complete_fade()-> void:
	show_next_message()

func show_next_message():
	print("show_next_message")
	label.set_bbcode(text)
	is_complete = true

func fade_effect(message):
	print("fade_effect: " + message)
	text = message
	remove_child(transition)
	add_child(transition)
	transition.speed = 5
	transition.light_to_dark_to_light()
