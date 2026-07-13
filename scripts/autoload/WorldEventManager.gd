extends Node


signal event_started(event: WorldEventData)
signal event_resolved(
	event: WorldEventData,
	option: EventOptionData
)


var pending_event: WorldEventData

var completed_event_ids: Array[String] = []


func has_pending_event() -> bool:
	return pending_event != null


func try_trigger_after_action(
	action_id: String
) -> bool:
	if has_pending_event():
		return false

	var location := GameManager.current_location

	if location == null:
		return false

	var eligible_events: Array[WorldEventData] = []

	for event_variant in WorldEventDatabase.get_all():
		var event := event_variant as WorldEventData

		if event == null:
			continue

		if not _is_event_eligible(
			event,
			action_id,
			location.id
		):
			continue

		eligible_events.append(event)

	eligible_events.shuffle()

	for event in eligible_events:
		var roll := randf_range(0.0, 100.0)

		if roll <= event.trigger_chance_percent:
			_start_event(event)
			return true

	return false


func resolve_option(option_id: String) -> bool:
	if pending_event == null:
		return false

	var chosen_option := _get_option(
		pending_event,
		option_id
	)

	if chosen_option == null:
		push_warning(
			"Unknown event option: " + option_id
		)
		return false

	var resolved_event := pending_event

	_apply_option(chosen_option)

	if resolved_event.once_only:
		if resolved_event.id not in completed_event_ids:
			completed_event_ids.append(
				resolved_event.id
			)

	pending_event = null

	event_resolved.emit(
		resolved_event,
		chosen_option
	)

	if GameManager.game_ui != null:
		GameManager.game_ui.refresh_all()

	return true


func _start_event(event: WorldEventData) -> void:
	pending_event = event

	if GameManager.game_ui != null:
		GameManager.game_ui.add_event("")
		GameManager.game_ui.add_event(
			"EVENT: " + event.display_name
		)

	event_started.emit(event)


func _apply_option(option: EventOptionData) -> void:
	var survivor := GameManager.current_survivor

	if survivor == null:
		return

	if option.game_minutes > 0:
		TimeManager.add_minutes(
			option.game_minutes
		)

	for reward in option.rewards:
		if reward == null or reward.item == null:
			continue

		survivor.inventory.add_item(
			reward.item.id,
			reward.amount
		)

		DiscoveryManager.record_item_observation(
			reward.item.id
		)

	if (
		not option.skill_id.is_empty()
		and option.xp_reward > 0
	):
		survivor.gain_skill_xp(
			option.skill_id,
			option.xp_reward
		)

	if option.knowledge_reward > 0:
		survivor.gain_knowledge(
			option.knowledge_reward
		)

	DiscoveryManager.check_discoveries()

	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			option.result_text
		)


func _is_event_eligible(
	event: WorldEventData,
	action_id: String,
	location_id: String
) -> bool:
	if (
		event.once_only
		and event.id in completed_event_ids
	):
		return false

	if (
		not event.trigger_action_ids.is_empty()
		and action_id not in event.trigger_action_ids
	):
		return false

	if (
		not event.location_ids.is_empty()
		and location_id not in event.location_ids
	):
		return false

	return true


func _get_option(
	event: WorldEventData,
	option_id: String
) -> EventOptionData:
	for option in event.options:
		if option == null:
			continue

		if option.id == option_id:
			return option

	return null
