extends Node


func record_item_observation(item_id: String) -> void:
	var civilization := GameManager.current_civilization

	if civilization == null:
		return

	var is_new_observation := civilization.observe_item(item_id)

	if not is_new_observation:
		return

	if GameManager.game_ui:
		var item_data := ItemDatabase.get_item(item_id)

		if item_data != null:
			GameManager.game_ui.add_event(
				"New observation: " + item_data.display_name
			)


func check_discoveries() -> void:
	var civilization := GameManager.current_civilization

	if civilization == null:
		return

	for discovery_variant in DiscoveryDatabase.get_all():
		var discovery := discovery_variant as DiscoveryData

		if discovery == null:
			continue

		if civilization.has_discovery(discovery.id):
			continue

		if civilization.knowledge < discovery.knowledge_required:
			continue

		if not civilization.has_observed_all(
			discovery.required_item_ids
		):
			continue

		unlock_discovery(discovery)


func unlock_discovery(discovery: DiscoveryData) -> void:
	var civilization := GameManager.current_civilization

	if civilization == null:
		return

	if not civilization.add_discovery(discovery):
		return

	print("Discovery unlocked: ", discovery.display_name)

	if GameManager.game_ui == null:
		return

	GameManager.game_ui.add_event("")
	GameManager.game_ui.add_event(
		"DISCOVERY: " + discovery.display_name
	)
	GameManager.game_ui.add_event(
		discovery.description
	)

	for recipe in discovery.unlocked_recipes:
		if recipe == null:
			continue

		GameManager.game_ui.add_event(
			"Recipe unlocked: "
			+ recipe.display_name
		)

	GameManager.game_ui.rebuild_location_controls()
	GameManager.game_ui.refresh_all()

func record_location_search(
	location_id: String
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	if location_id != "forest" and location_id != "meadow":
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
