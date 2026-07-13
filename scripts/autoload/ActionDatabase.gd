extends Node


const ACTION_FOLDER := "res://resources/actions/"


var actions: Dictionary = {}


func _ready() -> void:
	load_actions()


func load_actions() -> void:
	actions.clear()

	var file_names := DirAccess.get_files_at(
		ACTION_FOLDER
	)

	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue

		var resource_path := (
			ACTION_FOLDER + file_name
		)

		var loaded_resource := load(
			resource_path
		)

		if loaded_resource is not ActionData:
			push_warning(
				"Skipped non-ActionData resource: "
				+ resource_path
			)
			continue

		register(loaded_resource)

	print("Loaded ", actions.size(), " actions.")


func register(action: ActionData) -> void:
	if action.id.is_empty():
		push_error(
			"Action has no ID: "
				+ action.resource_path
		)
		return

	if actions.has(action.id):
		push_error(
			"Duplicate action ID: "
				+ action.id
		)
		return

	actions[action.id] = action


func get_action(action_id: String) -> ActionData:
	if not actions.has(action_id):
		push_warning(
			"Unknown action ID requested: "
				+ action_id
		)
		return null

	return actions[action_id]


func has_action(action_id: String) -> bool:
	return actions.has(action_id)
