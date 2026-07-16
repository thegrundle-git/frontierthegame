extends RefCounted
class_name FrontierInventory


var items: Dictionary = {}


func add_item(
	item_id: String,
	amount: int = 1
) -> void:
	if item_id.is_empty():
		return

	if amount <= 0:
		return

	if items.has(item_id):
		items[item_id] += amount
	else:
		items[item_id] = amount

	print(
		"Added: ",
		item_id,
		" x",
		amount
	)


func remove_item(
	item_id: String,
	amount: int = 1
) -> bool:
	if item_id.is_empty():
		return false

	if amount <= 0:
		return false

	if not has_amount(
		item_id,
		amount
	):
		return false

	items[item_id] -= amount

	if items[item_id] <= 0:
		items.erase(item_id)

	return true


func get_item_amount(
	item_id: String
) -> int:
	if not items.has(item_id):
		return 0

	return int(items[item_id])


func has_item(
	item_id: String
) -> bool:
	return get_item_amount(item_id) > 0


func has_amount(
	item_id: String,
	amount: int
) -> bool:
	if amount <= 0:
		return false

	return get_item_amount(item_id) >= amount


func can_afford_recipe(
	recipe: RecipeData
) -> bool:
	if recipe == null:
		return false

	for ingredient: IngredientData in recipe.ingredients:
		if (
			ingredient == null
			or ingredient.item == null
		):
			return false

		if not has_amount(
			ingredient.item.id,
			ingredient.amount
		):
			return false

	return true


func remove_recipe_ingredients(
	recipe: RecipeData
) -> bool:
	if not can_afford_recipe(recipe):
		return false

	for ingredient: IngredientData in recipe.ingredients:
		remove_item(
			ingredient.item.id,
			ingredient.amount
		)

	return true


func add_recipe_results(
	recipe: RecipeData
) -> void:
	if recipe == null:
		return

	for result: IngredientData in recipe.results:
		if (
			result == null
			or result.item == null
		):
			continue

		add_item(
			result.item.id,
			result.amount
		)
