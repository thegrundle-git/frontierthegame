extends Node


var random := RandomNumberGenerator.new()


func _ready() -> void:
	random.randomize()


func generate_search_find(
	actor_name: String,
	location: LocationData,
	item: ItemData,
	amount: int
) -> String:
	if location == null or item == null:
		return actor_name + " found something useful."

	var opening := _pick_string(
		_get_search_openings(location.id)
	)

	var discovery := _pick_string(
		_get_item_discoveries(item.id)
	)

	return (
		actor_name
		+ " "
		+ opening
		+ " "
		+ discovery
		+ _format_amount_suffix(amount)
	)


func generate_empty_search(
	actor_name: String,
	location: LocationData
) -> String:
	if location == null:
		return (
			actor_name
			+ " searched for a while but found nothing useful."
		)

	var empty_result := _pick_string(
		_get_empty_search_results(location.id)
	)

	return actor_name + " " + empty_result


func _get_search_openings(
	location_id: String
) -> Array[String]:
	match location_id:
		"forest":
			return [
				"searched beneath the tangled canopy.",
				"picked carefully through the undergrowth.",
				"followed a narrow opening between the trees.",
				"searched among roots, moss, and fallen branches."
			]

		"river":
			return [
				"searched along the damp riverbank.",
				"followed the edge of the slow-moving water.",
				"picked through debris left behind by the current.",
				"searched where mud and exposed roots met the water."
			]

		"meadow":
			return [
				"moved slowly through the tall grass.",
				"searched among the sunlit plants.",
				"followed faint trails through the meadow.",
				"parted the grass and examined the ground beneath."
			]

		_:
			return [
				"searched the surrounding area.",
				"looked carefully across the nearby ground."
			]


func _get_item_discoveries(
	item_id: String
) -> Array[String]:
	match item_id:
		"stick":
			return [
				"A dry stick lay caught among the vegetation.",
				"A usable stick had fallen clear of the damp ground.",
				"Among the debris was a straight piece of wood worth carrying."
			]

		"stone":
			return [
				"A solid stone stood out from the loose earth.",
				"A smooth stone had been exposed by weather and passing water.",
				"Among the smaller fragments was a stone with useful weight."
			]

		"berry":
			return [
				"A cluster of Wild Berries remained untouched on a low plant.",
				"Dark Wild Berries were growing beneath the leaves.",
				"A small patch of ripe Wild Berries had escaped the animals."
			]

		"herb":
			return [
				"The sharp scent of crushed leaves revealed a patch of Wild Herb.",
				"Wild Herb grew where the grass had recently been disturbed.",
				"A hardy patch of Wild Herb stood above the surrounding plants."
			]

		"flower":
			return [
				"A Wild Flower rose above the grass on a narrow green stem.",
				"Bright petals marked the location of a Wild Flower.",
				"A single Wild Flower had survived among the taller plants."
			]

		_:
			return [
				"Something useful was found nearby.",
				"The search uncovered an item worth keeping."
			]


func _get_empty_search_results(
	location_id: String
) -> Array[String]:
	match location_id:
		"forest":
			return [
				"searched beneath the trees but found only damp leaves and rotten wood.",
				"followed several promising signs, but none led to anything useful.",
				"searched the undergrowth and returned empty-handed."
			]

		"river":
			return [
				"searched the riverbank but found only mud and waterlogged debris.",
				"followed the current for a while without finding anything useful.",
				"searched between the exposed roots and came away empty-handed."
			]

		"meadow":
			return [
				"searched through the tall grass but found nothing worth carrying.",
				"followed several faint trails that ended without reward.",
				"searched among the flowers and insects but found nothing useful."
			]

		_:
			return [
				"searched carefully but found nothing useful.",
				"returned from the search empty-handed."
			]


func _format_amount_suffix(
	amount: int
) -> String:
	if amount <= 1:
		return ""

	return " Several were gathered."


func _pick_string(
	options: Array[String]
) -> String:
	if options.is_empty():
		return ""

	var index: int = random.randi_range(
		0,
		options.size() - 1
	)

	return options[index]
