extends Control
class_name JournalUI


signal back_requested
signal legacy_summary_requested
signal completed_life_requested(character_id: String)


@onready var journal_tabs: TabContainer = %JournalTabs
@onready var history_log: RichTextLabel = %HistoryLog
@onready var legacy_preview_log: RichTextLabel = %LegacyPreviewLog
@onready var open_legacy_summary_button: Button = %OpenLegacySummaryButton
@onready var completed_lives_log: RichTextLabel = %CompletedLivesLog
@onready var completed_life_selector: OptionButton = %CompletedLifeSelector
@onready var open_completed_life_button: Button = %OpenCompletedLifeButton
@onready var locations_log: RichTextLabel = %LocationsLog
@onready var discoveries_log: RichTextLabel = %DiscoveriesLog
@onready var fragments_log: RichTextLabel = %FragmentsLog
@onready var fragments_tab: Control = %Fragments
@onready var landmarks_log: RichTextLabel = %LandmarksLog
@onready var landmarks_tab: Control = %Landmarks
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(back_requested.emit)
	open_legacy_summary_button.pressed.connect(legacy_summary_requested.emit)
	open_completed_life_button.pressed.connect(_on_open_completed_life_pressed)


func get_default_focus_target() -> Control:
	return journal_tabs


func refresh() -> void:
	_update_history()
	_update_legacy_preview()
	_update_completed_lives()
	_update_locations()
	_update_discoveries()
	_update_fragments()
	_update_landmarks()
	_update_tab_visibility()


func _update_history() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.history_entries.is_empty():
		history_log.text = "No milestones have been recorded."
		return

	var history_text: String = ""
	for entry: CivilizationHistoryEntry in civilization.history_entries:
		if entry == null:
			continue
		if not history_text.is_empty():
			history_text += "\n\n"
		history_text += entry.title
		history_text += (
			"\nDay " + str(entry.day) + " — "
			+ str(entry.hour).pad_zeros(2) + ":"
			+ str(entry.minute).pad_zeros(2)
		)
		if not entry.contributor_name.is_empty():
			history_text += "\nContributor: " + entry.contributor_name
		if not entry.description.is_empty():
			history_text += "\n" + entry.description

	history_log.text = history_text


func _update_legacy_preview() -> void:
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null or survivor.data == null or survivor.data.life_record == null:
		legacy_preview_log.text = "No character life record is available."
		open_legacy_summary_button.disabled = true
		return

	var life_record: CharacterLifeRecord = survivor.data.life_record
	var first_day_text := "Not yet recorded"
	var latest_day_text := "Not yet recorded"
	if life_record.first_recorded_day > 0:
		first_day_text = str(life_record.first_recorded_day)
	if life_record.latest_recorded_day > 0:
		latest_day_text = str(life_record.latest_recorded_day)

	var credited_milestones := 0
	var character_id: String = survivor.data.character_id
	var civilization: CivilizationData = GameManager.current_civilization
	if not character_id.is_empty() and civilization != null:
		for entry: CivilizationHistoryEntry in civilization.history_entries:
			if (
				entry != null
				and not entry.contributor_id.is_empty()
				and entry.contributor_id == character_id
			):
				credited_milestones += 1

	legacy_preview_log.text = (
		survivor.data.display_name + " — Life Record\n\n"
		+ "First recorded day: " + first_day_text
		+ "\nLatest recorded day: " + latest_day_text
		+ "\n\nSearches completed: " + str(life_record.searches_completed)
		+ "\nItem units gathered: " + str(life_record.item_units_gathered)
		+ "\nCrafting actions completed: " + str(life_record.crafting_actions_completed)
		+ "\nItem units crafted: " + str(life_record.item_units_crafted)
		+ "\nDiscoveries contributed: " + str(life_record.discoveries_contributed)
		+ "\nKnowledge earned: " + str(life_record.knowledge_earned)
		+ "\nSkill levels gained: " + str(life_record.skill_levels_gained)
		+ "\nHistorical milestones credited: " + str(credited_milestones)
	)
	open_legacy_summary_button.disabled = false


