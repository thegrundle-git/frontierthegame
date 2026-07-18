extends Resource
class_name ItemInstance


@export var instance_id: String = ""
@export var item_id: String = ""
@export var material_id: String = ""
@export var crafted_by_id: String = ""
@export var crafted_by_name: String = ""
@export var crafted_day: int = 1
@export var crafted_hour: int = 0
@export var crafted_minute: int = 0


func is_valid() -> bool:
	return not instance_id.is_empty() and not item_id.is_empty()


func get_item_data() -> ItemData:
	if item_id.is_empty():
		return null

	return ItemDatabase.get_item(item_id)
