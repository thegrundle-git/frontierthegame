extends Node


const LOCATION_FOLDER := "res://resources/locations/"


var locations: Dictionary = {}


func _ready() -> void:
	load_locations()


func load_locations() -> void:
	locations.clear()

	var file_names := DirAccess.get_files_at(
		LOCATION_FOLDER
	)

	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue

		var resource_path := (
			LOCATION_FOLDER + file_name
		)

		var loaded_resource := load(
			resource_path
		)

		if loaded_resource is not LocationData:
			push_warning(
				"Skipped non-LocationData resource: "
				+ resource_path
			)
			continue

		register(loaded_resource)

	print(
		"Loaded ",
		locations.size(),
		" locations."
	)


func register(location: LocationData) -> void:
	if location.id.is_empty():
		push_error(
			"Location has no ID: "
				+ location.resource_path
		)
		return

	if locations.has(location.id):
		push_error(
			"Duplicate location ID: "
				+ location.id
		)
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
