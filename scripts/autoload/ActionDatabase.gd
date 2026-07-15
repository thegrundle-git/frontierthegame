extends Node


var actions: Dictionary = {}


func _ready() -> void:
	load_actions()


func load_actions() -> void:
	actions.clear()

	var action_paths: Array[String] = [
		"res://resources/actions/search_area.tres",
		"res://resources/actions/chop_tree.tres",
		"res://resources/actions/track_animals.tres"
	]

	for action_path in action_paths:
		var action_resource := load(action_path)

		if action_resource == null:
			push_error(
				"Failed to load action: "
				+ action_path
			)
			continue

		if action_resource is not ActionData:
			push_error(
				"Resource is not ActionData: "
				+ action_path
			)
			continue

		register(action_resource)

	print(
		"Loaded ",
		actions.size(),
		" actions."
	)


func register(action: ActionData) -> void:
	if action == null:
		return

	if action.id.is_empty():
		push_error(
			"Action has no ID: "
				+ action.resource_path
		)
		return

	if actions.has(action.id):
		return

	actions[action.id] = action


func get_action(
	action_id: String
) -> ActionData:
	if not actions.has(action_id):
		push_warning(
			"Unknown action ID requested: "
				+ action_id
		)
		return null

	return actions[action_id]


func has_action(action_id: String) -> bool:
	return actions.has(action_id)
