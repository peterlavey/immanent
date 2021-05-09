class_name Dramatic extends BaseNode

signal on_finish
var message: Message
var DIALOGUES: Array

func _init(dialogues = []):
	DIALOGUES = dialogues
	message = Load.src("utils/message/message", Message.TYPE.FADE)

func config_message()-> void:
	var screen_weigth = OS.get_window_size().x
	var screen_height = OS.get_window_size().y
	var position = Vector2(screen_weigth * 0.15, screen_height * 0.35)
	message.font.size = 24
	message.set_position(position)
	message.label.set_size(Vector2((screen_weigth * 0.7), (screen_height * 0.75)))

func _process(delta):
	listen_start_button()

func listen_start_button()-> void:
	if Input.is_action_just_released("ui_accept"):
		show_next_message()

func start()-> void:
	show_messages()

func show_messages():
	add_child(message)
	config_message()
	show_next_message()

func show_next_message():
	if message.is_complete:
		if DIALOGUES.empty():
			emit_signal("on_finish")
			pass
		else:
			show_next_text()
	else:
		message.complete()

func show_next_text()-> void:
	message.show_message(DIALOGUES.pop_front())

func set_dialogues(dialogues):
	DIALOGUES = dialogues
