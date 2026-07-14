extends Control


@export var game_scene: PackedScene


@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var quit_button: Button = %QuitButton


var _transition_started: bool = false


func _ready() -> void:
	_connect_buttons()

	continue_button.disabled = not SaveManager.save_exists()
	new_game_button.grab_focus()

	print("MainMenu ready")


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
	if _transition_started:
		return

	_transition_started = true
	_set_buttons_disabled(true)

	print("New Game pressed")

	GameManager.prepare_new_game()

	call_deferred("_open_game_scene")


func _on_continue_button_pressed() -> void:
	if _transition_started:
		return

	if not SaveManager.save_exists():
		continue_button.disabled = true
		return

	_transition_started = true
	_set_buttons_disabled(true)

	print("Continue pressed")

	GameManager.prepare_saved_game()

	call_deferred("_open_game_scene")


func _on_quit_button_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()


func _open_game_scene() -> void:
	if game_scene == null:
		push_error(
			"No gameplay scene assigned to MainMenu."
		)

		_transition_started = false
		_set_buttons_disabled(false)
		return

	var error := get_tree().change_scene_to_packed(
		game_scene
	)

	print("Scene change result: ", error)

	if error != OK:
		push_error(
			"Failed to open gameplay scene. Error: "
			+ str(error)
		)

		_transition_started = false
		_set_buttons_disabled(false)


func _set_buttons_disabled(
	disabled: bool
) -> void:
	new_game_button.disabled = disabled

	continue_button.disabled = (
		disabled
		or not SaveManager.save_exists()
	)

	quit_button.disabled = disabled
