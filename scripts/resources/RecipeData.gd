extends Resource
class_name RecipeData


@export var id: String = ""
@export var display_name: String = ""

@export var ingredients: Array[IngredientData] = []
@export var results: Array[IngredientData] = []

@export var craft_time: int = 0

@export_group("Progression")
@export var skill_id: String = "crafting"
@export var xp_reward: int = 0

@export_group("Presentation")
@export_multiline
var description: String = ""
