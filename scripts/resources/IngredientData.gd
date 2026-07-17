extends Resource
class_name IngredientData


@export var item: ItemData
@export var amount: int = 1

@export_group("Alternative Component")
@export var component_slot: String = ""


func uses_component_slot() -> bool:
	return item == null and not component_slot.is_empty()


func is_valid() -> bool:
	return amount > 0 and (
		item != null
		or not component_slot.is_empty()
	)
