extends Node
class_name TrackAnimalsAction


func perform(
	survivor: Survivor
) -> bool:
	if survivor == null:
		return false

	var location: LocationData = (
		GameManager.current_location
	)

	if location == null:
		return false

	var roll: int = randi_range(
		1,
		100
	)

	if roll <= 45:
		_add_event(
			_get_empty_tracking_story(
				survivor.data.display_name,
				location.id
			)
		)

	elif roll <= 80:
		survivor.gain_knowledge(1)

		_add_event(
			_get_fresh_tracks_story(
				survivor.data.display_name,
				location.id
			)
		)

		_add_event(
			"Knowledge gained: 1"
		)

	else:
		survivor.gain_knowledge(2)

		_add_event(
			_get_large_tracks_story(
				survivor.data.display_name,
				location.id
			)
		)

		_add_event(
			"Knowledge gained: 2"
		)

	DiscoveryManager.check_discoveries()

	return true


func _get_empty_tracking_story(
	actor_name: String,
	location_id: String
) -> String:
	match location_id:
		"forest":
			return (
				actor_name
				+ " followed faint prints between the trees, "
				+ "but the trail disappeared beneath fallen leaves."
			)

		"meadow":
			return (
				actor_name
				+ " followed a narrow path through the grass, "
				+ "but the wind had erased most of the trail."
			)

		_:
			return (
				actor_name
				+ " searched for signs of wildlife, "
				+ "but found no trail worth following."
			)


func _get_fresh_tracks_story(
	actor_name: String,
	location_id: String
) -> String:
	match location_id:
		"forest":
			return (
				actor_name
				+ " found a line of fresh pawprints pressed "
				+ "into the damp soil. Whatever left them "
				+ "passed through recently."
			)

		"meadow":
			return (
				actor_name
				+ " found fresh hoofprints cutting across "
				+ "the meadow. Bent grass marked the animal's path."
			)

		_:
			return (
				actor_name
				+ " found a fresh trail left by a passing animal."
			)


func _get_large_tracks_story(
	actor_name: String,
	location_id: String
) -> String:
	match location_id:
		"forest":
			return (
				actor_name
				+ " uncovered deep tracks beneath the trees. "
				+ "The spacing suggests something large moved "
				+ "through the forest."
			)

		"meadow":
			return (
				actor_name
				+ " found a broad trail flattened through the grass. "
				+ "Whatever made it was heavier than the smaller "
				+ "animals normally found here."
			)

		_:
			return (
				actor_name
				+ " discovered unusually large tracks nearby."
			)


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
