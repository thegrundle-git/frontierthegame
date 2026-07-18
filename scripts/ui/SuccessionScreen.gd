extends Control
class_name SuccessionScreen


signal successor_selected(display_name: String, character_id: String)


@onready var candidate_name_label: Label = %CandidateNameLabel
@onready var continue_button: Button = %ContinueButton

var _candidate_name: String = ""
var _candidate_id: String = ""


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	visible = false


func show_candidate(candidate: Dictionary) -> void:
	_candidate_name = str(candidate.get("display_name", ""))
	_candidate_id = str(candidate.get("character_id", ""))

	if _candidate_name.is_empty() or _candidate_id.is_empty():
		return

	candidate_name_label.text = _candidate_name
	continue_button.text = "Continue as " + _candidate_name
	visible = true
	move_to_front()
	continue_button.grab_focus()


func hide_screen() -> void:
	visible = false
	_candidate_name = ""
	_candidate_id = ""


func _on_continue_pressed() -> void:
	if _candidate_name.is_empty() or _candidate_id.is_empty():
		return

	successor_selected.emit(_candidate_name, _candidate_id)
