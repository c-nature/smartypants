extends CanvasLayer

func _ready():
	# Check if the current platform is a mobile device
	# Godot provides OS.has_feature() to check for specific platform features.
	# "mobile" is a common feature tag for mobile platforms (Android, iOS).
	if OS.has_feature("mobile"):
		# If on mobile, make the CanvasLayer visible (it's visible by default, but good to be explicit)
		self.visible = true
		print("Running on mobile device. Mobile UI enabled.")
	else:
		# If not on mobile (e.g., desktop browser, desktop app), hide the CanvasLayer
		self.visible = false
		print("Running on non-mobile device. Mobile UI disabled.")
