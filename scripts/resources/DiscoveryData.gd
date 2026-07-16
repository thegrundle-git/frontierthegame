extends Resource
class_name DiscoveryData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var knowledge_required: int = 0

@export var required_item_ids: Array[String] = []
@export var required_location_ids: Array[String] = []

@export var unlocked_recipes: Array[RecipeData] = []

@export var hidden_until_discovered: bool = true
