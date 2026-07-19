extends RefCounted
class_name EquipmentComponentReplacementService


static func get_active_component(
	instance: ItemInstance,
	component_slot: String
) -> EquipmentComponentRecord:
	if instance == null or not instance.component_history_known:
		return null
	for component: EquipmentComponentRecord in instance.components:
		if component != null and component.component_slot == component_slot:
			return component
	return null


static func can_replace(
	instance: ItemInstance,
	component_slot: String,
	replacement: ItemData
) -> bool:
	if instance == null or replacement == null or not replacement.is_tool_component():
		return false
	if replacement.component_slot != component_slot:
		return false
	var current: EquipmentComponentRecord = get_active_component(instance, component_slot)
	if current == null:
		return false
	var condition: EquipmentComponentCondition = (
		EquipmentDurabilityCalculator.get_component_condition(
			instance,
			current.record_id
		)
	)
	if condition == null:
		return false
	return not (
		current.item_id == replacement.id
		and condition.current_condition >= condition.maximum_condition
	)


static func will_recover_removed_component(
	instance: ItemInstance,
	component_slot: String
) -> bool:
	var current: EquipmentComponentRecord = get_active_component(instance, component_slot)
	if current == null:
		return false
	var condition: EquipmentComponentCondition = (
		EquipmentDurabilityCalculator.get_component_condition(instance, current.record_id)
	)
	return (
		condition != null
		and condition.current_condition >= condition.maximum_condition
	)


static func get_result_item(
	instance: ItemInstance,
	component_slot: String,
	replacement: ItemData
) -> ItemData:
	if not can_replace(instance, component_slot, replacement):
		return null
	var recipe: RecipeData = RecipeDatabase.get_assembly_recipe_for_item(instance.item_id)
	if recipe == null:
		return instance.get_item_data()
	var selected_components: Dictionary = {}
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		var item: ItemData = component.get_item_data()
		if component.component_slot == component_slot:
			item = replacement
		if item != null:
			selected_components[component.component_slot] = item
	for result: IngredientData in recipe.get_results_for_components(selected_components):
		if result != null and result.item != null and result.item.uses_unique_instances():
			return result.item
	return instance.get_item_data()


static func replace_component(
	instance: ItemInstance,
	component_slot: String,
	replacement: ItemData,
	replaced_by_id: String,
	replaced_by_name: String,
	recovered: bool
) -> bool:
	if not can_replace(instance, component_slot, replacement):
		return false
	var component_index := -1
	var removed: EquipmentComponentRecord
	for index: int in range(instance.components.size()):
		var component: EquipmentComponentRecord = instance.components[index]
		if component != null and component.component_slot == component_slot:
			component_index = index
			removed = component
			break
	if component_index < 0 or removed == null:
		return false
	var old_condition: EquipmentComponentCondition = (
		EquipmentDurabilityCalculator.get_component_condition(instance, removed.record_id)
	)
	if old_condition == null:
		return false

	var installed := EquipmentComponentRecord.new()
	installed.component_slot = component_slot
	installed.record_id = "component." + str(maxi(instance.next_component_record_sequence, 1))
	instance.next_component_record_sequence = maxi(instance.next_component_record_sequence, 1) + 1
	installed.item_id = replacement.id
	installed.material_id = replacement.material_id
	installed.material_quality = maxi(replacement.material_quality, 0)
	installed.amount = 1

	var new_condition := EquipmentComponentCondition.new()
	new_condition.component_record_id = installed.record_id
	new_condition.maximum_condition = (
		EquipmentDurabilityCalculator.get_maximum_component_condition(installed)
	)
	new_condition.current_condition = new_condition.maximum_condition

	var condition_index := instance.component_conditions.find(old_condition)
	instance.components[component_index] = installed
	if condition_index >= 0:
		instance.component_conditions[condition_index] = new_condition
	else:
		instance.component_conditions.append(new_condition)

	var result_item: ItemData = get_result_item_after_replacement(instance)
	if result_item != null:
		instance.item_id = result_item.id
		instance.material_id = result_item.material_id

	var record := EquipmentComponentReplacementRecord.new()
	record.sequence = instance.component_replacements.size() + 1
	record.component_slot = component_slot
	record.removed_component = removed.duplicate(true) as EquipmentComponentRecord
	record.removed_current_condition = old_condition.current_condition
	record.removed_maximum_condition = old_condition.maximum_condition
	record.installed_component = installed.duplicate(true) as EquipmentComponentRecord
	record.replacement_day = maxi(TimeManager.day, 1)
	record.replacement_hour = clampi(TimeManager.hour, 0, 23)
	record.replacement_minute = clampi(TimeManager.minute, 0, 59)
	record.replaced_by_id = replaced_by_id
	record.replaced_by_name = replaced_by_name
	record.removed_component_recovered = recovered
	instance.component_replacements.append(record)
	return true


static func get_result_item_after_replacement(instance: ItemInstance) -> ItemData:
	var recipe: RecipeData = RecipeDatabase.get_assembly_recipe_for_item(instance.item_id)
	if recipe == null:
		return instance.get_item_data()
	var selected_components: Dictionary = {}
	for component: EquipmentComponentRecord in instance.components:
		if component != null and component.is_valid():
			var item: ItemData = component.get_item_data()
			if item != null:
				selected_components[component.component_slot] = item
	for result: IngredientData in recipe.get_results_for_components(selected_components):
		if result != null and result.item != null and result.item.uses_unique_instances():
			return result.item
	return instance.get_item_data()
