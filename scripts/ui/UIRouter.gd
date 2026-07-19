extends RefCounted
class_name UIRouter


var _screens: Dictionary = {}
var _focus_targets: Dictionary = {}
var _history: Array[String] = []
var _current_screen_id: String = ""


func register_screen(
	screen_id: String,
	screen: Control,
	focus_target: Control = null
) -> void:
	if screen_id.is_empty() or screen == null:
		return

	_screens[screen_id] = screen
	_focus_targets[screen_id] = focus_target
	screen.visible = false


func open(screen_id: String, remember_current: bool = true) -> bool:
	if not _screens.has(screen_id):
		return false

	if (
		remember_current
		and not _current_screen_id.is_empty()
		and _current_screen_id != screen_id
	):
		_history.append(_current_screen_id)

	_show_only(screen_id)
	return true


func back(fallback_screen_id: String = "") -> bool:
	while not _history.is_empty():
		var previous_screen_id: String = _history.pop_back()
		if _screens.has(previous_screen_id):
			_show_only(previous_screen_id)
			return true

	if not fallback_screen_id.is_empty():
		return open(fallback_screen_id, false)

	return false


func close_all() -> void:
	for screen: Control in _screens.values():
		screen.visible = false

	_history.clear()
	_current_screen_id = ""


func get_current_screen_id() -> String:
	return _current_screen_id


func _show_only(screen_id: String) -> void:
	for registered_id: String in _screens:
		var screen: Control = _screens[registered_id]
		screen.visible = registered_id == screen_id

	_current_screen_id = screen_id

	var focus_target: Control = _focus_targets.get(screen_id)
	if focus_target != null and focus_target.is_visible_in_tree():
		focus_target.call_deferred("grab_focus")
