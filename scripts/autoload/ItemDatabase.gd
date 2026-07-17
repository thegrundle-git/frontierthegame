extends Node


var items: Dictionary = {}


func _ready() -> void:
	load_items()


func load_items() -> void:
	items.clear()

	var item_paths: Array[String] = [
		"res://resources/items/stick.tres",
		"res://resources/items/stone.tres",
		"res://resources/items/berry.tres",
		"res://resources/items/stone_axe.tres",
		"res://resources/items/wood_log.tres",
		"res://resources/items/herb.tres",
		"res://resources/items/flower.tres",
		"res://resources/items/stone_axe_head.tres",
		"res://resources/items/stick_handle.tres",
		"res://resources/items/fiber_binding.tres",
		"res://resources/items/flint.tres",
		"res://resources/items/flint_axe_head.tres",
		"res://resources/items/flint_axe.tres",
	]

	for item_path: String in item_paths:
		var loaded_resource: Resource = load(
			item_path
		)

		if loaded_resource == null:
			push_error(
				"Failed to load item: "
				+ item_path
			)
			continue

		if loaded_resource is not ItemData:
			push_warning(
				"Skipped non-ItemData resource: "
				+ item_path
			)
			continue

		register(
			loaded_resource
		)

	print(
		"Loaded ",
		items.size(),
		" items."
	)


func register(
	item: ItemData
) -> void:
	if item == null:
		return

	if item.id.is_empty():
		push_error(
			"Item has no ID: "
			+ item.resource_path
		)
		return

	if items.has(item.id):
		return

	items[item.id] = item


func get_item(
	item_id: String
) -> ItemData:
	if not items.has(item_id):
		push_warning(
			"Unknown item ID requested: "
			+ item_id
		)
		return null

	return items[item_id]


func has_item(
	item_id: String
) -> bool:
	return items.has(item_id)

func get_components_for_slot(
	component_slot: String
) -> Array[ItemData]:
	var matches: Array[ItemData] = []

	if component_slot.is_empty():
		return matches

	for item_value: Variant in items.values():
		var item := item_value as ItemData

		if item == null:
			continue

		if item.component_slot != component_slot:
			continue

		matches.append(item)

	matches.sort_custom(
		func(
			first: ItemData,
			second: ItemData
		) -> bool:
			if first.material_quality == second.material_quality:
				return first.id < second.id

			return first.material_quality > second.material_quality
	)

	return matches
