extends Control

# Path to the Paddle Selection scene.
const PADDLE_SELECT_SCENE_PATH = "res://Scenes/PaddleSelectScreen.tscn"

# Note: The UI_CLICK_SOUND_PATH is no longer needed here, as it's handled by GlobalAudio.gd

@onready var one_player_button = $UIContainer/OnePlayerButton
@onready var two_players_button = $UIContainer/TwoPlayersButton

func _ready():
	# The logic to load sounds has been moved to GlobalAudio.gd,
	# so the _ready function can be left empty or removed if not needed for other things.
	pass

func _on_OnePlayerButton_pressed():
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()
		
	# Set the game mode in the GameManager singleton.
	GameManager.current_game_mode = GameManager.GameMode.ONE_PLAYER
	
	# Wait a moment for the sound to play, then change the scene.
	get_tree().create_timer(0.2).timeout.connect(func():
		get_tree().change_scene_to_file(PADDLE_SELECT_SCENE_PATH)
	)

func _on_TwoPlayersButton_pressed():
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()

	# Set the game mode in the GameManager singleton.
	GameManager.current_game_mode = GameManager.GameMode.TWO_PLAYERS
	
	# Wait a moment for the sound to play, then change the scene.
	get_tree().create_timer(0.2).timeout.connect(func():
		get_tree().change_scene_to_file(PADDLE_SELECT_SCENE_PATH)
	)
