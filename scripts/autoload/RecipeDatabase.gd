extends Node


var recipes: Dictionary = {}


func _ready() -> void:
	load_recipes()


func load_recipes() -> void:
	recipes.clear()

	var recipe_paths: Array[String] = [
		"res://resources/recipes/stone_axe_head_recipe.tres",
		"res://resources/recipes/stick_handle_recipe.tres",
		"res://resources/recipes/fiber_binding_recipe.tres",
		"res://resources/recipes/stone_axe_recipe.tres",
		"res://resources/recipes/flint_axe_head_recipe.tres",
	]

	for recipe_path: String in recipe_paths:
		var recipe_resource: Resource = load(
			recipe_path
		)

		if recipe_resource == null:
			push_error(
				"Failed to load recipe: "
				+ recipe_path
			)
			continue

		if recipe_resource is not RecipeData:
			push_error(
				"Resource is not RecipeData: "
				+ recipe_path
			)
			continue

		register(
			recipe_resource
		)

	print(
		"Loaded ",
		recipes.size(),
		" recipes."
	)


func register(
	recipe: RecipeData
) -> void:
	if recipe == null:
		return

	if recipe.id.is_empty():
		push_error(
			"Recipe has no ID: "
			+ recipe.resource_path
		)
		return

	if recipes.has(recipe.id):
		return

	recipes[recipe.id] = recipe


func get_recipe(
	recipe_id: String
) -> RecipeData:
	if not recipes.has(recipe_id):
		push_warning(
			"Unknown recipe ID requested: "
			+ recipe_id
		)
		return null

	return recipes[recipe_id]


func has_recipe(
	recipe_id: String
) -> bool:
	return recipes.has(recipe_id)
