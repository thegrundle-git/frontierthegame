extends Control
class_name LegacySummaryScreen


signal closed
signal save_requested
signal successor_requested


@onready var character_name_label: Label = %CharacterNameLabel
@onready var title_label: Label = %TitleLabel
@onready var lifespan_label: Label = %LifespanLabel
@onready var summary_label: Label = %SummaryLabel
@onready var statistics_log: RichTextLabel = %StatisticsLog
@onready var milestones_log: RichTextLabel = %MilestonesLog
@onready var close_button: Button = %CloseButton
@onready var successor_button: Button = %SuccessorButton

var _previous_focus: Control
var _is_final: bool = false


func _ready() -> void:
	close_button.pressed.connect(_on_primary_button_pressed)
	successor_button.pressed.connect(
		func() -> void: successor_requested.emit()
	)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and not _is_final and event.is_action_pressed("ui_cancel"):
		hide_summary()
		get_viewport().set_input_as_handled()


func show_summary(
	survivor_data: SurvivorData,
	history_entries: Array[CivilizationHistoryEntry],
	is_final: bool = false
) -> void:
	if survivor_data == null or survivor_data.life_record == null:
		return

	_previous_focus = get_viewport().gui_get_focus_owner()
	_is_final = is_final
	_populate_summary(survivor_data, history_entries)
	title_label.text = (
		"FINAL LEGACY SUMMARY"
		if _is_final
		else "LEGACY SUMMARY"
	)
	close_button.visible = true
	close_button.disabled = false
	close_button.text = (
		"Save Final Record"
		if _is_final
		else "Return to Frontier"
	)
	successor_button.visible = _is_final
	successor_button.disabled = not _is_final
	visible = true
	move_to_front()
	close_button.grab_focus()


func _on_primary_button_pressed() -> void:
	if _is_final:
		save_requested.emit()
		return

	hide_summary()


func hide_summary() -> void:
	if not visible or _is_final:
		return

	visible = false

	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()

	closed.emit()


func complete_final_summary() -> void:
	_is_final = false
	hide_summary()


func _populate_summary(
	survivor_data: SurvivorData,
	history_entries: Array[CivilizationHistoryEntry]
) -> void:
	var life_record := survivor_data.life_record
	var credited_entries: Array[CivilizationHistoryEntry] = []

	if not survivor_data.character_id.is_empty():
		for entry: CivilizationHistoryEntry in history_entries:
			if (
				entry != null
				and not entry.contributor_id.is_empty()
				and entry.contributor_id == survivor_data.character_id
			):
				credited_entries.append(entry)

	character_name_label.text = survivor_data.display_name
	lifespan_label.text = _build_lifespan_text(life_record)
	summary_label.text = _build_summary_text(
		survivor_data.display_name,
		life_record,
		credited_entries
	)
	statistics_log.text = _build_statistics_text(
		life_record,
		credited_entries.size()
	)
	milestones_log.text = _build_milestones_text(credited_entries)


func _build_lifespan_text(life_record: CharacterLifeRecord) -> String:
	if life_record.is_finalized:
		return (
			"Died on Day " + str(life_record.death_day)
			+ " at " + str(life_record.death_hour).pad_zeros(2)
			+ ":" + str(life_record.death_minute).pad_zeros(2)
			+ " — " + life_record.cause_of_death
		)

	if life_record.first_recorded_day <= 0:
		return "No contributions have been recorded yet."

	if life_record.latest_recorded_day <= life_record.first_recorded_day:
		return "Recorded on Day " + str(life_record.first_recorded_day)

	return (
		"Recorded from Day "
		+ str(life_record.first_recorded_day)
		+ " through Day "
		+ str(life_record.latest_recorded_day)
	)


func _build_summary_text(
	display_name: String,
	life_record: CharacterLifeRecord,
	credited_entries: Array[CivilizationHistoryEntry]
) -> String:
	if life_record.first_recorded_day <= 0:
		return display_name + "'s story is only beginning."

	var contributions: Array[String] = []

	if life_record.searches_completed > 0:
		contributions.append("explored the wilderness")

	if life_record.crafting_actions_completed > 0:
		contributions.append("crafted useful items")

	if (
		life_record.discoveries_contributed > 0
		or life_record.knowledge_earned > 0
	):
		contributions.append("expanded the civilization's knowledge")

	if contributions.is_empty():
		contributions.append("contributed to the civilization")

	var summary := display_name + " " + contributions[0]

	if contributions.size() == 2:
		summary += " and " + contributions[1]
	elif contributions.size() > 2:
		for index: int in range(1, contributions.size() - 1):
			summary += ", " + contributions[index]

		summary += ", and " + contributions[-1]

	if not credited_entries.is_empty():
		summary += ", leaving milestones recorded in civilization history"

	return summary + "."


func _build_statistics_text(
	life_record: CharacterLifeRecord,
	credited_milestones: int
) -> String:
	return (
		"Searches completed: " + str(life_record.searches_completed)
		+ "\nItem units gathered: " + str(life_record.item_units_gathered)
		+ "\nCrafting actions completed: " + str(life_record.crafting_actions_completed)
		+ "\nItem units crafted: " + str(life_record.item_units_crafted)
		+ "\nDiscoveries contributed: " + str(life_record.discoveries_contributed)
		+ "\nKnowledge earned: " + str(life_record.knowledge_earned)
		+ "\nSkill levels gained: " + str(life_record.skill_levels_gained)
		+ "\nHistorical milestones credited: " + str(credited_milestones)
	)


func _build_milestones_text(
	credited_entries: Array[CivilizationHistoryEntry]
) -> String:
	if credited_entries.is_empty():
		return "No civilization milestones have been credited yet."

	var result := ""

	for entry: CivilizationHistoryEntry in credited_entries:
		if not result.is_empty():
			result += "\n\n"

		result += (
			"Day " + str(entry.day)
			+ " — " + str(entry.hour).pad_zeros(2)
			+ ":" + str(entry.minute).pad_zeros(2)
			+ "\n" + entry.title
		)

		if not entry.description.is_empty():
			result += "\n" + entry.description

	return result
