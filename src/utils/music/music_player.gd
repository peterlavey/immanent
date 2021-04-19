class_name MusicPlayer extends AudioStreamPlayer2D

export var songs: Array
export var shuffle: bool = true
export var currentSong: String
var currentIndex:int = 0
var input
var show_info: bool = false

func _init(show_info = false):
	self.show_info = show_info
	if show_info:
		config_input()
	connect("finished", self, "next_song")
	pass

func set_songs(_songs)-> void:
	songs = _songs
	if shuffle:
		songs.shuffle()

func next_song()-> void:
	stop()
	set_next_song()
	start()
	pass

func start():
	set_current_song()
	load_song()
	play()

func set_current_song():
	currentSong = songs[currentIndex]
	if show_info:
		input.set_text(currentSong.split(".")[0])

func load_song():
	var song = load(currentSong)
	stream = song

func set_next_song():
	if currentIndex < songs.size() -1:
		currentIndex += 1
	else:	
		currentIndex = 0

func config_input() -> void:
	input = TextEdit.new()
	input.rect_size.x = 500
	input.rect_size.y = 30
	
	add_child(input)
	
	pass

func _process(delta):
	if song_is_finished():
		next_song()
	pass

func song_is_finished()-> bool:
	return get_playback_position() > stream.get_length() -0.05
