extends Resource
class_name CivilizationData


@export var display_name: String = "Unnamed Civilization"

var knowledge: int = 0
var discovered_ids: Array[String] = []
var unlocked_recipe_ids: Array[String] = []


func has_discovery(discovery_id: String) -> bool:
	return discovery_id in discovered_ids


func add_discovery(discovery: DiscoveryData) -> void:
	if has_discovery(discovery.id):
		return

	discovered_ids.append(discovery.id)

	for recipe in discovery.unlocked_recipes:
		if recipe != null and recipe.id not in unlocked_recipe_ids:
			unlocked_recipe_ids.append(recipe.id)


func has_recipe(recipe_id: String) -> bool:
	return recipe_id in unlocked_recipe_ids
