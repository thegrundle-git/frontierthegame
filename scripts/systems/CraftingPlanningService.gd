extends RefCounted
class_name CraftingPlanningService


static func build_plan(
	recipe: RecipeData,
	inventories: Array[FrontierInventory],
	preferred_component_ids: Dictionary = {}
) -> CraftingPlan:
	var plan := CraftingPlan.new()
	if recipe == null:
		plan.unavailable_reason = "Crafting unavailable."
		return plan

	plan.recipe_id = recipe.id
	var remaining_by_item := _get_available_amounts(inventories)

	for ingredient: IngredientData in recipe.ingredients:
		if ingredient == null or not ingredient.is_valid():
			plan.unavailable_reason = "This recipe has invalid requirements."
			return plan

		if ingredient.uses_component_slot():
			_plan_component_ingredient(
				plan,
				ingredient,
				remaining_by_item,
				str(
					preferred_component_ids.get(
						ingredient.component_slot,
						""
					)
				)
			)
		else:
			_plan_item_ingredient(plan, ingredient, remaining_by_item)

	if not plan.unavailable_reason.is_empty():
		plan.results = recipe.get_results_for_components(plan.selected_components)
		return plan

	plan.results = recipe.get_results_for_components(plan.selected_components)
	plan.can_craft = not plan.results.is_empty()
	if not plan.can_craft:
		plan.unavailable_reason = "This recipe has no valid result."
	return plan


static func _get_available_amounts(
	inventories: Array[FrontierInventory]
) -> Dictionary:
	var amounts: Dictionary = {}
	for inventory: FrontierInventory in inventories:
		if inventory == null:
			continue
		for item_id_value: Variant in inventory.items.keys():
			var item_id := str(item_id_value)
			amounts[item_id] = int(amounts.get(item_id, 0)) + (
				inventory.get_item_amount(item_id)
			)
	return amounts


static func _plan_item_ingredient(
	plan: CraftingPlan,
	ingredient: IngredientData,
	remaining_by_item: Dictionary
) -> void:
	if ingredient.item == null:
		plan.unavailable_reason = "This recipe has an invalid item requirement."
		return
	var available := int(remaining_by_item.get(ingredient.item.id, 0))
	if available < ingredient.amount:
		plan.unavailable_reason = (
			"Missing "
			+ str(ingredient.amount - available)
			+ " "
			+ ingredient.item.display_name
			+ "."
		)
		return
	remaining_by_item[ingredient.item.id] = available - ingredient.amount
	_add_required_amount(plan, ingredient.item.id, ingredient.amount)
	if ingredient.item.is_tool_component():
		_add_component_record(
			plan,
			ingredient.item,
			ingredient.item.component_slot,
			ingredient.amount
		)


static func _plan_component_ingredient(
	plan: CraftingPlan,
	ingredient: IngredientData,
	remaining_by_item: Dictionary,
	preferred_item_id: String
) -> void:
	if not preferred_item_id.is_empty():
		_plan_preferred_component(
			plan,
			ingredient,
			remaining_by_item,
			preferred_item_id
		)
		return

	var remaining := ingredient.amount
	for component: ItemData in ItemDatabase.get_components_for_slot(
		ingredient.component_slot
	):
		if remaining <= 0:
			break
		var available := int(remaining_by_item.get(component.id, 0))
		var selected_amount := mini(remaining, available)
		if selected_amount <= 0:
			continue
		remaining_by_item[component.id] = available - selected_amount
		_add_required_amount(plan, component.id, selected_amount)
		_add_component_record(
			plan,
			component,
			ingredient.component_slot,
			selected_amount
		)
		if not plan.selected_components.has(ingredient.component_slot):
			plan.selected_components[ingredient.component_slot] = component
		remaining -= selected_amount

	if remaining > 0:
		plan.unavailable_reason = (
			"Missing "
			+ str(remaining)
			+ " "
			+ ingredient.component_slot.capitalize()
			+ " component."
		)


static func _plan_preferred_component(
	plan: CraftingPlan,
	ingredient: IngredientData,
	remaining_by_item: Dictionary,
	preferred_item_id: String
) -> void:
	var component: ItemData = ItemDatabase.get_item(preferred_item_id)
	if component == null or component.component_slot != ingredient.component_slot:
		plan.unavailable_reason = (
			"The selected "
			+ ingredient.component_slot.capitalize()
			+ " is not compatible with this recipe."
		)
		return

	var available := int(remaining_by_item.get(component.id, 0))
	if available < ingredient.amount:
		plan.unavailable_reason = (
			component.display_name
			+ " is no longer available in the required quantity."
		)
		return

	remaining_by_item[component.id] = available - ingredient.amount
	_add_required_amount(plan, component.id, ingredient.amount)
	_add_component_record(
		plan,
		component,
		ingredient.component_slot,
		ingredient.amount
	)
	plan.selected_components[ingredient.component_slot] = component


static func _add_required_amount(
	plan: CraftingPlan,
	item_id: String,
	amount: int
) -> void:
	plan.required_item_amounts[item_id] = (
		int(plan.required_item_amounts.get(item_id, 0)) + amount
	)


static func _add_component_record(
	plan: CraftingPlan,
	item: ItemData,
	component_slot: String,
	amount: int
) -> void:
	for record: EquipmentComponentRecord in plan.component_records:
		if record.component_slot == component_slot and record.item_id == item.id:
			record.amount += amount
			return
	var record := EquipmentComponentRecord.new()
	record.component_slot = component_slot
	record.item_id = item.id
	record.material_id = item.material_id
	record.material_quality = maxi(item.material_quality, 0)
	record.amount = amount
	plan.component_records.append(record)
