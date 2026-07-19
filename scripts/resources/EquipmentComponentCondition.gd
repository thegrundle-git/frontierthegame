extends Resource
class_name EquipmentComponentCondition


@export var component_record_id: String = ""
@export var current_condition: int = 0
@export var maximum_condition: int = 0


func is_valid() -> bool:
	return not component_record_id.is_empty() and maximum_condition > 0


func is_failed() -> bool:
	return is_valid() and current_condition <= 0


func apply_wear(amount: int) -> bool:
	if not is_valid() or amount <= 0 or current_condition <= 0:
		return false
	current_condition = maxi(current_condition - amount, 0)
	return true


func get_condition_percent() -> int:
	if not is_valid():
		return 0
	return clampi(roundi(float(current_condition) / float(maximum_condition) * 100.0), 0, 100)
