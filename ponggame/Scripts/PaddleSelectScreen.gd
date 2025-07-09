extends Control

# Path to the main game scene.
const MAIN_GAME_SCENE_PATH = "res://Scenes/Main.tscn"

# Note: The UI_CLICK_SOUND_PATH is no longer needed here, as it's handled by GlobalAudio.gd

# @onready variables for UI elements, ensuring paths are correct.
@onready var instruction_label: Label = $TopUIContainer/InstructionLabel
@onready var confirm_button: BaseButton = $TopUIContainer/ConfirmButton

# Player 1 elements
@onready var player1_selection_block: Control = $SelectionBlocksContainer/Player1SelectionBlock
@onready var player1_president_display: TextureRect = $SelectionBlocksContainer/Player1SelectionBlock/Player1PresidentControls/Player1PresidentDisplay
@onready var player1_left_arrow: BaseButton = $SelectionBlocksContainer/Player1SelectionBlock/Player1PresidentControls/Player1LeftArrow
@onready var player1_right_arrow: BaseButton = $SelectionBlocksContainer/Player1SelectionBlock/Player1PresidentControls/Player1RightArrow
@onready var player1_select_button: BaseButton = $SelectionBlocksContainer/Player1SelectionBlock/Player1SelectButton
@onready var player1_president_info_label: Label = $SelectionBlocksContainer/Player1SelectionBlock/Player1PresidentControls/Player1PresidentDisplay/Player1PresidentInfoLabel

# Player 2 elements
@onready var player2_selection_block: Control = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock
@onready var player2_president_display: TextureRect = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock/Player2PresidentControls/Player2PresidentDisplay
@onready var player2_left_arrow: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock/Player2PresidentControls/Player2LeftArrow
@onready var player2_right_arrow: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock/Player2PresidentControls/Player2RightArrow
@onready var player2_select_button: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock/Player2SelectButton
@onready var player2_president_info_label: Label = $SelectionBlocksContainer/RightSideSelectionWrapper/Player2SelectionBlock/Player2PresidentControls/Player2PresidentDisplay/Player2PresidentInfoLabel

# AI elements
@onready var ai_selection_block: Control = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock
@onready var ai_president_display: TextureRect = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock/AIPresidentControls/AIPresidentDisplay
@onready var ai_left_arrow: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock/AIPresidentControls/AILeftArrow
@onready var ai_right_arrow: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock/AIPresidentControls/AIRightArrow
@onready var ai_select_button: BaseButton = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock/AISelectButton
@onready var ai_president_info_label: Label = $SelectionBlocksContainer/RightSideSelectionWrapper/AISelectionBlock/AIPresidentControls/AIPresidentDisplay/AIPresidentInfoLabel

# Variables for paddle selection
var player1_selected_texture_path = ""
var player2_selected_texture_path = ""
var ai_selected_texture_path = ""
var available_paddle_keys = []
var player1_current_paddle_index = 0
var player2_current_paddle_index = 0
var ai_current_paddle_index = 0

func _ready():
	# Populate available_paddle_keys from the GameManager singleton
	available_paddle_keys = GameManager.available_paddle_textures.keys()

	# Connect signals for Player 1 controls
	player1_left_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("player1", -1))
	player1_right_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("player1", 1))
	player1_select_button.pressed.connect(Callable(self, "_on_select_button_pressed").bind("player1"))

	# Connect signals for Player 2 controls
	player2_left_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("player2", -1))
	player2_right_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("player2", 1))
	player2_select_button.pressed.connect(Callable(self, "_on_select_button_pressed").bind("player2"))

	# Connect signals for AI controls
	ai_left_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("ai", -1))
	ai_right_arrow.pressed.connect(Callable(self, "_on_arrow_pressed").bind("ai", 1))
	ai_select_button.pressed.connect(Callable(self, "_on_select_button_pressed").bind("ai"))

	# The Confirm button signal should be connected in the Godot editor.

	# Perform initial setup based on the game mode selected previously
	_initialize_paddle_selection()
	_update_ui_visibility()
	_update_confirm_button_state()

func _initialize_paddle_selection():
	if not available_paddle_keys.is_empty():
		player1_selected_texture_path = GameManager.available_paddle_textures[available_paddle_keys[0]]["path"]
		player2_selected_texture_path = GameManager.available_paddle_textures[available_paddle_keys[0]]["path"]
		ai_selected_texture_path = GameManager.available_paddle_textures[available_paddle_keys[0]]["path"]

		if available_paddle_keys.size() >= 2:
			player2_selected_texture_path = GameManager.available_paddle_textures[available_paddle_keys[1]]["path"]
			ai_selected_texture_path = GameManager.available_paddle_textures[available_paddle_keys[1]]["path"]
			player2_current_paddle_index = 1
			ai_current_paddle_index = 1
	
	_update_displayed_paddles()

