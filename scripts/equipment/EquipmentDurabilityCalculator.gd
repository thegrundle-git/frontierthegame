extends RefCounted
class_name EquipmentDurabilityCalculator


const HEAD_BASE_CONDITION := 20
const HANDLE_BASE_CONDITION := 30
const BINDING_BASE_CONDITION := 10
const QUALITY_CONDITION_BONUS := 10
const LEGACY_CONDITION_MULTIPLIER := 20
const AXE_CRITICAL_SLOTS: Array[String] = ["head", "handle", "binding"]
const AXE_WEAR_SLOTS: Array[String] = ["head", "binding"]


static func initialize_condition(instance: ItemInstance) -> void:
	if instance == null:
		return
	instance.component_conditions.clear()
	if not instance.component_history_known:
		var item: ItemData = instance.get_item_data()
		var efficiency := 1
		if item != null:
			efficiency = maxi(item.tool_efficiency, 1)
		instance.legacy_maximum_condition = efficiency * LEGACY_CONDITION_MULTIPLIER
		instance.legacy_current_condition = instance.legacy_maximum_condition
		return

	instance.legacy_current_condition = 0
	instance.legacy_maximum_condition = 0
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		var condition: EquipmentComponentCondition = EquipmentComponentCondition.new()
		condition.component_record_id = component.record_id
		condition.maximum_condition = get_maximum_component_condition(component)
		condition.current_condition = condition.maximum_condition
		instance.component_conditions.append(condition)


static func get_maximum_component_condition(
	component: EquipmentComponentRecord
) -> int:
	if component == null:
		return 1
	var base_condition := 10
	match component.component_slot:
		"head":
			base_condition = HEAD_BASE_CONDITION
		"handle":
			base_condition = HANDLE_BASE_CONDITION
		"binding":
			base_condition = BINDING_BASE_CONDITION
	return maxi(base_condition + maxi(component.material_quality, 0) * QUALITY_CONDITION_BONUS, 1)


static func get_component_condition(
	instance: ItemInstance,
	record_id: String
) -> EquipmentComponentCondition:
	if instance == null or record_id.is_empty():
		return null
	for condition: EquipmentComponentCondition in instance.component_conditions:
		if condition != null and condition.component_record_id == record_id:
			return condition
	return null


static func get_condition_for_slot(
	instance: ItemInstance,
	component_slot: String
) -> EquipmentComponentCondition:
	if instance == null or component_slot.is_empty():
		return null
	for component: EquipmentComponentRecord in instance.components:
		if component != null and component.component_slot == component_slot:
			return get_component_condition(instance, component.record_id)
	return null


static func is_usable(instance: ItemInstance) -> bool:
	return get_failed_critical_slot(instance).is_empty()


static func get_failed_critical_slot(instance: ItemInstance) -> String:
	if instance == null:
		return "tool"
	if not instance.component_history_known:
		if instance.legacy_maximum_condition <= 0 or instance.legacy_current_condition <= 0:
			return "tool"
		return ""

	var item: ItemData = instance.get_item_data()
	if item == null:
		return "tool"
	var critical_slots: Array[String] = []
	if "axe" in item.tags:
		critical_slots.assign(AXE_CRITICAL_SLOTS)
	for component_slot: String in critical_slots:
		var condition: EquipmentComponentCondition = (
			get_condition_for_slot(instance, component_slot)
		)
		if condition == null or condition.is_failed():
			return component_slot
	return ""


static func get_overall_condition_percent(instance: ItemInstance) -> int:
	if instance == null:
		return 0
	if not instance.component_history_known:
		if instance.legacy_maximum_condition <= 0:
			return 0
		return clampi(roundi(float(instance.legacy_current_condition) / float(instance.legacy_maximum_condition) * 100.0), 0, 100)

	var lowest_percent := 100
	var found_condition := false
	for condition: EquipmentComponentCondition in instance.component_conditions:
		if condition == null or not condition.is_valid():
			continue
		lowest_percent = mini(lowest_percent, condition.get_condition_percent())
		found_condition = true
	return lowest_percent if found_condition else 0


static func apply_axe_wear(instance: ItemInstance) -> bool:
	if instance == null or not is_usable(instance):
		return false
	if not instance.component_history_known:
		instance.legacy_current_condition = maxi(instance.legacy_current_condition - 1, 0)
		return true

	var applied := false
	for component_slot: String in AXE_WEAR_SLOTS:
		var condition: EquipmentComponentCondition = (
			get_condition_for_slot(instance, component_slot)
		)
		if condition != null:
			applied = condition.apply_wear(1) or applied
	return applied


static func get_repair_item_id(
	instance: ItemInstance,
	component_record_id: String = ""
) -> String:
	if instance == null:
		return ""
	if not instance.component_history_known:
		if instance.legacy_current_condition >= instance.legacy_maximum_condition:
			return ""
		return instance.material_id if ItemDatabase.get_item(instance.material_id) != null else ""

	for component: EquipmentComponentRecord in instance.components:
		if component == null or component.record_id != component_record_id:
			continue
		var condition: EquipmentComponentCondition = get_component_condition(
			instance,
			component_record_id
		)
		if condition == null or condition.current_condition >= condition.maximum_condition:
			return ""
		return component.item_id
	return ""


static func repair(
	instance: ItemInstance,
	component_record_id: String = ""
) -> bool:
	if instance == null or get_repair_item_id(instance, component_record_id).is_empty():
		return false
	if not instance.component_history_known:
		instance.legacy_current_condition = instance.legacy_maximum_condition
		return true
	var condition: EquipmentComponentCondition = get_component_condition(
		instance,
		component_record_id
	)
	return condition != null and condition.repair_to_maximum()
