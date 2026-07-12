extends Resource
class_name CivilizationData


@export var display_name: String = "Unnamed Civilization"


var knowledge: int = 0

var observed_item_ids: Array[String] = []
var discovered_ids: Array[String] = []
var unlocked_recipe_ids: Array[String] = []


func observe_item(item_id: String) -> bool:
	if item_id in observed_item_ids:
		return false

	observed_item_ids.append(item_id)

	print("New observation: ", item_id)

	return true


func has_observed_item(item_id: String) -> bool:
	return item_id in observed_item_ids


func has_observed_all(item_ids: Array[String]) -> bool:
	for item_id in item_ids:
		if not has_observed_item(item_id):
			return false

	return true


func has_discovery(discovery_id: String) -> bool:
	return discovery_id in discovered_ids


func add_discovery(discovery: DiscoveryData) -> bool:
	if has_discovery(discovery.id):
		return false

	discovered_ids.append(discovery.id)

	for recipe in discovery.unlocked_recipes:
		if recipe == null:
			continue

		if recipe.id not in unlocked_recipe_ids:
			unlocked_recipe_ids.append(recipe.id)

	return true


func has_recipe(recipe_id: String) -> bool:
	return recipe_id in unlocked_recipe_ids
