extends Node

const DISCOVERY_FOLDER := "res://resources/discoveries/"

var discoveries: Dictionary = {}

func _ready():
	load_discoveries()

func load_discoveries():
	discoveries.clear()

	var files := DirAccess.get_files_at(DISCOVERY_FOLDER)

	for file in files:
		if not file.ends_with(".tres"):
			continue

		var discovery = load(DISCOVERY_FOLDER + file)

		if discovery is DiscoveryData:
			discoveries[discovery.id] = discovery

	print("Loaded ", discoveries.size(), " discoveries.")


func get_all() -> Array:
	return discoveries.values()
