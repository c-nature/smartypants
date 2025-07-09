extends Node2D

var player_score = 0
var ai_score = 0 # This variable is used for AI score in 1-player, and Player 2 score in 2-player mode.

# Timer and Term variables
var term_duration_seconds = 60.0 # Each term will be 1 minute (60 seconds)
var current_term = 1
var max_terms = 2 # You can adjust the total number of terms here
var time_left_in_term = 0.0
var game_active = false # Controls if the game (and timer) is actively running
var ball_waiting_for_launch = false # True when ball is centered, waiting for player input to launch

@onready var player_score_label = $Player1Score
@onready var ai_score_label = $ComputerScore # Renamed for clarity, but still refers to the same label
@onready var ball = $Ball
@onready var player1_paddle = $PlayerPaddle # Assuming PlayerPaddle is Player 1
@onready var ai_paddle = $AIPaddle
@onready var player2_paddle = $Player2Paddle # Assuming you have a Player2Paddle node
@onready var timer_label = $TimerLabel # Reference to the Label node for the timer display
@onready var winner_display_container = $TextureRect # NEW: Reference to the parent TextureRect
@onready var winner_label = $TextureRect/WinnerLabel # Reference to a Label node to display the winner

# NEW: AudioStreamPlayer2D nodes for ball hit sounds
@onready var ball_hit_sound1 = $BallHitSound1 # Path to your first AudioStreamPlayer2D node
@onready var ball_hit_sound2 = $BallHitSound2 # Path to your second AudioStreamPlayer2D node
@onready var ball_hit_sound3 = $BallHitSound3 # Path to your third AudioStreamPlayer2D node

var ball_hit_sounds = [] # Array to hold all ball hit sound players

# Define game modes (already in GameManager, but kept here for clarity if needed locally)
enum GameMode { ONE_PLAYER, TWO_PLAYERS }


func _ready():
	# Initialize random number generator for sound selection
	randomize()

	# Apply selected paddle textures
	_apply_paddle_textures()

	setup_game_mode()
	update_score_display()
	GlobalAudio.stop_music()
	
	# Hide the winner display container initially
	if winner_display_container:
		winner_display_container.hide()

	# Initialize and start the first term (ball will wait for launch)
	_start_term(current_term)

	# Load ball hit sound streams and add them to the array
	# IMPORTANT: Ensure these paths are correct and match your actual files
	if ball_hit_sound1:
		ball_hit_sound1.stream = load("res://Sounds/pongballsound1.mp3")
		ball_hit_sounds.append(ball_hit_sound1)
	if ball_hit_sound2:
		ball_hit_sound2.stream = load("res://Sounds/pongballsound2.mp3")
		ball_hit_sounds.append(ball_hit_sound2)
	if ball_hit_sound3:
		ball_hit_sound3.stream = load("res://Sounds/pongballsound3.mp3")
		ball_hit_sounds.append(ball_hit_sound3)

	# Connect the ball's body_entered signal to play a sound
	# This assumes your 'Ball' node has an Area2D child (e.g., named 'CollisionDetector')
	# that emits the 'body_entered' signal.
	if ball and ball.has_node("CollisionDetector"): # Check if Ball node exists and has the Area2D child
		ball.get_node("CollisionDetector").body_entered.connect(Callable(self, "_on_ball_body_entered"))
		print("DEBUG: Ball CollisionDetector found and signal connected in _ready.") # Debug print
	else:
		print("DEBUG: Ball or CollisionDetector not found in _ready, or signal not connected.") # Debug print


func _process(delta):
	# This function runs every frame and is used to update the timer.
	if game_active:
		time_left_in_term -= delta
		if time_left_in_term <= 0:
			time_left_in_term = 0
			_end_term()
		update_score_display() # Update display frequently to show countdown

func _input(event):
	# Listen for input to launch the ball
	if event.is_action_pressed("ui_accept") and game_active and ball_waiting_for_launch:
		ball_waiting_for_launch = false
		ball.launch_ball() # Call the new launch function in Ball.gd

