extends Resource
class_name EquipmentDisassemblyRecord


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
@export var component_replacements: Array[EquipmentComponentReplacementRecord] = []
@export var maintenance_count: int = 0
@export var recovered_component_item_ids: Array[String] = []
@export var disassembled_day: int = 1
@export var disassembled_hour: int = 0
@export var disassembled_minute: int = 0
@export var disassembled_by_id: String = ""
@export var disassembled_by_name: String = ""


func is_valid() -> bool:
	return not instance_id.is_empty() and not item_id.is_empty()
