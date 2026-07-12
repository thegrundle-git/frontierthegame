extends Node


signal action_started(action_name: String)
signal action_progress_changed(progress: float)
signal action_completed(action_name: String)
signal busy_changed(is_busy: bool)


var is_busy: bool = false
var current_action_name: String = ""
var current_progress: float = 0.0

var _elapsed_seconds: float = 0.0
var _duration_seconds: float = 0.0
var _game_minutes: int = 0
var _completion_callback: Callable


func _process(delta: float) -> void:
	if not is_busy:
		return

	_elapsed_seconds += delta

	if _duration_seconds <= 0.0:
		current_progress = 1.0
	else:
		current_progress = clamp(
			_elapsed_seconds / _duration_seconds,
			0.0,
			1.0
		)

	action_progress_changed.emit(current_progress)

	if current_progress >= 1.0:
		_finish_action()


func start_action(
	action_name: String,
	duration_seconds: float,
	game_minutes: int,
	completion_callback: Callable
) -> bool:
	if is_busy:
		return false

	if not completion_callback.is_valid():
		push_error(
			"Cannot start action with an invalid callback."
		)
		return false

	is_busy = true
	current_action_name = action_name
	current_progress = 0.0

	_elapsed_seconds = 0.0
	_duration_seconds = max(duration_seconds, 0.01)
	_game_minutes = max(game_minutes, 0)
	_completion_callback = completion_callback

	busy_changed.emit(true)
	action_started.emit(current_action_name)
	action_progress_changed.emit(0.0)

	return true


func _finish_action() -> void:
	var finished_action_name := current_action_name
	var callback := _completion_callback
	var minutes_to_advance := _game_minutes

	is_busy = false
	current_action_name = ""
	current_progress = 0.0

	_elapsed_seconds = 0.0
	_duration_seconds = 0.0
	_game_minutes = 0
	_completion_callback = Callable()

	TimeManager.add_minutes(minutes_to_advance)

	if callback.is_valid():
		callback.call()

	action_completed.emit(finished_action_name)
	busy_changed.emit(false)
	action_progress_changed.emit(0.0)