func _apply_paddle_textures():
	# Player 1's paddle
	# IMPORTANT: Ensure PlayerPaddle has a Sprite2D child named "Sprite2D"
	if player1_paddle and player1_paddle.has_node("Sprite2D"):
		var sprite = player1_paddle.get_node("Sprite2D")
		if GameManager.player1_paddle_texture_path != "":
			sprite.texture = load(GameManager.player1_paddle_texture_path)
		else: # Fallback if no selection was made (shouldn't happen if confirm button is disabled)
			sprite.texture = load(GameManager.available_paddle_textures["Joe Biden"]) # Fallback to Joe Biden
		sprite.flip_h = false # Player 1 paddle faces left (default)

	match GameManager.current_game_mode:
		GameMode.ONE_PLAYER:
			# AI Paddle
			# IMPORTANT: Ensure AIPaddle has a Sprite2D child named "Sprite2D"
			if ai_paddle and ai_paddle.has_node("Sprite2D"):
				var sprite = ai_paddle.get_node("Sprite2D")
				if GameManager.ai_paddle_texture_path != "":
					sprite.texture = load(GameManager.ai_paddle_texture_path)
				else: # Fallback
					sprite.texture = load(GameManager.available_paddle_textures["Donald Trump"]) # Fallback to Donald Trump
				sprite.flip_h = true # AI paddle faces right (flipped)
		GameMode.TWO_PLAYERS:
			# Player 2 Paddle
			# IMPORTANT: Ensure Player2Paddle has a Sprite2D child named "Sprite2D"
			if player2_paddle and player2_paddle.has_node("Sprite2D"):
				var sprite = player2_paddle.get_node("Sprite2D")
				if GameManager.player2_paddle_texture_path != "":
					sprite.texture = load(GameManager.player2_paddle_texture_path)
				else: # Fallback
					sprite.texture = load(GameManager.available_paddle_textures["Donald Trump"]) # Fallback to Donald Trump
				sprite.flip_h = true # Player 2 paddle faces right (flipped)

func setup_game_mode():
	# Use GameManager's current_game_mode
	match GameManager.current_game_mode:
		GameMode.ONE_PLAYER:
			ai_paddle.show()
			ai_paddle.set_process(true)
			if player2_paddle:
				player2_paddle.hide()
				player2_paddle.set_process(false)
		GameMode.TWO_PLAYERS:
			ai_paddle.hide()
			ai_paddle.set_process(false)
			if player2_paddle:
				player2_paddle.show()
				player2_paddle.set_process(true)
			# Ensure Player 2 paddle script (Player2Paddle.gd) is using Player 2 input actions.

func _on_LeftGoal_body_entered(body):
	# This function is called when the ball enters the LEFT goal (meaning the LEFT player/AI missed).
	# The 'body' argument here refers to the node that entered the goal.
	if body.name == "Ball": # This check is for the root node of the Ball scene
		if GameManager.current_game_mode == GameMode.ONE_PLAYER:
			# In 1-player mode, if ball enters left goal, AI scores (player missed).
			ai_score += 1
		elif GameManager.current_game_mode == GameMode.TWO_PLAYERS:
			# In 2-player mode, if ball enters left goal, Player 2 scores (Player 1 missed).
			ai_score += 1 # ai_score variable is repurposed for Player 2's score
		update_score_display()
		ball.reset_ball_position() # Only reset ball position, don't launch immediately
		ball_waiting_for_launch = true # Wait for player input to launch

