extends RefCounted
class_name EquipmentDisassemblyService


static func build_record(
	instance: ItemInstance,
	disassembled_by_id: String,
	disassembled_by_name: String
) -> EquipmentDisassemblyRecord:
	if instance == null or not instance.is_valid():
		return null
	var record := EquipmentDisassemblyRecord.new()
	record.instance_id = instance.instance_id
	record.item_id = instance.item_id
	record.material_id = instance.material_id
	record.crafted_by_id = instance.crafted_by_id
	record.crafted_by_name = instance.crafted_by_name
	record.crafted_day = instance.crafted_day
	record.crafted_hour = instance.crafted_hour
	record.crafted_minute = instance.crafted_minute
	record.component_history_known = instance.component_history_known
	record.maintenance_count = instance.maintenance_count
	record.disassembled_day = maxi(TimeManager.day, 1)
	record.disassembled_hour = clampi(TimeManager.hour, 0, 23)
	record.disassembled_minute = clampi(TimeManager.minute, 0, 59)
	record.disassembled_by_id = disassembled_by_id
	record.disassembled_by_name = disassembled_by_name

	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		record.components.append(
			component.duplicate(true) as EquipmentComponentRecord
		)
		var condition: EquipmentComponentCondition = (
			EquipmentDurabilityCalculator.get_component_condition(
				instance,
				component.record_id
			)
		)
		if condition != null and condition.is_valid():
			record.component_conditions.append(
				condition.duplicate(true) as EquipmentComponentCondition
			)
			if condition.current_condition >= condition.maximum_condition:
				record.recovered_component_item_ids.append(component.item_id)

	for replacement: EquipmentComponentReplacementRecord in instance.component_replacements:
		if replacement != null and replacement.is_valid():
			record.component_replacements.append(
				replacement.duplicate(true) as EquipmentComponentReplacementRecord
			)
	return record if record.is_valid() else null


static func get_recovery_preview(instance: ItemInstance) -> String:
	if instance == null:
		return "No equipment selected."
	if not instance.component_history_known:
		return "Component history is unavailable. No components will be recovered."
	var recovered: Array[String] = []
	var lost: Array[String] = []
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		var item: ItemData = component.get_item_data()
		var display_name: String = item.display_name if item != null else component.item_id
		var condition: EquipmentComponentCondition = (
			EquipmentDurabilityCalculator.get_component_condition(instance, component.record_id)
		)
		if condition != null and condition.current_condition >= condition.maximum_condition:
			recovered.append(display_name)
		else:
			lost.append(display_name)
	var preview := "Recovered: " + (", ".join(recovered) if not recovered.is_empty() else "None")
	preview += "\nNot recovered: " + (", ".join(lost) if not lost.is_empty() else "None")
	return preview
