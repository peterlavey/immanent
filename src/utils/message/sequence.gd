class_name Sequence extends BaseNode

signal on_finish
var DIALOGUES: Array
const NEXT = "->"
var image_manager: ImageManager
var message: Message
var images: Array
var picure_options: PictureOptions
var music_player: MusicPlayer
var folder_manager: FolderManager

func _init(dialogues, imgPath, songs = []):
	config_pictures()
	DIALOGUES = dialogues
	folder_manager = Load.src("utils/directory/folder_manager")
	images = folder_manager.get_directory_list("res://assets/" + imgPath, "png", true)
	image_manager = Load.src("utils/image_manager/image_manager", images, picure_options)
	message = Load.src("utils/message/message")
	
	if !songs.empty():
		music_player = Load.src("utils/music/music_player")
		config_music(songs)
		play_music()

func config_music(songs)-> void:
	music_player.set_songs(songs)
	music_player.shuffle = false

func config_pictures()-> void:
	picure_options = Load.src("utils/image_manager/picture_options")
	picure_options.scale = 50
	picure_options.h_align = POSITION.CENTER
	picure_options.v_align = POSITION.TOP
	picure_options.padding = 10

func config_message()-> void:
	var margin = 30
	var screen_height = OS.get_window_size().y
	var picture_x = image_manager.images_loaded[0].position.x
	var picture_w = image_manager.images_loaded[0].width
	var picture_h = image_manager.images_loaded[0].height

	var position = Vector2(picture_x, (screen_height * .5) + picure_options.padding + margin)
	message.set_position(position)
	message.set_size(Vector2(picture_w, picture_h))
	message.label.set_size(Vector2(picture_w, picture_h))

func _process(delta):
	listen_start_button()

func listen_start_button()-> void:
	if Input.is_action_just_released("ui_accept"):
		show_next_message()

func start()-> void:
	show_images()
	show_messages()

func play_music()-> void:
	add_child(music_player)
	music_player.start()

func show_images()-> void:
	add_child(image_manager)

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
			if DIALOGUES[0] == NEXT:
				show_next_image()
			else:
				show_next_text()
	else:
		message.complete()

func show_next_image()-> void:
	DIALOGUES.pop_front()
	image_manager.next()
	if !DIALOGUES.empty():
		if DIALOGUES[0] != NEXT:
			message.show_message(DIALOGUES.pop_front())

func show_next_text()-> void:
	message.show_message(DIALOGUES.pop_front())
