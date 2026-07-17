extends Node
class_name CraftAction


func perform(
	survivor: Survivor,
	recipe: RecipeData
) -> bool:
	if survivor == null:
		return false

	if recipe == null:
		return false

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return false

	if not civilization.has_recipe(
		recipe.id
	):
		_add_event(
			"That recipe has not been discovered."
		)
		return false

	if not GameManager.can_afford_recipe_from_accessible_inventories(
		recipe
	):
		_add_event(
			"Not enough materials to craft "
			+ recipe.display_name
			+ "."
		)
		return false

	if not GameManager.consume_recipe_ingredients_from_accessible_inventories(
		recipe
	):
		return false

	var output_inventory: FrontierInventory = (
		_get_crafting_output_inventory(
			survivor,
			civilization
		)
	)

	if output_inventory == null:
		return false

	output_inventory.add_recipe_results(
		recipe
	)

	_add_event(
		survivor.data.display_name
		+ " crafted "
		+ recipe.display_name
		+ "."
	)

	_auto_equip_first_tool(
		survivor,
		recipe
	)

	return true


func _get_crafting_output_inventory(
	survivor: Survivor,
	civilization: CivilizationData
) -> FrontierInventory:
	if GameManager.is_survivor_at_home():
		return civilization.inventory

	return survivor.inventory


func _auto_equip_first_tool(
	survivor: Survivor,
	recipe: RecipeData
) -> void:
	if not survivor.equipped_tool_id.is_empty():
		return

	for result: IngredientData in recipe.results:
		if (
			result == null
			or result.item == null
		):
			continue

		if "tool" not in result.item.tags:
			continue

		survivor.equip_tool(
			result.item.id
		)

		return


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
