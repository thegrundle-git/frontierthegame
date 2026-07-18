extends RefCounted
class_name EquipmentStatCalculator


static func get_tool_efficiency(instance: ItemInstance) -> int:
	var component: EquipmentComponentRecord = get_efficiency_component(instance)
	if component != null:
		return maxi(component.material_quality, 1)

	if instance == null:
		return 1
	var item: ItemData = instance.get_item_data()
	if item == null:
		return 1
	return maxi(item.tool_efficiency, 1)


static func get_efficiency_component(
	instance: ItemInstance
) -> EquipmentComponentRecord:
	if instance == null or not instance.component_history_known:
		return null

	for component: EquipmentComponentRecord in instance.components:
		if (
			component != null
			and component.is_valid()
			and component.component_slot == "head"
		):
			return component

	return null


static func uses_component_efficiency(instance: ItemInstance) -> bool:
	return get_efficiency_component(instance) != null
