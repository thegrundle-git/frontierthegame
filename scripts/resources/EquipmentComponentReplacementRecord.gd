extends Resource
class_name EquipmentComponentReplacementRecord


@export var sequence: int = 0
@export var component_slot: String = ""
@export var removed_component: EquipmentComponentRecord
@export var removed_current_condition: int = 0
@export var removed_maximum_condition: int = 0
@export var installed_component: EquipmentComponentRecord
@export var replacement_day: int = 1
@export var replacement_hour: int = 0
@export var replacement_minute: int = 0
@export var replaced_by_id: String = ""
@export var replaced_by_name: String = ""
@export var removed_component_recovered: bool = false


func is_valid() -> bool:
	return (
		sequence > 0
		and not component_slot.is_empty()
		and removed_component != null
		and removed_component.is_valid()
		and installed_component != null
		and installed_component.is_valid()
	)
