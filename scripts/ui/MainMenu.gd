extends Control


const GAME_SCENE: PackedScene = preload(
	"res://scenes/main.tscn"
)


@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	_configure_mouse_input()
	_connect_buttons()

	continue_button.disabled = not SaveManager.save_exists()

	new_game_button.grab_focus()

	print("MainMenu ready")
	print("New Game connected: ", new_game_button.pressed.is_connected(
		_on_new_game_button_pressed
	))
	print("Continue connected: ", continue_button.pressed.is_connected(
		_on_continue_button_pressed
	))
	print("Quit connected: ", quit_button.pressed.is_connected(
		_on_quit_button_pressed
	))


func _configure_mouse_input() -> void:
	# The root and layout containers should not consume clicks.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	for control in get_tree().get_nodes_in_group(
		"menu_noninteractive"
	):
		if control is Control:
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Buttons must receive clicks.
	new_game_button.mouse_filter = Control.MOUSE_FILTER_STOP
	continue_button.mouse_filter = Control.MOUSE_FILTER_STOP
	quit_button.mouse_filter = Control.MOUSE_FILTER_STOP


func _connect_buttons() -> void:
	if not new_game_button.pressed.is_connected(
		_on_new_game_button_pressed
	):
		new_game_button.pressed.connect(
			_on_new_game_button_pressed
		)

	if not continue_button.pressed.is_connected(
		_on_continue_button_pressed
	):
		continue_button.pressed.connect(
			_on_continue_button_pressed
		)

	if not quit_button.pressed.is_connected(
		_on_quit_button_pressed
	):
		quit_button.pressed.connect(
			_on_quit_button_pressed
		)


func _on_new_game_button_pressed() -> void:
	print("New Game pressed")

	GameManager.prepare_new_game()
	_open_game_scene()


func _on_continue_button_pressed() -> void:
	print("Continue pressed")

	if not SaveManager.save_exists():
		continue_button.disabled = true
		return

	GameManager.prepare_saved_game()
	_open_game_scene()


func _on_quit_button_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()


func _open_game_scene() -> void:
	if GAME_SCENE == null:
		push_error(
			"Main gameplay scene was not loaded."
		)
		return

	var error := get_tree().change_scene_to_packed(
		GAME_SCENE
	)

	if error != OK:
		push_error(
			"Failed to open gameplay scene. Error: "
			+ str(error)
		)
