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
@export var component_history_known: bool = false
@export var components: Array[EquipmentComponentRecord] = []
@export var component_conditions: Array[EquipmentComponentCondition] = []
@export var legacy_current_condition: int = 0
@export var legacy_maximum_condition: int = 0
@export var maintenance_count: int = 0
@export var last_maintained_day: int = 0
@export var last_maintained_by_id: String = ""
@export var last_maintained_by_name: String = ""
@export var next_component_record_sequence: int = 1
@export var component_replacements: Array[EquipmentComponentReplacementRecord] = []


func is_valid() -> bool:
	return not instance_id.is_empty() and not item_id.is_empty()


func get_item_data() -> ItemData:
	if item_id.is_empty():
		return null

	return ItemDatabase.get_item(item_id)
