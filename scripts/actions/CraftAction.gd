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
	var component_records: Array[EquipmentComponentRecord] = []

	if not GameManager.consume_recipe_ingredients_from_accessible_inventories(
		recipe,
		consumed_components,
		component_records
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

	var crafted_instances: Array[ItemInstance] = (
		_add_crafted_results(
			output_inventory,
			crafted_results,
			survivor,
			civilization,
			component_records
		)
	)

	_record_crafting_contribution(
		survivor,
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
		crafted_instances
	)

	return true


func _add_crafted_results(
	output_inventory: FrontierInventory,
	crafted_results: Array[IngredientData],
	survivor: Survivor,
	civilization: CivilizationData,
	component_records: Array[EquipmentComponentRecord]
) -> Array[ItemInstance]:
	var created_instances: Array[ItemInstance] = []

	for result: IngredientData in crafted_results:
		if result == null or result.item == null or result.amount <= 0:
			continue

		if not result.item.uses_unique_instances():
			output_inventory.add_item(result.item.id, result.amount)
			continue

		for _unit: int in range(result.amount):
			var instance: ItemInstance = civilization.create_item_instance(
				result.item,
				survivor.data.character_id,
				survivor.data.display_name,
				component_records,
				true
			)
			if instance != null and output_inventory.add_equipment_instance(instance):
				created_instances.append(instance)

	return created_instances


func _record_crafting_contribution(
	survivor: Survivor,
	crafted_results: Array[IngredientData]
) -> void:
	if survivor.data == null:
		return

	var life_record: CharacterLifeRecord = (
		survivor.data.life_record
	)

	if life_record == null:
		return

	var output_units := 0

	for result: IngredientData in crafted_results:
		if (
			result == null
			or result.item == null
			or result.amount <= 0
		):
			continue

		output_units += result.amount

	if life_record.record_crafting(
		output_units,
		TimeManager.day
	) and GameManager.game_ui != null:
		GameManager.game_ui.update_legacy_preview()


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
			survivor.data.character_id,
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
	crafted_instances: Array[ItemInstance]
) -> void:
	if survivor.equipped_tool_instance != null:
		return

	for instance: ItemInstance in crafted_instances:
		if instance == null:
			continue

		survivor.equip_tool(
			instance.instance_id
		)

		return


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
