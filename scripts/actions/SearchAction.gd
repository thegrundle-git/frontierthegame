extends Node
class_name SearchAction


func perform(survivor: Survivor) -> bool:
	if survivor == null:
		return false

	var location := GameManager.current_location

	if location == null:
		_add_event(
			"There is nowhere to search."
		)
		return false

	var chosen_entry := _choose_loot_entry(
		location
	)

	survivor.gain_knowledge(1)

	if chosen_entry == null:
		_add_event(
			survivor.data.display_name
			+ " searched "
			+ location.display_name
			+ " but found nothing useful."
		)

		DiscoveryManager.check_discoveries()
		return true

	if chosen_entry.item == null:
		push_warning(
			"Search loot entry has no item in location: "
			+ location.id
		)
		return false

	var amount := chosen_entry.get_random_amount()
	var item := chosen_entry.item

	survivor.inventory.add_item(
		item.id,
		amount
	)

	DiscoveryManager.record_item_observation(
		item.id
	)

	DiscoveryManager.check_discoveries()

	_add_event(
		survivor.data.display_name
		+ " searched "
		+ location.display_name
		+ " and found "
		+ item.display_name
		+ "."
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

	for entry in location.search_loot:
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

	for entry in location.search_loot:
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
func _add_event(message: String) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(message)
