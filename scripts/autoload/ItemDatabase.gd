extends Node


const ITEM_FOLDER := "res://resources/items/"


var items: Dictionary = {}


func _ready() -> void:
	load_items()


func load_items() -> void:
	items.clear()

	var file_names := DirAccess.get_files_at(ITEM_FOLDER)

	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue

		var item_path := ITEM_FOLDER + file_name
		var loaded_resource := load(item_path)

		if loaded_resource is not ItemData:
			push_warning(
				"Skipped non-ItemData resource: " + item_path
			)
			continue

		register(loaded_resource)

	print("Loaded ", items.size(), " items.")


func register(item: ItemData) -> void:
	if item.id.is_empty():
		push_error(
			"Item has no ID: " + item.resource_path
		)
		return

	if items.has(item.id):
		push_error(
			"Duplicate item ID: " + item.id
		)
		return

	items[item.id] = item


func get_item(item_id: String) -> ItemData:
	if not items.has(item_id):
		push_warning(
			"Unknown item ID requested: " + item_id
		)
		return null

	return items[item_id]


func has_item(item_id: String) -> bool:
	return items.has(item_id)
