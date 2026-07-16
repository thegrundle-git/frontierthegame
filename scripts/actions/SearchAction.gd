extends Node
class_name SearchAction


func perform(
	survivor: Survivor
) -> bool:
	if survivor == null:
		return false

	var location: LocationData = (
		GameManager.current_location
	)

	if location == null:
		_add_event(
			"There is nowhere to search."
		)
		return false

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		push_error(
			"Cannot search without a civilization."
		)
		return false

	var chosen_entry: SearchLootEntryData = (
		_choose_loot_entry(
			location
		)
	)

	DiscoveryManager.record_location_search(
		location.id
	)

	survivor.gain_knowledge(1)

	if chosen_entry == null:
		var empty_narrative: String = (
			NarrativeGenerator.generate_empty_search(
				survivor.data.display_name,
				location
			)
		)

		_add_event(
			empty_narrative
		)

		DiscoveryManager.check_discoveries()

		return true

	if chosen_entry.item == null:
		push_warning(
			"Search loot entry has no item in location: "
			+ location.id
		)
		return false

	var amount: int = (
		chosen_entry.get_random_amount()
	)

	var item: ItemData = (
		chosen_entry.item
	)

	survivor.inventory.add_item(
		item.id,
		amount
	)

	DiscoveryManager.record_item_observation(
		item.id
	)

	DiscoveryManager.check_discoveries()

	var narrative_text: String = (
		NarrativeGenerator.generate_search_find(
			survivor.data.display_name,
			location,
			item,
			amount
		)
	)

	_add_event(
		narrative_text
	)

	_add_event(
		"Found: "
		+ item.display_name
		+ " x"
		+ str(amount)
	)

	return true


func _choose_loot_entry(
	location: LocationData
) -> SearchLootEntryData:
	var total_weight: int = maxi(
		location.empty_search_weight,
		0
	)

	for entry: SearchLootEntryData in location.search_loot:
		if entry == null:
			continue

		if entry.item == null:
			continue

		total_weight += maxi(
			entry.weight,
			0
		)

	if total_weight <= 0:
		return null

	var roll: int = randi_range(
		1,
		total_weight
	)

	var empty_weight: int = maxi(
		location.empty_search_weight,
		0
	)

	if roll <= empty_weight:
		return null

	var current_weight: int = empty_weight

	for entry: SearchLootEntryData in location.search_loot:
		if entry == null:
			continue

		if entry.item == null:
			continue

		current_weight += maxi(
			entry.weight,
			0
		)

		if roll <= current_weight:
			return entry

	return null


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
