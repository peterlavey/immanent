extends Node

# AudioManager singleton for managing global music and SFX.
# Registered as an Autoload.

@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()

var music_bus: int = 0
var sfx_bus: int = 0

func _ready() -> void:
	# Add the music player as a child to the singleton
	add_child(music_player)
	
	# Ensure music continues playing even when the game is paused
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set up the music player to use the "Music" bus
	music_bus = AudioServer.get_bus_index("Music")
	if music_bus == -1:
		# Fallback if the bus doesn't exist yet (handled in project settings or bus layout)
		music_player.bus = "Master"
	else:
		music_player.bus = "Music"
	
	# Start background music if available
	play_music("res://assets/audio/music/hope.mp3")

func play_music(music_path: String) -> void:
	if ResourceLoader.exists(music_path):
		var stream = load(music_path)
		if stream is AudioStream:
			# Set the stream to loop if it's an MP3
			if stream is AudioStreamMP3:
				stream.loop = true
			
			music_player.stream = stream
			music_player.play()
			print("AudioManager: Playing music from ", music_path)
		else:
			push_warning("AudioManager: Resource at ", music_path, " is not an AudioStream.")
	else:
		push_warning("AudioManager: Music file not found at ", music_path)

func play_sfx(sfx_path: String, volume_db: float = 0.0) -> void:
	if ResourceLoader.exists(sfx_path):
		var stream = load(sfx_path)
		if stream is AudioStream:
			var sfx_player = AudioStreamPlayer.new()
			sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(sfx_player)
			sfx_player.stream = stream
			sfx_player.volume_db = volume_db
			
			sfx_bus = AudioServer.get_bus_index("SFX")
			if sfx_bus != -1:
				sfx_player.bus = "SFX"
			
			sfx_player.play()
			# Clean up the SFX player when finished
			sfx_player.finished.connect(sfx_player.queue_free)
		else:
			push_warning("AudioManager: Resource at ", sfx_path, " is not an AudioStream.")
	else:
		push_warning("AudioManager: SFX file not found at ", sfx_path)