func _update_ui_visibility():
	player1_selection_block.show()

	match GameManager.current_game_mode:
		GameManager.GameMode.ONE_PLAYER:
			player2_selection_block.hide()
			ai_selection_block.show()
			if ai_selected_texture_path == GameManager.available_paddle_textures[available_paddle_keys[player1_current_paddle_index]]["path"]:
				_auto_select_ai_paddle_different_from(ai_selected_texture_path)
		GameManager.GameMode.TWO_PLAYERS:
			player2_selection_block.show()
			ai_selection_block.hide()
			if player2_selected_texture_path == GameManager.available_paddle_textures[available_paddle_keys[player1_current_paddle_index]]["path"]:
				_auto_select_player2_paddle_different_from(player2_selected_texture_path)
	
	_update_confirm_button_state()
	_update_displayed_paddles()

func _on_arrow_pressed(player_type: String, direction: int):
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()

	var current_index: int
	var display_node: TextureRect
	var info_label_node: Label
	var select_button_node: BaseButton

	match player_type:
		"player1":
			current_index = player1_current_paddle_index
			display_node = player1_president_display
			info_label_node = player1_president_info_label
			select_button_node = player1_select_button
		"player2":
			current_index = player2_current_paddle_index
			display_node = player2_president_display
			info_label_node = player2_president_info_label
			select_button_node = player2_select_button
		"ai":
			current_index = ai_current_paddle_index
			display_node = ai_president_display
			info_label_node = ai_president_info_label
			select_button_node = ai_select_button
		_:
			return

	if select_button_node.disabled:
		_on_select_button_pressed(player_type)
		return

	var new_index = wrapi(current_index + direction, 0, available_paddle_keys.size())
	var new_paddle_key = available_paddle_keys[new_index]
	var new_paddle_data = GameManager.available_paddle_textures[new_paddle_key]
	var new_paddle_path = new_paddle_data["path"]

	match player_type:
		"player1":
			player1_current_paddle_index = new_index
			player1_selected_texture_path = new_paddle_path
		"player2":
			player2_current_paddle_index = new_index
			player2_selected_texture_path = new_paddle_path
		"ai":
			ai_current_paddle_index = new_index
			ai_selected_texture_path = new_paddle_path

	display_node.texture = load(new_paddle_path)
	info_label_node.text = "%s (%s)" % [new_paddle_key, new_paddle_data["term"]]

	_ensure_unique_selections(player_type, new_paddle_path)
	_update_confirm_button_state()
	_update_paddle_button_highlights()

func _ensure_unique_selections(changed_player_type: String, new_path: String):
	if available_paddle_keys.size() <= 1:
		return

	match GameManager.current_game_mode:
		GameManager.GameMode.ONE_PLAYER:
			if changed_player_type == "player1" and new_path == ai_selected_texture_path:
				_auto_select_ai_paddle_different_from(new_path)
			elif changed_player_type == "ai" and new_path == player1_selected_texture_path:
				_auto_select_player1_paddle_different_from(new_path)
		GameManager.GameMode.TWO_PLAYERS:
			if changed_player_type == "player1" and new_path == player2_selected_texture_path:
				_auto_select_player2_paddle_different_from(new_path)
			elif changed_player_type == "player2" and new_path == player1_selected_texture_path:
				_auto_select_player1_paddle_different_from(new_path)

func _on_select_button_pressed(player_type: String):
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()

	var select_button_node: BaseButton
	var left_arrow_node: BaseButton
	var right_arrow_node: BaseButton
	var selected_path: String

	match player_type:
		"player1":
			select_button_node = player1_select_button
			left_arrow_node = player1_left_arrow
			right_arrow_node = player1_right_arrow
			selected_path = player1_selected_texture_path
		"player2":
			select_button_node = player2_select_button
			left_arrow_node = player2_left_arrow
			right_arrow_node = player2_right_arrow
			selected_path = player2_selected_texture_path
		"ai":
			select_button_node = ai_select_button
			left_arrow_node = ai_left_arrow
			right_arrow_node = ai_right_arrow
			selected_path = ai_selected_texture_path
		_:
			return

	if select_button_node.disabled:
		select_button_node.disabled = false
		left_arrow_node.disabled = false
		right_arrow_node.disabled = false
		if select_button_node.has_node("Label"):
			select_button_node.get_node("Label").text = "Select"
	else:
		if selected_path == "": return
		select_button_node.disabled = true
		left_arrow_node.disabled = true
		right_arrow_node.disabled = true
		if select_button_node.has_node("Label"):
			select_button_node.get_node("Label").text = "Elected!"

	_update_confirm_button_state()
	_update_paddle_button_highlights()

func _auto_select_ai_paddle_different_from(forbidden_path: String):
	for i in range(available_paddle_keys.size()):
		var key = available_paddle_keys[i]
		var data = GameManager.available_paddle_textures[key]
		if data["path"] != forbidden_path:
			ai_current_paddle_index = i
			ai_selected_texture_path = data["path"]
			ai_president_display.texture = load(data["path"])
			ai_president_info_label.text = "%s (%s)" % [key, data["term"]]
			return
	var forbidden_index = player1_current_paddle_index
	var fallback_index = (forbidden_index + 1) % available_paddle_keys.size()
	var key = available_paddle_keys[fallback_index]
	var data = GameManager.available_paddle_textures[key]
	ai_current_paddle_index = fallback_index
	ai_selected_texture_path = data["path"]
	ai_president_display.texture = load(data["path"])
	ai_president_info_label.text = "%s (%s)" % [key, data["term"]]

