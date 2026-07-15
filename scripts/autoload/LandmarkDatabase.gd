extends Node


var landmarks: Dictionary = {}


func _ready() -> void:
	load_landmarks()


func load_landmarks() -> void:
	landmarks.clear()

	var landmark_paths: Array[String] = [
		"res://resources/landmarks/abandoned_campsite.tres"
	]

	for landmark_path in landmark_paths:
		var loaded_resource := load(
			landmark_path
		)

		if loaded_resource == null:
			push_error(
				"Failed to load landmark: "
				+ landmark_path
			)
			continue

		if loaded_resource is not LandmarkData:
			push_error(
				"Resource is not LandmarkData: "
				+ landmark_path
			)
			continue

		register(loaded_resource)

	print(
		"Loaded ",
		landmarks.size(),
		" landmarks."
	)


func register(
	landmark: LandmarkData
) -> void:
	if landmark == null:
		return

	if landmark.id.is_empty():
		push_error(
			"Landmark has no ID: "
				+ landmark.resource_path
		)
		return

	if landmarks.has(landmark.id):
		push_error(
			"Duplicate landmark ID: "
				+ landmark.id
		)
		return

	landmarks[landmark.id] = landmark


func get_all() -> Array:
	return landmarks.values()


func get_landmark(
	landmark_id: String
) -> LandmarkData:
	if not landmarks.has(landmark_id):
		return null

	return landmarks[landmark_id]


func has_landmark(
	landmark_id: String
) -> bool:
	return landmarks.has(landmark_id)