func _on_RightGoal_body_entered(body):
	# This function is called when the ball enters the RIGHT goal (meaning the RIGHT player/AI missed).
	# The 'body' argument here refers to the node that entered the goal.
	if body.name == "Ball": # This check is for the root node of the Ball scene
		if GameManager.current_game_mode == GameMode.ONE_PLAYER:
			# In 1-player mode, if ball enters right goal, Player 1 scores (AI missed).
			player_score += 1
		elif GameManager.current_game_mode == GameMode.TWO_PLAYERS:
			# In 2-player mode, if ball enters right goal, Player 1 scores (Player 2 missed).
			player_score += 1
		update_score_display()
		ball.reset_ball_position() # Only reset ball position, don't launch immediately
		ball_waiting_for_launch = true # Wait for player input to launch

func update_score_display():
	player_score_label.text = str(player_score)
	ai_score_label.text = str(ai_score)
	
	# Format time for display (e.g., 01:00) and show current term
	var minutes = int(time_left_in_term / 60.0)
	var seconds = int(fmod(time_left_in_term, 60.0))
	timer_label.text = "%02d:%02d | Term %d/%d" % [minutes, seconds, current_term, max_terms]

func _start_term(term_number: int):
	# Resets the game state and starts a new term
	current_term = term_number
	time_left_in_term = term_duration_seconds
	game_active = true # Allow game elements to move
	ball.reset_ball_position() # Only reset ball position, don't launch immediately
	ball_waiting_for_launch = true # Wait for player input to launch
	update_score_display() # Update display immediately
	# Hide winner display container if it was shown
	if winner_display_container:
		winner_display_container.hide()


func _end_term():
	# Handles the end of a term or the entire game
	game_active = false # Stop game elements from moving
	# Stop ball movement and particles
	ball.velocity = Vector2.ZERO
	ball.particle_trail.emitting = false

	if current_term < max_terms:
		# If there are more terms, prepare for the next one
		current_term += 1
		# Display a message like "Next Term Starting..."
		if winner_label and winner_display_container:
			winner_label.text = "Next Term Starting..."
			winner_display_container.show() # Show the parent TextureRect
		get_tree().create_timer(3.0).timeout.connect(func(): _start_term(current_term))
	else:
		# All terms completed, game over
		_determine_winner() # Determine and display the winner
		# Example: Transition back to TitleScreen after a delay
		get_tree().create_timer(5.0).timeout.connect(func(): get_tree().change_scene_to_file("res://Scenes/TitleScreen.tscn"))

func _determine_winner():
	var winner_text = ""
	var player1_name = GameManager._get_president_name_from_path(GameManager.player1_paddle_texture_path)
	var opponent_name = "" # Will be AI's name or Player 2's name
	if GameManager.current_game_mode == GameMode.ONE_PLAYER:
		opponent_name = GameManager._get_president_name_from_path(GameManager.ai_paddle_texture_path)
	elif GameManager.current_game_mode == GameMode.TWO_PLAYERS:
		opponent_name = GameManager._get_president_name_from_path(GameManager.player2_paddle_texture_path)

	if player_score > ai_score:
		winner_text = "%s WINS!!!" % player1_name
	elif ai_score > player_score:
		winner_text = "%s WINS!!!" % opponent_name
	else:
		winner_text = "IT'S A TIE!"
	
	if winner_label and winner_display_container:
		winner_label.text = winner_text
		winner_display_container.show() # Show the parent TextureRect

# NEW HELPER FUNCTION: To get the President's name from their texture path


func play_random_ball_hit_sound():
	if not ball_hit_sounds.is_empty():
		# Pick a random sound from the array and play it.
		var sound_to_play = ball_hit_sounds.pick_random()
		sound_to_play.play()


#Function to handle ball-paddle collisions and play random sound
func _on_ball_body_entered(body: Node2D):

	if body.name == "PlayerPaddle" or body.name == "AIPaddle" or body.name == "Player2Paddle":

		if not ball_hit_sounds.is_empty():
			var random_index = randi_range(0, ball_hit_sounds.size() - 1)
			var selected_sound_player = ball_hit_sounds[random_index]
			
			if selected_sound_player and selected_sound_player.stream:

				selected_sound_player.stop() # Stop any previous playback
				selected_sound_player.play()
 # Debug print
