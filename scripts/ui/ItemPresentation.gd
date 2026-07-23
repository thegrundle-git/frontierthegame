extends RefCounted
class_name ItemPresentation


const FALLBACK_COLOR := Color("e8e3d8")
const FOOD_COLOR := Color("e5ad59")
const PLANT_COLOR := Color("8fbd72")
const WOOD_COLOR := Color("bd8b5f")
const STONE_COLOR := Color("91a9b8")
const ANIMAL_COLOR := Color("d1a27e")
const METAL_COLOR := Color("aebbc5")


static func get_material_color(item: ItemData) -> Color:
	if item == null:
		return FALLBACK_COLOR

	match item.material_family:
		"food":
			return FOOD_COLOR
		"plant":
			return PLANT_COLOR
		"wood":
			return WOOD_COLOR
		"stone":
			return STONE_COLOR
		"animal":
			return ANIMAL_COLOR
		"metal":
			return METAL_COLOR
		_:
			return FALLBACK_COLOR


static func get_material_family_label(item: ItemData) -> String:
	if item == null or item.material_family == "unspecified":
		return "Unspecified"
	return item.material_family.capitalize()


static func colorize_name(item: ItemData, fallback_name: String = "") -> String:
	var display_name := fallback_name
	if item != null:
		display_name = item.display_name
	return (
		"[color=#"
		+ get_material_color(item).to_html(false)
		+ "]"
		+ display_name
		+ "[/color]"
	)


static func apply_item_list_color(
	item_list: ItemList,
	index: int,
	item: ItemData
) -> void:
	if item_list == null or index < 0:
		return
	item_list.set_item_custom_fg_color(index, get_material_color(item))
