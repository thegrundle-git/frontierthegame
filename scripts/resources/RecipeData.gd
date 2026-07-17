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

@export_group("Material Result Variants")
@export var variant_component_slot: String = ""
@export var material_result_variants: Array[MaterialResultVariantData] = []

@export_group("Presentation")
@export_multiline
var description: String = ""


func get_results_for_components(
	consumed_components: Dictionary
) -> Array[IngredientData]:
	if variant_component_slot.is_empty():
		return results

	if not consumed_components.has(
		variant_component_slot
	):
		return results

	var component := (
		consumed_components[
			variant_component_slot
		] as ItemData
	)

	if component == null:
		return results

	for variant: MaterialResultVariantData in material_result_variants:
		if (
			variant == null
			or not variant.is_valid()
		):
			continue

		if variant.material_id == component.material_id:
			return variant.results

	return results