func _update_completed_lives() -> void:
	var previous_character_id := ""
	if completed_life_selector.selected >= 0:
		previous_character_id = str(
			completed_life_selector.get_item_metadata(completed_life_selector.selected)
		)

	completed_life_selector.clear()
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.archived_lives.is_empty():
		completed_lives_log.text = "No completed lives have been recorded."
		completed_life_selector.disabled = true
		open_completed_life_button.disabled = true
		return

	var journal_text := ""
	var restored_index := -1
	for archived_life: ArchivedCharacterLife in civilization.archived_lives:
		if archived_life == null or not archived_life.is_valid():
			continue
		if not journal_text.is_empty():
			journal_text += "\n\n"
		journal_text += (
			archived_life.display_name + "\nDied on Day "
			+ str(archived_life.life_record.death_day) + " — "
			+ archived_life.life_record.cause_of_death
		)
		completed_life_selector.add_item(archived_life.display_name)
		var index: int = completed_life_selector.item_count - 1
		completed_life_selector.set_item_metadata(index, archived_life.character_id)
		if archived_life.character_id == previous_character_id:
			restored_index = index

	completed_lives_log.text = journal_text
	var has_entries: bool = completed_life_selector.item_count > 0
	completed_life_selector.disabled = not has_entries
	open_completed_life_button.disabled = not has_entries
	if restored_index >= 0:
		completed_life_selector.select(restored_index)


func _on_open_completed_life_pressed() -> void:
	if completed_life_selector.selected < 0:
		return
	var character_id := str(
		completed_life_selector.get_item_metadata(completed_life_selector.selected)
	)
	if not character_id.is_empty():
		completed_life_requested.emit(character_id)


func _update_locations() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.visited_location_ids.is_empty():
		locations_log.text = "No locations recorded."
		return

	var journal_text := ""
	for location_id: String in civilization.visited_location_ids:
		var location: LocationData = LocationDatabase.get_location(location_id)
		if location == null:
			continue
		if not journal_text.is_empty():
			journal_text += "\n\n"
		journal_text += "[b]" + location.display_name + "[/b]\n" + location.description
	locations_log.text = journal_text


func _update_discoveries() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.discovered_ids.is_empty():
		discoveries_log.text = "No discoveries recorded."
		return

	var journal_text := ""
	for discovery_id: String in civilization.discovered_ids:
		var discovery: DiscoveryData = DiscoveryDatabase.get_discovery(discovery_id)
		if discovery == null:
			continue
		if not journal_text.is_empty():
			journal_text += "\n\n"
		journal_text += "[b]" + discovery.display_name + "[/b]\n" + discovery.description
	discoveries_log.text = journal_text


func _update_landmarks() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.discovered_landmark_ids.is_empty():
		landmarks_log.text = "No landmarks recorded."
		return

	var journal_text := ""
	for landmark_id: String in civilization.discovered_landmark_ids:
		var landmark: LandmarkData = LandmarkDatabase.get_landmark(landmark_id)
		if landmark == null:
			continue
		if not journal_text.is_empty():
			journal_text += "\n\n"
		journal_text += "[b]" + landmark.display_name + "[/b]\n" + landmark.description
	landmarks_log.text = journal_text


func _update_fragments() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null or civilization.recovered_journal_fragments.is_empty():
		fragments_log.text = "No journal fragments recovered."
		return

	var journal_text := ""
	for record: RecoveredJournalFragment in civilization.recovered_journal_fragments:
		if record == null or not record.is_valid():
			continue
		var fragment: JournalFragmentData = (
			JournalFragmentDatabase.get_fragment(record.fragment_id)
		)
		if fragment == null:
			continue
		if not journal_text.is_empty():
			journal_text += "\n\n"
		journal_text += "[b]" + fragment.display_name + "[/b]"
		journal_text += "\nAttribution: " + fragment.attribution
		journal_text += (
			"\nRecovered by " + record.recovered_by_name
			+ " at " + record.location_name
			+ " on Day " + str(record.day)
			+ " — " + str(record.hour).pad_zeros(2)
			+ ":" + str(record.minute).pad_zeros(2)
		)
		journal_text += "\n\n" + fragment.physical_description
		journal_text += "\n\n[i]" + fragment.body + "[/i]"
	fragments_log.text = journal_text


func _update_tab_visibility() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	var fragments_index: int = journal_tabs.get_tab_idx_from_control(fragments_tab)
	if fragments_index >= 0:
		journal_tabs.set_tab_hidden(
			fragments_index,
			civilization == null
			or civilization.recovered_journal_fragments.is_empty()
		)
	var tab_index: int = journal_tabs.get_tab_idx_from_control(landmarks_tab)
	if tab_index < 0:
		push_warning("Landmarks tab is not a direct child of JournalTabs.")
		return
	journal_tabs.set_tab_hidden(
		tab_index,
		civilization == null or civilization.discovered_landmark_ids.is_empty()
	)
