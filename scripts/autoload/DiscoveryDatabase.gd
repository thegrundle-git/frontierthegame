extends Node


var discoveries: Dictionary = {}


func _ready() -> void:
	load_discoveries()


func load_discoveries() -> void:
	discoveries.clear()

	var discovery_paths: Array[String] = [
		"res://resources/discoveries/primitive_toolmaking.tres"
	]

	for discovery_path in discovery_paths:
		var discovery := load(discovery_path)

		if discovery == null:
			push_error(
				"Failed to load discovery: "
				+ discovery_path
			)
			continue

		if discovery is not DiscoveryData:
			push_error(
				"Resource is not DiscoveryData: "
				+ discovery_path
			)
			continue

		discoveries[discovery.id] = discovery

	print(
		"Loaded ",
		discoveries.size(),
		" discoveries."
	)


func get_all() -> Array:
	return discoveries.values()

func get_discovery(
	discovery_id: String
) -> DiscoveryData:
	if not discoveries.has(discovery_id):
		push_warning(
			"Unknown discovery ID requested: "
			+ discovery_id
		)
		return null

	return discoveries[discovery_id]
