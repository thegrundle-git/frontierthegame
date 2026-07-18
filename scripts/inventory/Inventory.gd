extends RefCounted
class_name FrontierInventory


var items: Dictionary = {}
var kept_item_ids: Array[String] = []
var equipment_instances: Array[ItemInstance] = []


func add_equipment_instance(instance: ItemInstance) -> bool:
	if instance == null or not instance.is_valid():
		return false
	if get_equipment_instance(instance.instance_id) != null:
		return false

	equipment_instances.append(instance)
	return true


func get_equipment_instance(instance_id: String) -> ItemInstance:
	if instance_id.is_empty():
		return null

	for instance: ItemInstance in equipment_instances:
		if instance != null and instance.instance_id == instance_id:
			return instance

	return null


func remove_equipment_instance(instance_id: String) -> ItemInstance:
	for index: int in range(equipment_instances.size()):
		var instance: ItemInstance = equipment_instances[index]
		if instance != null and instance.instance_id == instance_id:
			equipment_instances.remove_at(index)
			return instance

	return null


func transfer_equipment_instance_to(
	target: FrontierInventory,
	instance_id: String
) -> bool:
	if target == null or target == self:
		return false

	var instance: ItemInstance = remove_equipment_instance(instance_id)
	if instance == null:
		return false
	if target.add_equipment_instance(instance):
		return true

	add_equipment_instance(instance)
	return false


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
		kept_item_ids.erase(item_id)

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


func set_item_kept(
	item_id: String,
	is_kept: bool
) -> void:
	if item_id.is_empty():
		return

	if not has_item(item_id):
		kept_item_ids.erase(item_id)
		return

	if is_kept:
		if item_id not in kept_item_ids:
			kept_item_ids.append(item_id)
	else:
		kept_item_ids.erase(item_id)


func is_item_kept(
	item_id: String
) -> bool:
	return item_id in kept_item_ids


func transfer_item_to(
	target: FrontierInventory,
	item_id: String,
	amount: int
) -> int:
	if target == null:
		return 0

	if target == self:
		return 0

	var transfer_amount: int = mini(
		amount,
		get_item_amount(item_id)
	)

	if transfer_amount <= 0:
		return 0

	if not remove_item(
		item_id,
		transfer_amount
	):
		return 0

	target.add_item(
		item_id,
		transfer_amount
	)

	return transfer_amount


func transfer_all_to(
	target: FrontierInventory,
	respect_kept_items: bool = true
) -> int:
	if target == null:
		return 0

	if target == self:
		return 0

	var total_transferred := 0
	var item_ids: Array = items.keys()

	for item_id_variant: Variant in item_ids:
		var item_id := str(
			item_id_variant
		)

		if (
			respect_kept_items
			and is_item_kept(item_id)
		):
			continue

		total_transferred += transfer_item_to(
			target,
			item_id,
			get_item_amount(item_id)
		)

	return total_transferred


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

	add_ingredient_results(
		recipe.results
	)


func add_ingredient_results(
	results: Array[IngredientData]
) -> void:
	for result: IngredientData in results:
		if (
			result == null
			or result.item == null
		):
			continue

		add_item(
			result.item.id,
			result.amount
		)
