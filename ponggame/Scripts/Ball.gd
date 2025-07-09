extends CharacterBody2D

@export var initial_speed = 500 # Initial speed of the ball, adjustable in the Inspector
@export var max_speed = 1200 # Maximum speed the ball can reach
@export var speed_increase_on_paddle_hit = 1.05 # Multiplier for speed increase after paddle hit (e.g., 1.05 for 5% increase)
@export var max_deflection_angle_degrees = 60 # Max angle in degrees the ball can deflect after hitting a paddle

@onready var particle_trail = $CPUParticles2D # Get reference to the particle trail node

# Define a minimum horizontal speed to prevent getting stuck vertically
const MIN_HORIZONTAL_SPEED = 150 # Adjust this value as needed
const MIN_BOUNCE_SPEED = 200 # Minimum speed after any collision to prevent freezing

func _ready():
	# MODIFIED: Call reset_ball_position instead of reset_ball
	reset_ball_position() # Ensure ball starts from center, but stopped
	particle_trail.emitting = false # Ensure particles are not emitting initially

func _physics_process(delta): # Use 'delta' for frame-rate independence
	# Get a reference to the parent node (Main.gd) to check game_active state
	var main_node = get_parent()
	
	# Only move the ball if the game is actively running AND the ball is NOT waiting for launch
	# Corrected: Directly access 'game_active' and 'ball_waiting_for_launch' properties
	if main_node is Node and main_node.game_active and not main_node.ball_waiting_for_launch:
		# Start emitting particles once the ball begins moving
		if not particle_trail.emitting and velocity.length() > 0.1: # Small threshold to avoid immediate emission
			particle_trail.emitting = true

		var collision = move_and_collide(velocity * delta)

		if collision:
			var collider = collision.get_collider() # Get the node that was collided with

			if collider is CharacterBody2D: # Hit a paddle (PlayerPaddle or AIPaddle)
				# Tell the main scene to play a sound
				get_parent().play_random_ball_hit_sound()
				
				# Calculate hit position relative to paddle center for varied bounce angles
				# Assuming paddles have a CollisionShape2D named "CollisionShape2D"
				var paddle_collision_shape = collider.get_node_or_null("CollisionShape2D")
				if paddle_collision_shape and paddle_collision_shape.shape is RectangleShape2D:
					var paddle_height = paddle_collision_shape.shape.extents.y * 2
					var hit_pos_y_on_paddle = global_position.y - collider.global_position.y
					var normalized_hit = clamp(hit_pos_y_on_paddle / (paddle_height / 2), -1.0, 1.0) # Value from -1.0 to 1.0

					# Calculate new angle based on hit position
					var new_angle = normalized_hit * deg_to_rad(max_deflection_angle_degrees)

					# Reflect velocity based on collision normal
					velocity = velocity.bounce(collision.get_normal())
					# Apply angle adjustment
					velocity = velocity.rotated(new_angle)

					# --- IMPROVED LOGIC TO PREVENT GETTING STUCK ON PADDLE ---
					var current_speed_after_bounce = velocity.length()

					# Ensure minimum horizontal speed immediately after paddle bounce
					if abs(velocity.x) < MIN_HORIZONTAL_SPEED:
						velocity.x = sign(velocity.x) * MIN_HORIZONTAL_SPEED if velocity.x != 0 else MIN_HORIZONTAL_SPEED
						# Re-normalize to maintain the overall speed, ensuring it's at least MIN_BOUNCE_SPEED
						velocity = velocity.normalized() * max(current_speed_after_bounce, MIN_BOUNCE_SPEED)
					# If horizontal speed was fine, but overall speed is too low
					elif current_speed_after_bounce < MIN_BOUNCE_SPEED:
						velocity = velocity.normalized() * MIN_BOUNCE_SPEED
					# --- END IMPROVED LOGIC ---

					# Increase speed slightly after hitting a paddle, then cap it
					velocity *= speed_increase_on_paddle_hit
					velocity = velocity.limit_length(max_speed)
				else:
					# Fallback if paddle collision shape is not found or not a RectangleShape2D
					velocity = velocity.bounce(collision.get_normal())


			elif collider is StaticBody2D: # Hit a StaticBody2D (TopWall or BottomWall)
				# Tell the main scene to play a sound
				get_parent().play_random_ball_hit_sound()
				
				velocity = velocity.bounce(collision.get_normal())
				# For walls, also ensure minimum speed
				if velocity.length() < MIN_BOUNCE_SPEED:
					velocity = velocity.normalized() * MIN_BOUNCE_SPEED
				# And for walls, ensure minimum horizontal speed if it's a top/bottom wall
				# This helps prevent the ball from sliding along the top/bottom walls too slowly
				if abs(velocity.x) < MIN_HORIZONTAL_SPEED and (collision.get_normal().y != 0): # Only if it hit a horizontal wall
					velocity.x = sign(velocity.x) * MIN_HORIZONTAL_SPEED if velocity.x != 0 else MIN_HORIZONTAL_SPEED
					velocity = velocity.normalized() * velocity.length()
	else:
		# If game is not active or ball is waiting for launch, ensure ball is stopped and particles are off
		velocity = Vector2.ZERO
		particle_trail.emitting = false


# MODIFIED: New function to just reset the ball's position and stop it
func reset_ball_position():
	# Stop emitting particles when the ball resets
	particle_trail.emitting = false
	# Get the global position of the BallSpawnPosition node
	# Ensure BallSpawnPosition exists, otherwise fallback to center of screen
	var spawn_node = get_parent().get_node_or_null("BallSpawnPosition")
	if spawn_node:
		global_position = spawn_node.global_position
	else:
		# Fallback to center of the viewport if BallSpawnPosition is not found
		global_position = get_viewport_rect().size / 2
	velocity = Vector2.ZERO # Stop the ball's movement

# NEW: Function to launch the ball with initial velocity
func launch_ball():
	# Start emitting particles when the ball is launched
	particle_trail.emitting = true
	# Reset velocity to initial state with a new random direction
	randomize() # Initialize random number generator (good practice, though Godot often handles it)
	var start_angle_range = deg_to_rad(45) # Angle range for initial launch (e.g., -45 to 45 degrees from horizontal)
	var start_angle = randf_range(-start_angle_range, start_angle_range)

	if randf() < 0.5: # 50% chance to go left, 50% chance to go right
		# For left, add 180 degrees (PI radians) to flip direction
		start_angle += PI
	
	velocity = Vector2(initial_speed, 0).rotated(start_angle)
	# Ensure the initial velocity also adheres to the minimum horizontal speed
	if abs(velocity.x) < MIN_HORIZONTAL_SPEED:
		velocity.x = sign(velocity.x) * MIN_HORIZONTAL_SPEED if velocity.x != 0 else MIN_HORIZONTAL_SPEED
		velocity = velocity.normalized() * initial_speed # Re-normalize to initial speed after adjustment


func _on_ball_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
