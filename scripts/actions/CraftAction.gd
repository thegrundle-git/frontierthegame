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

	var civilization := GameManager.current_civilization

	if civilization == null:
		return false

	if not civilization.has_recipe(recipe.id):
		_add_event(
			"That recipe has not been discovered."
		)
		return false

	if not survivor.inventory.can_afford_recipe(recipe):
		_add_event(
			"Not enough materials to craft "
			+ recipe.display_name
			+ "."
		)
		return false

	if not survivor.inventory.remove_recipe_ingredients(
		recipe
	):
		return false

	survivor.inventory.add_recipe_results(recipe)

	_add_event(
		survivor.data.display_name
		+ " crafted "
		+ recipe.display_name
		+ "."
	)

	return true


func _add_event(message: String) -> void:
	if GameManager.game_ui:
		GameManager.game_ui.add_event(message)
