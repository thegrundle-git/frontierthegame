extends RefCounted
class_name EquipmentStatCalculator


const HANDLING_REDUCTION_PER_RATING := 0.10
const MAXIMUM_HANDLING_REDUCTION := 0.25


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


static func get_component_for_slot(
	instance: ItemInstance,
	component_slot: String
) -> EquipmentComponentRecord:
	if instance == null or not instance.component_history_known:
		return null
	for component: EquipmentComponentRecord in instance.components:
		if (
			component != null
			and component.is_valid()
			and component.component_slot == component_slot
		):
			return component
	return null


static func get_quality_rating_for_slot(
	instance: ItemInstance,
	component_slot: String,
	override_item: ItemData = null
) -> int:
	if override_item != null and override_item.component_slot == component_slot:
		return maxi(override_item.material_quality, 0) + 1
	var component: EquipmentComponentRecord = get_component_for_slot(
		instance,
		component_slot
	)
	if component == null:
		return 0
	return maxi(component.material_quality, 0) + 1


static func get_handling_rating(
	instance: ItemInstance,
	override_handle: ItemData = null
) -> int:
	return get_quality_rating_for_slot(instance, "handle", override_handle)


static func get_stability_rating(
	instance: ItemInstance,
	override_binding: ItemData = null
) -> int:
	return get_quality_rating_for_slot(instance, "binding", override_binding)


static func get_overall_quality(
	instance: ItemInstance,
	override_slot: String = "",
	override_item: ItemData = null
) -> int:
	if instance == null or not instance.component_history_known:
		return 0
	var weakest := 0
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		var rating: int = maxi(component.material_quality, 0) + 1
		if component.component_slot == override_slot and override_item != null:
			rating = maxi(override_item.material_quality, 0) + 1
		if weakest == 0 or rating < weakest:
			weakest = rating
	return weakest


static func get_weakest_component(
	instance: ItemInstance
) -> EquipmentComponentRecord:
	if instance == null or not instance.component_history_known:
		return null
	var weakest: EquipmentComponentRecord
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		if (
			weakest == null
			or component.material_quality < weakest.material_quality
		):
			weakest = component
	return weakest


static func get_action_duration_seconds(
	instance: ItemInstance,
	base_duration_seconds: float,
	override_handle: ItemData = null
) -> float:
	var base_duration: float = maxf(base_duration_seconds, 0.01)
	var handling: int = get_handling_rating(instance, override_handle)
	if handling <= 0:
		return base_duration
	var reduction: float = minf(
		float(handling) * HANDLING_REDUCTION_PER_RATING,
		MAXIMUM_HANDLING_REDUCTION
	)
	return maxf(base_duration * (1.0 - reduction), 0.01)
