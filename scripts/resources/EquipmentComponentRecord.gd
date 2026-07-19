extends Resource
class_name EquipmentComponentRecord


@export var component_slot: String = ""
@export var record_id: String = ""
@export var item_id: String = ""
@export var material_id: String = ""
@export var material_quality: int = 0
@export var amount: int = 1


func is_valid() -> bool:
	return (
		not component_slot.is_empty()
		and not item_id.is_empty()
		and amount > 0
	)


func get_item_data() -> ItemData:
	return ItemDatabase.get_item(item_id)
