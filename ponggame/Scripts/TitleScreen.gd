extends Control

# Path to the Mode Selection scene.
const MODE_SELECT_SCENE_PATH = "res://Scenes/ModeSelectScreen.tscn"

# Note: The UI_CLICK_SOUND_PATH is no longer needed here, as it's handled by GlobalAudio.gd

@onready var start_game_button = $UIContainer/StartGameButton

# The transition nodes can be uncommented when you add them to your scene.
# @onready var transition_canvas_layer = $TransitionCanvasLayer
# @onready var transition_rect = $TransitionCanvasLayer/TransitionRect
# @onready var transition_anim_player = $TransitionCanvasLayer/TransitionAnimPlayer

# This is the single, combined _ready function.
func _ready():
	# Start the menu music as soon as the game launches.
	GlobalAudio.play_menu_music()
	
	# Allow the _input function to detect key presses like "ui_accept" (Enter key).
	set_process_input(true)
	
	# The code to load the UI click sound has been moved to GlobalAudio.gd,
	# so it is no longer needed in this script.

	# Connect animation signals if you add the transition nodes.
	# if transition_anim_player:
	# 	transition_anim_player.animation_finished.connect(Callable(self, "_on_transition_animation_finished"))


# This function listens for the Enter key to be pressed.
func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_StartGameButton_pressed()

# This is the single, combined function for when the start button is pressed.
func _on_StartGameButton_pressed():
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()

	# Disable the button to prevent it from being clicked again during the transition.
	start_game_button.disabled = true

	# Wait a moment for the sound to play, then change the scene.
	get_tree().create_timer(0.2).timeout.connect(func():
		# This function handles the actual scene change.
		_on_transition_animation_finished("fade_out")
	)

# This function changes the scene.
func _on_transition_animation_finished(anim_name: String):
	if anim_name == "fade_out":
		get_tree().change_scene_to_file(MODE_SELECT_SCENE_PATH)
