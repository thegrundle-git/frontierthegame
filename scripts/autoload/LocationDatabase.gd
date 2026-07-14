extends Node


var locations: Dictionary = {}


func _ready() -> void:
	load_locations()


func load_locations() -> void:
	locations.clear()

	var location_paths: Array[String] = [
		"res://resources/locations/forest.tres",
		"res://resources/locations/river.tres",
		"res://resources/locations/meadow.tres"
	]

	for location_path in location_paths:
		var location_resource := load(location_path)

		if location_resource == null:
			push_error(
				"Failed to load location: "
				+ location_path
			)
			continue

		if location_resource is not LocationData:
			push_error(
				"Resource is not LocationData: "
				+ location_path
			)
			continue

		register(location_resource)

	print(
		"Loaded ",
		locations.size(),
		" locations."
	)


func register(location: LocationData) -> void:
	if location == null:
		return

	if location.id.is_empty():
		push_error(
			"Location has no ID: "
				+ location.resource_path
		)
		return

	if locations.has(location.id):
		return

	locations[location.id] = location


func get_location(
	location_id: String
) -> LocationData:
	if not locations.has(location_id):
		push_warning(
			"Unknown location ID requested: "
				+ location_id
		)
		return null

	return locations[location_id]


func has_location(location_id: String) -> bool:
	return locations.has(location_id)
