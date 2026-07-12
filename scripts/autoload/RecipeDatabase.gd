extends Node


const RECIPE_FOLDER := "res://resources/recipes/"


var recipes: Dictionary = {}


func _ready() -> void:
	load_recipes()


func load_recipes() -> void:
	recipes.clear()

	var file_names := DirAccess.get_files_at(RECIPE_FOLDER)

	for file_name in file_names:
		if not file_name.ends_with(".tres"):
			continue

		var recipe_path := RECIPE_FOLDER + file_name
		var loaded_resource := load(recipe_path)

		if loaded_resource is not RecipeData:
			push_warning(
				"Skipped non-RecipeData resource: " + recipe_path
			)
			continue

		register(loaded_resource)

	print("Loaded ", recipes.size(), " recipes.")


func register(recipe: RecipeData) -> void:
	if recipe.id.is_empty():
		push_error(
			"Recipe has no ID: " + recipe.resource_path
		)
		return

	if recipes.has(recipe.id):
		push_error(
			"Duplicate recipe ID: " + recipe.id
		)
		return

	recipes[recipe.id] = recipe


func get_recipe(recipe_id: String) -> RecipeData:
	if not recipes.has(recipe_id):
		push_warning(
			"Unknown recipe ID requested: " + recipe_id
		)
		return null

	return recipes[recipe_id]


func has_recipe(recipe_id: String) -> bool:
	return recipes.has(recipe_id)
