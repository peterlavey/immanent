class_name Prologue extends BaseNode

var image_manager: ImageManager
var message: Message
var images: Array
var DIALOGUES: GDScript
var picure_options: PictureOptions
var music_player: MusicPlayer
var songs: Array = ["res://assets/prologue/music/prologue.ogg"]
var folder_manager: FolderManager
#class_name Playlist extends Nodehttps://open.spotify.com/track/073qwNpeFHepLKcTS43WWT?si=f4AoHBqwQqye16sew5da0A

func _init():
	config_pictures()
	
	folder_manager = Load.src("utils/directory/folder_manager")
	images = folder_manager.get_directory_list("res://assets/prologue/images", "png", true)
	music_player = Load.src("utils/music/music_player")
	DIALOGUES = Load.src("resources/dialogues")
	image_manager = Load.src("utils/image_manager/image_manager", images, picure_options)
	message = Load.src("utils/message/message")
	
	config_music()

func config_music()-> void:
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
	play_music()
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
		if DIALOGUES.PROLOGUE.empty():
			#iniciar juego o siguiente secuencia
			emit_signal("next")
			pass
		else:
			if DIALOGUES.PROLOGUE[0] == DIALOGUES.NEXT:
				show_next_image()
			else:
				show_next_text()
	else:
		message.complete()

func show_next_image()-> void:
	DIALOGUES.PROLOGUE.pop_front()
	image_manager.next()
	if !DIALOGUES.PROLOGUE.empty():
		if DIALOGUES.PROLOGUE[0] != DIALOGUES.NEXT:
			message.show_message(DIALOGUES.PROLOGUE.pop_front())

func show_next_text()-> void:
	message.show_message(DIALOGUES.PROLOGUE.pop_front())
