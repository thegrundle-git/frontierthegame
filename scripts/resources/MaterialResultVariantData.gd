extends Resource
class_name MaterialResultVariantData


@export var material_id: String = ""
@export var results: Array[IngredientData] = []


func is_valid() -> bool:
	return (
		not material_id.is_empty()
		and not results.is_empty()
	)
