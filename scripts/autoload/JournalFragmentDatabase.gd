extends Node


var fragments: Dictionary = {}


func _ready() -> void:
	load_fragments()


func load_fragments() -> void:
	fragments.clear()
	var fragment_paths: Array[String] = [
		"res://resources/journal_fragments/fragment_beneath_ashes.tres"
	]
	for fragment_path: String in fragment_paths:
		var loaded_resource: Resource = load(fragment_path)
		if loaded_resource is not JournalFragmentData:
			push_error("Failed to load journal fragment: " + fragment_path)
			continue
		var fragment := loaded_resource as JournalFragmentData
		if fragment.id.is_empty() or fragments.has(fragment.id):
			push_error("Invalid or duplicate journal fragment: " + fragment_path)
			continue
		fragments[fragment.id] = fragment


func get_all() -> Array:
	return fragments.values()


func get_fragment(fragment_id: String) -> JournalFragmentData:
	if not fragments.has(fragment_id):
		return null
	return fragments[fragment_id] as JournalFragmentData
