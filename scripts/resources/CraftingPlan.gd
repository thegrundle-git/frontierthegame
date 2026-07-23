extends RefCounted
class_name CraftingPlan


var recipe_id: String = ""
var can_craft: bool = false
var unavailable_reason: String = ""
var required_item_amounts: Dictionary = {}
var selected_components: Dictionary = {}
var component_records: Array[EquipmentComponentRecord] = []
var results: Array[IngredientData] = []


func get_primary_result() -> IngredientData:
	for result: IngredientData in results:
		if result != null and result.is_valid() and result.item != null:
			return result
	return null


func build_preview_instance() -> ItemInstance:
	var result: IngredientData = get_primary_result()
	if result == null or not result.item.uses_unique_instances():
		return null

	var instance := ItemInstance.new()
	instance.instance_id = "preview"
	instance.item_id = result.item.id
	instance.material_id = result.item.material_id
	instance.component_history_known = not component_records.is_empty()
	for record: EquipmentComponentRecord in component_records:
		if record != null:
			var copied_record := record.duplicate(true) as EquipmentComponentRecord
			if copied_record != null:
				instance.components.append(copied_record)
	return instance
