extends Node


const DEFAULT_SELECTOR_ID := "default"
const SEARCH_TEMPLATES: Array[NarrativeTemplateData] = [
	preload("res://resources/narrative/search/opening_forest.tres"),
	preload("res://resources/narrative/search/opening_river.tres"),
	preload("res://resources/narrative/search/opening_meadow.tres"),
	preload("res://resources/narrative/search/opening_default.tres"),
	preload("res://resources/narrative/search/empty_forest.tres"),
	preload("res://resources/narrative/search/empty_river.tres"),
	preload("res://resources/narrative/search/empty_meadow.tres"),
	preload("res://resources/narrative/search/empty_default.tres"),
	preload("res://resources/narrative/search/find_stick.tres"),
	preload("res://resources/narrative/search/find_stone.tres"),
	preload("res://resources/narrative/search/find_berry.tres"),
	preload("res://resources/narrative/search/find_herb.tres"),
	preload("res://resources/narrative/search/find_flower.tres"),
	preload("res://resources/narrative/search/find_hardwood_branch.tres"),
	preload("res://resources/narrative/search/find_river_reed.tres"),
	preload("res://resources/narrative/search/find_default.tres")
]


var random := RandomNumberGenerator.new()
var _templates_by_key: Dictionary = {}


func _ready() -> void:
	random.randomize()
	_build_template_index()


func generate_search_find(
	actor_name: String,
	location: LocationData,
	item: ItemData,
	amount: int
) -> String:
	if location == null or item == null:
		return actor_name + " found something useful."

	var context := _build_context(actor_name, location, item, amount)
	var opening := _render_template("search_opening", location.id, context)
	var discovery := _render_template("search_find", item.id, context)

	return opening + " " + discovery + _format_amount_suffix(amount)


func generate_empty_search(
	actor_name: String,
	location: LocationData
) -> String:
	if location == null:
		return actor_name + " searched for a while but found nothing useful."

	var context := _build_context(actor_name, location, null, 0)
	return _render_template("search_empty", location.id, context)


func render_contextual_text(text: String) -> String:
	var survivor: Survivor = GameManager.current_survivor
	var actor_name := "The survivor"
	if survivor != null and survivor.data != null:
		actor_name = survivor.data.display_name
	var context := _build_context(
		actor_name,
		GameManager.current_location,
		null,
		0
	)
	return _render_text(text, context)


func _build_template_index() -> void:
	_templates_by_key.clear()

	for template: NarrativeTemplateData in SEARCH_TEMPLATES:
		if template == null or template.category.is_empty():
			continue
		var selector_id := template.selector_id
		if selector_id.is_empty():
			selector_id = DEFAULT_SELECTOR_ID
		_templates_by_key[_template_key(template.category, selector_id)] = template


func _render_template(
	category: String,
	selector_id: String,
	context: Dictionary
) -> String:
	var template := _get_template(category, selector_id)
	if template == null or template.variants.is_empty():
		return ""

	var variant := _pick_string(template.variants)
	return _render_text(variant, context)


func _render_text(text: String, context: Dictionary) -> String:
	var rendered := text
	for key_variant: Variant in context:
		var key := str(key_variant)
		rendered = rendered.replace(
			"{" + key + "}",
			str(context[key_variant])
		)
	return rendered


func _get_template(
	category: String,
	selector_id: String
) -> NarrativeTemplateData:
	var key := _template_key(category, selector_id)
	if _templates_by_key.has(key):
		return _templates_by_key[key] as NarrativeTemplateData

	var fallback_key := _template_key(category, DEFAULT_SELECTOR_ID)
	if _templates_by_key.has(fallback_key):
		return _templates_by_key[fallback_key] as NarrativeTemplateData

	return null


func _build_context(
	actor_name: String,
	location: LocationData,
	item: ItemData,
	amount: int
) -> Dictionary:
	return {
		"actor_name": actor_name,
		"location_name": location.display_name if location != null else "the wilderness",
		"item_name": item.display_name if item != null else "",
		"amount": amount,
		"day": TimeManager.day,
		"time": TimeManager.get_time_text()
	}


func _template_key(category: String, selector_id: String) -> String:
	return category + ":" + selector_id


func _format_amount_suffix(amount: int) -> String:
	if amount <= 1:
		return ""
	return " Several were gathered."


func _pick_string(options: Array[String]) -> String:
	if options.is_empty():
		return ""
	var index: int = random.randi_range(0, options.size() - 1)
	return options[index]
