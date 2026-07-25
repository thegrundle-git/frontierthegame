extends Node
class_name TrackAnimalsAction


func perform(survivor: Survivor) -> bool:
	if survivor == null or survivor.data == null:
		return false

	var location: LocationData = GameManager.current_location
	if location == null:
		return false

	var entry: WeightedWildlifeSignEntryData = _choose_sign(location)
	if entry == null or entry.sign == null:
		_add_event(_get_empty_tracking_story(
			survivor.data.display_name,
			location.id
		))
		DiscoveryManager.check_discoveries()
		return true

	var sign: WildlifeSignData = entry.sign
	var exploration_level: int = _get_exploration_level(survivor)
	if exploration_level < sign.identification_level:
		_add_event(
			survivor.data.display_name
			+ " found signs of wildlife, but could not yet "
			+ "identify them with confidence."
		)
		if not sign.unidentified_description.is_empty():
			_add_event(sign.unidentified_description)
		DiscoveryManager.check_discoveries()
		return true

	_add_event(
		survivor.data.display_name
		+ " identified "
		+ sign.display_name
		+ "."
	)
	if not sign.identified_description.is_empty():
		_add_event(sign.identified_description)

	var civilization: CivilizationData = GameManager.current_civilization
	var is_new_identification: bool = false
	if civilization != null:
		is_new_identification = civilization.record_identified_wildlife_sign(
			sign.id
		)

	if is_new_identification:
		_add_event("New wildlife sign recorded: " + sign.display_name)

	var knowledge_reward: int = maxi(sign.knowledge_reward, 0)
	if knowledge_reward > 0:
		survivor.gain_knowledge(knowledge_reward)
		_add_event("Knowledge gained: " + str(knowledge_reward))

	if is_new_identification and GameManager.game_ui != null:
		GameManager.game_ui.refresh_all()

	DiscoveryManager.check_discoveries()
	return true


func _choose_sign(location: LocationData) -> WeightedWildlifeSignEntryData:
	var total_weight: int = maxi(location.empty_tracking_weight, 0)
	for entry: WeightedWildlifeSignEntryData in location.wildlife_signs:
		if entry != null and entry.is_valid():
			total_weight += entry.weight

	if total_weight <= 0:
		return null

	var roll: int = randi_range(1, total_weight)
	var running_weight: int = maxi(location.empty_tracking_weight, 0)
	if roll <= running_weight:
		return null

	for entry: WeightedWildlifeSignEntryData in location.wildlife_signs:
		if entry == null or not entry.is_valid():
			continue
		running_weight += entry.weight
		if roll <= running_weight:
			return entry

	return null


func _get_exploration_level(survivor: Survivor) -> int:
	var exploration: SkillProgress = survivor.get_skill("exploration")
	if exploration == null:
		return 1
	return maxi(exploration.level, 1)


func _get_empty_tracking_story(actor_name: String, location_id: String) -> String:
	match location_id:
		"forest":
			return (
				actor_name
				+ " searched beneath the trees, but fallen leaves "
				+ "had covered every useful sign."
			)
		"meadow":
			return (
				actor_name
				+ " searched through the grass, but the wind had "
				+ "erased every useful trail."
			)
		"river":
			return (
				actor_name
				+ " searched the riverbank, but moving water had "
				+ "washed the clearest signs away."
			)
		_:
			return (
				actor_name
				+ " searched for signs of wildlife, but found "
				+ "nothing worth recording."
			)


func _add_event(message: String) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(message)
