extends Node


func record_item_observation(
	item_id: String
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	var is_new_observation: bool = (
		civilization.observe_item(
			item_id
		)
	)

	if not is_new_observation:
		return

	if GameManager.game_ui == null:
		return

	var item_data: ItemData = (
		ItemDatabase.get_item(
			item_id
		)
	)

	if item_data != null:
		GameManager.game_ui.add_event(
			"New observation: "
			+ item_data.display_name
		)


func check_discoveries() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	for discovery_variant: Variant in (
		DiscoveryDatabase.get_all()
	):
		var discovery: DiscoveryData = (
			discovery_variant as DiscoveryData
		)

		if discovery == null:
			continue

		if civilization.has_discovery(
			discovery.id
		):
			continue

		if (
			civilization.knowledge
			< discovery.knowledge_required
		):
			continue

		if not civilization.has_observed_all(
			discovery.required_item_ids
		):
			continue

		if not _has_visited_all_locations(
			civilization,
			discovery.required_location_ids
		):
			continue

		unlock_discovery(
			discovery
		)


func unlock_discovery(
	discovery: DiscoveryData
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	if discovery == null:
		return

	if not civilization.add_discovery(
		discovery
	):
		return

	print(
		"Discovery unlocked: ",
		discovery.display_name
	)

	_record_first_discovery(
		civilization,
		discovery
	)

	if GameManager.game_ui == null:
		return

	GameManager.game_ui.add_event("")

	GameManager.game_ui.add_event(
		"DISCOVERY: "
		+ discovery.display_name
	)

	GameManager.game_ui.add_event(
		discovery.description
	)

	for recipe: RecipeData in discovery.unlocked_recipes:
		if recipe == null:
			continue

		GameManager.game_ui.add_event(
			"Recipe unlocked: "
			+ recipe.display_name
		)

	GameManager.game_ui.rebuild_location_controls()
	GameManager.game_ui.refresh_all()


func _record_first_discovery(
	civilization: CivilizationData,
	discovery: DiscoveryData
) -> void:
	var contributor_name := ""
	var survivor: Survivor = GameManager.current_survivor

	if survivor != null and survivor.data != null:
		contributor_name = survivor.data.display_name

	var description := (
		"The civilization made its first discovery: "
		+ discovery.display_name
		+ "."
	)

	if not contributor_name.is_empty():
		description = (
			contributor_name
			+ " made the civilization's first discovery: "
			+ discovery.display_name
			+ "."
		)

	var recorded := civilization.record_history_event(
		CivilizationData.HISTORY_FIRST_DISCOVERY,
		"First Discovery: " + discovery.display_name,
		description,
		"discovery",
		"",
		contributor_name,
		TimeManager.day,
		TimeManager.hour,
		TimeManager.minute
	)

	if recorded and GameManager.game_ui != null:
		GameManager.game_ui.update_history_journal()


func record_location_search(
	location_id: String
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	if (
		location_id != "forest"
		and location_id != "meadow"
	):
		return

	var search_count: int = (
		civilization.record_wilderness_search()
	)

	if search_count < 5:
		return

	var discovery: DiscoveryData = (
		DiscoveryDatabase.get_discovery(
			"animal_tracks"
		)
	)

	if discovery == null:
		push_warning(
			"Animal Tracks discovery was not found."
		)
		return

	unlock_discovery(
		discovery
	)


func _has_visited_all_locations(
	civilization: CivilizationData,
	location_ids: Array[String]
) -> bool:
	for location_id: String in location_ids:
		if not civilization.has_visited_location(
			location_id
		):
			return false

	return true