func _auto_select_player2_paddle_different_from(forbidden_path: String):
	for i in range(available_paddle_keys.size()):
		var key = available_paddle_keys[i]
		var data = GameManager.available_paddle_textures[key]
		if data["path"] != forbidden_path:
			player2_current_paddle_index = i
			player2_selected_texture_path = data["path"]
			player2_president_display.texture = load(data["path"])
			player2_president_info_label.text = "%s (%s)" % [key, data["term"]]
			return
	var forbidden_index = player1_current_paddle_index
	var fallback_index = (forbidden_index + 1) % available_paddle_keys.size()
	var key = available_paddle_keys[fallback_index]
	var data = GameManager.available_paddle_textures[key]
	player2_current_paddle_index = fallback_index
	player2_selected_texture_path = data["path"]
	player2_president_display.texture = load(data["path"])
	player2_president_info_label.text = "%s (%s)" % [key, data["term"]]

func _auto_select_player1_paddle_different_from(forbidden_path: String):
	for i in range(available_paddle_keys.size()):
		var key = available_paddle_keys[i]
		var data = GameManager.available_paddle_textures[key]
		if data["path"] != forbidden_path:
			player1_current_paddle_index = i
			player1_selected_texture_path = data["path"]
			player1_president_display.texture = load(data["path"])
			player1_president_info_label.text = "%s (%s)" % [key, data["term"]]
			return
	var forbidden_index = player2_current_paddle_index
	if GameManager.current_game_mode == GameManager.GameMode.ONE_PLAYER:
		forbidden_index = ai_current_paddle_index
	var fallback_index = (forbidden_index + 1) % available_paddle_keys.size()
	var key = available_paddle_keys[fallback_index]
	var data = GameManager.available_paddle_textures[key]
	player1_current_paddle_index = fallback_index
	player1_selected_texture_path = data["path"]
	player1_president_display.texture = load(data["path"])
	player1_president_info_label.text = "%s (%s)" % [key, data["term"]]

func _update_displayed_paddles():
	if available_paddle_keys.is_empty(): return

	var p1_key = available_paddle_keys[player1_current_paddle_index]
	var p1_data = GameManager.available_paddle_textures[p1_key]
	player1_selected_texture_path = p1_data["path"]
	player1_president_display.texture = load(player1_selected_texture_path)
	player1_president_info_label.text = "%s (%s)" % [p1_key, p1_data["term"]]

	var p2_key = available_paddle_keys[player2_current_paddle_index]
	var p2_data = GameManager.available_paddle_textures[p2_key]
	player2_selected_texture_path = p2_data["path"]
	player2_president_display.texture = load(player2_selected_texture_path)
	player2_president_info_label.text = "%s (%s)" % [p2_key, p2_data["term"]]

	var ai_key = available_paddle_keys[ai_current_paddle_index]
	var ai_data = GameManager.available_paddle_textures[ai_key]
	ai_selected_texture_path = ai_data["path"]
	ai_president_display.texture = load(ai_selected_texture_path)
	ai_president_info_label.text = "%s (%s)" % [ai_key, ai_data["term"]]

func _update_paddle_button_highlights():
	player1_president_display.modulate = Color.WHITE
	player2_president_display.modulate = Color.WHITE
	ai_president_display.modulate = Color.WHITE

func _update_confirm_button_state():
	var can_confirm = false
	match GameManager.current_game_mode:
		GameManager.GameMode.ONE_PLAYER:
			can_confirm = player1_select_button.disabled and ai_select_button.disabled
		GameManager.GameMode.TWO_PLAYERS:
			can_confirm = player1_select_button.disabled and player2_select_button.disabled
	
	confirm_button.disabled = not can_confirm
	
	if confirm_button.has_node("Label"):
		var confirm_label = confirm_button.get_node("Label")
		if can_confirm:
			confirm_label.text = "Start Game"
		else:
			confirm_label.text = "Cast Your Vote"

func _on_ConfirmButton_pressed():
	# Play the UI click sound using the function from our global script.
	GlobalAudio.play_ui_click()
		
	GameManager.player1_paddle_texture_path = player1_selected_texture_path
	if GameManager.current_game_mode == GameManager.GameMode.TWO_PLAYERS:
		GameManager.player2_paddle_texture_path = player2_selected_texture_path
	else:
		GameManager.ai_paddle_texture_path = ai_selected_texture_path

	_start_transition(MAIN_GAME_SCENE_PATH)

func _start_transition(target_scene: String):
	confirm_button.disabled = true
	player1_select_button.disabled = true
	player2_select_button.disabled = true
	ai_select_button.disabled = true
	
	get_tree().create_timer(0.2).timeout.connect(func():
		get_tree().change_scene_to_file(target_scene)
	)
