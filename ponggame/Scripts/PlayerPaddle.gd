# PlayerPaddle.gd
extends CharacterBody2D # This script extends CharacterBody2D for physics-based movement

@export var speed = 600 # Speed of the paddle, adjustable in the Inspector

# _physics_process is called every physics frame, ensuring consistent movement
func _physics_process(_delta): # _delta is used to acknowledge the parameter without direct usage
	# Initialize velocity to zero, only affecting Y-axis for paddle movement
	velocity.x = 0
	velocity.y = 0

	# Check for input to move up or down
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1

	# Normalize velocity to ensure consistent speed (if diagonal movement were possible)
	# and apply speed.
	velocity = velocity.normalized() * speed

	# Move the character body using its velocity.
	# move_and_slide() handles collision and delta calculation internally in Godot 4.
	move_and_slide()

	# Clamp the paddle's position to stay within screen bounds
	# Adjusted for 1280x720 resolution
	position.y = clamp(position.y, -1000, 1000) # 720 - 50 = 670
