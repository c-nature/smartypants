# This is the complete script for your GlobalAudioPlayer.gd

extends Node

# Get references to both audio players in the scene
@onready var ui_sound_player = $UISoundPlayer
@onready var music_player = $MusicPlayer

func _ready():
	# Load the sounds for each player when the game starts
	ui_sound_player.stream = load("res://Sounds/ui-click-43196.mp3")
	music_player.stream = load("res://Sounds/PresidentialPongSong.mp3")
	music_player.finished.connect(music_player.play)


# --- New functions to control your audio ---

# Call this to play the short UI click sound
func play_ui_click():
	ui_sound_player.play()

# Call this to start the music (if it's not already playing)
func play_menu_music():
	if not music_player.playing:
		music_player.play()

# Call this to stop the music
func stop_music():
	music_player.stop()
