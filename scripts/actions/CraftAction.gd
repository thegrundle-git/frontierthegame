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

	var consumed_components: Dictionary = {}

	if not GameManager.consume_recipe_ingredients_from_accessible_inventories(
		recipe,
		consumed_components
	):
		return false

	var crafted_results: Array[IngredientData] = (
		recipe.get_results_for_components(
			consumed_components
		)
	)

	var output_inventory: FrontierInventory = (
		_get_crafting_output_inventory(
			survivor,
			civilization
		)
	)

	if output_inventory == null:
		return false

	output_inventory.add_ingredient_results(
		crafted_results
	)

	_record_first_crafted_tool(
		survivor,
		civilization,
		crafted_results
	)

	_add_event(
		survivor.data.display_name
		+ " crafted "
		+ _get_crafted_display_name(
			recipe,
			crafted_results
		)
		+ "."
	)

	_auto_equip_first_tool(
		survivor,
		crafted_results
	)

	return true


func _record_first_crafted_tool(
	survivor: Survivor,
	civilization: CivilizationData,
	crafted_results: Array[IngredientData]
) -> void:
	for result: IngredientData in crafted_results:
		if result == null or result.item == null:
			continue

		if "tool" not in result.item.tags:
			continue

		var recorded := civilization.record_history_event(
			CivilizationData.HISTORY_FIRST_CRAFTED_TOOL,
			"First Crafted Tool",
			survivor.data.display_name
			+ " crafted the civilization's first tool: "
			+ result.item.display_name
			+ ".",
			"crafting",
			"",
			survivor.data.display_name,
			TimeManager.day,
			TimeManager.hour,
			TimeManager.minute
		)

		if recorded and GameManager.game_ui != null:
			GameManager.game_ui.update_history_journal()

		return


func _get_crafting_output_inventory(
	survivor: Survivor,
	civilization: CivilizationData
) -> FrontierInventory:
	if GameManager.is_survivor_at_home():
		return civilization.inventory

	return survivor.inventory


func _get_crafted_display_name(
	recipe: RecipeData,
	crafted_results: Array[IngredientData]
) -> String:
	for result: IngredientData in crafted_results:
		if (
			result == null
			or result.item == null
		):
			continue

		return result.item.display_name

	return recipe.display_name


func _auto_equip_first_tool(
	survivor: Survivor,
	crafted_results: Array[IngredientData]
) -> void:
	if not survivor.equipped_tool_id.is_empty():
		return

	for result: IngredientData in crafted_results:
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
