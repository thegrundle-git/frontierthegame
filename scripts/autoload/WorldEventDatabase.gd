extends Node


const EVENT_FOLDER := "res://resources/events/"


var events: Dictionary = {}


func _ready() -> void:
	load_events()


func load_events() -> void:
	events.clear()

	var file_names := DirAccess.get_files_at(
		EVENT_FOLDER
	)

	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue

		var resource_path := (
			EVENT_FOLDER + file_name
		)

		var loaded_resource := load(
			resource_path
		)

		if loaded_resource is not WorldEventData:
			push_warning(
				"Skipped non-WorldEventData resource: "
				+ resource_path
			)
			continue

		register(loaded_resource)

	print("Loaded ", events.size(), " world events.")


func register(event: WorldEventData) -> void:
	if event.id.is_empty():
		push_error(
			"World event has no ID: "
				+ event.resource_path
		)
		return

	if events.has(event.id):
		push_error(
			"Duplicate world event ID: "
				+ event.id
		)
		return

	events[event.id] = event


func get_all() -> Array:
	return events.values()


func get_event(event_id: String) -> WorldEventData:
	if not events.has(event_id):
		return null

	return events[event_id]
