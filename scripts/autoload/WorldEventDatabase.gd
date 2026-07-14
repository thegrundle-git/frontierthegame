extends Node


var events: Dictionary = {}


func _ready() -> void:
	load_events()


func load_events() -> void:
	events.clear()

	var event_paths: Array[String] = [
		"res://resources/events/abandoned_campsite.tres"
	]

	for event_path in event_paths:
		var loaded_resource := load(event_path)

		if loaded_resource == null:
			push_error(
				"Failed to load world event: "
				+ event_path
			)
			continue

		if loaded_resource is not WorldEventData:
			push_error(
				"Resource is not WorldEventData: "
				+ event_path
			)
			continue

		register(loaded_resource)

	print(
		"Loaded ",
		events.size(),
		" world events."
	)


func register(event: WorldEventData) -> void:
	if event == null:
		return

	if event.id.is_empty():
		push_error(
			"World event has no ID: "
				+ event.resource_path
		)
		return

	if events.has(event.id):
		return

	events[event.id] = event


func get_all() -> Array:
	return events.values()


func get_event(
	event_id: String
) -> WorldEventData:
	if not events.has(event_id):
		return null

	return events[event_id]
