extends CharacterBody2D # This script extends CharacterBody2D

@export var speed = 600 # AI speed, slightly slower than player for challenge
@onready var ball = get_parent().get_node("Ball") # Get a reference to the ball node when ready



func _physics_process(_delta): # _delta is used to acknowledge the parameter
	var target_y = ball.position.y # AI wants to move to the ball's Y position
	var direction = 0 # Initialize direction
	

	if position.y < target_y:
		direction = 1 # Move down
	elif position.y > target_y:
		direction = -1 # Move up

	# Ensure velocity's X component is always 0 for purely vertical movement
	velocity = Vector2(0, direction * speed) # Set vertical velocity
	move_and_slide() # Move the character body

	# Explicitly reset X position after movement to prevent unwanted horizontal drift
	position.x = 40.0 # Force the X position back to 40.0 every frame

	# Clamp the paddle's Y position to stay within screen bounds
	# Adjusted for 1280x720 resolution, assuming paddle height allows 50px buffer top/bottom
	position.y = clamp(position.y, 50, 670) # 720 - 50 (top margin) - 50 (bottom margin, assuming paddle is 100px tall) = 620. So 670 is correct if 50 is the center of the paddle from the top/bottom.
