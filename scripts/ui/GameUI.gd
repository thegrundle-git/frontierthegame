extends Control


const INTERACTIVE_CONTROL_MINIMUM_HEIGHT := 42.0
const EVENT_SEPARATOR := "────────────────────────"




@onready var event_log: RichTextLabel = %EventLog
@onready var history_log: RichTextLabel = %HistoryLog
@onready var legacy_preview_log: RichTextLabel = %LegacyPreviewLog
@onready var open_legacy_summary_button: Button = %OpenLegacySummaryButton
@onready var legacy_summary_screen: LegacySummaryScreen = %LegacySummaryScreen
@onready var succession_screen: SuccessionScreen = %SuccessionScreen
@onready var debug_death_button: Button = %DebugDeathButton
@onready var completed_lives_log: RichTextLabel = %CompletedLivesLog
@onready var completed_life_selector: OptionButton = %CompletedLifeSelector
@onready var open_completed_life_button: Button = %OpenCompletedLifeButton
@onready var inventory_label: RichTextLabel = %InventoryLabel
@onready var skills_label: Label = %SkillsLabel
@onready var tool_label: Label = %ToolLabel
@onready var open_equipment_button: Button = %OpenEquipmentButton
@onready var equipment_ui: EquipmentUI = %EquipmentUI
@onready var location_label: Label = %LocationLabel
@onready var locations_log: RichTextLabel = %LocationsLog
@onready var landmarks_log: RichTextLabel = %LandmarksLog
@onready var journal_tabs: TabContainer = %JournalTabs
@onready var landmarks_tab: Control = %Landmarks
@onready var discoveries_log: RichTextLabel = %DiscoveriesLog

@onready var time_label: Label = %TimeLabel
@onready var current_action_label: Label = %CurrentActionLabel
@onready var action_progress: ProgressBar = %ActionProgress

@onready var action_list: VBoxContainer = %ActionList
@onready var travel_list: VBoxContainer = %TravelList
@onready var home_access_panel: PanelContainer = %HomeAccessPanel
@onready var enter_camp_button: Button = %EnterCampButton

@onready var event_overlay: CenterContainer = %EventOverlay
@onready var event_title: Label = %EventTitle
@onready var event_body: Label = %EventBody
@onready var event_options: VBoxContainer = %EventOptions

@onready var home_ui: HomeUI = %HomeUI
@onready var crafting_ui: CraftingUI = %CraftingUI
@onready var storage_ui: StorageUI = %StorageUI
@onready var camp_navigation: CampNavigation = %CampNavigation

var camp_router := UIRouter.new()

var world_action_buttons: Dictionary = {}
var travel_buttons: Dictionary = {}

func _ready() -> void:
	GameManager.game_ui = self

	open_equipment_button.pressed.connect(_on_open_equipment_pressed)
	enter_camp_button.pressed.connect(_on_enter_camp_pressed)
	equipment_ui.equipment_repaired.connect(
		_on_equipment_repaired
	)
	equipment_ui.equipment_component_replaced.connect(
		_on_equipment_component_replaced
	)
	equipment_ui.equipment_disassembled.connect(
		_on_equipment_disassembled
	)

	open_legacy_summary_button.pressed.connect(
		_on_open_legacy_summary_pressed
	)
	legacy_summary_screen.save_requested.connect(
		_on_save_button_pressed
	)
	legacy_summary_screen.successor_requested.connect(
		_on_successor_requested
	)
	succession_screen.successor_selected.connect(
		_on_successor_selected
	)

	debug_death_button.pressed.connect(
		_on_debug_death_pressed
	)
	debug_death_button.visible = OS.is_debug_build()
	open_completed_life_button.pressed.connect(
		_on_open_completed_life_pressed
	)

	ActionManager.action_started.connect(
		_on_action_started
	)

	ActionManager.action_progress_changed.connect(
		_on_action_progress_changed
	)

	ActionManager.action_completed.connect(
		_on_action_completed
	)

	ActionManager.busy_changed.connect(
		_on_busy_changed
	)

	TimeManager.time_changed.connect(
		_update_time
	)

	WorldEventManager.event_started.connect(
		_on_world_event_started
	)

	WorldEventManager.event_resolved.connect(
		_on_world_event_resolved
	)

	home_ui.storage_requested.connect(
  	  _on_home_storage_requested
)

	storage_ui.back_requested.connect(
   	 _on_storage_back_requested
)
	storage_ui.equipment_inspection_requested.connect(
		_on_storage_equipment_inspection_requested
	)
	camp_navigation.screen_requested.connect(
		_on_camp_screen_requested
	)
	camp_navigation.leave_requested.connect(
		_on_leave_home_requested
	)
	crafting_ui.craft_requested.connect(_on_craft_requested)
	crafting_ui.back_requested.connect(_on_crafting_back_requested)
	equipment_ui.back_requested.connect(_on_equipment_back_requested)
	equipment_ui.equip_requested.connect(_on_equipment_equip_requested)
	equipment_ui.unequip_requested.connect(_on_equipment_unequip_requested)
	camp_router.register_screen(
		CampNavigation.OVERVIEW_SCREEN_ID,
		home_ui,
		home_ui.get_default_focus_target()
	)
	camp_router.register_screen(
		CampNavigation.STORAGE_SCREEN_ID,
		storage_ui,
		storage_ui.get_default_focus_target()
	)
	camp_router.register_screen(
		CampNavigation.CRAFTING_SCREEN_ID,
		crafting_ui,
		crafting_ui.get_default_focus_target()
	)
	camp_router.register_screen(
		CampNavigation.EQUIPMENT_SCREEN_ID,
		equipment_ui,
		equipment_ui.get_default_focus_target()
	)

	event_overlay.visible = false
	camp_router.close_all()
	camp_navigation.visible = false
	current_action_label.text = "Idle"
	action_progress.value = 0.0

	build_world_action_buttons()
	build_travel_buttons()
	refresh_all()

	GameManager.flush_pending_startup_messages()

	call_deferred(
		"_request_initial_refresh"
	)
	home_ui.leave_home_requested.connect(
		_on_leave_home_requested
)

	home_ui.crafting_requested.connect(
		_on_home_crafting_requested
)

func _unhandled_input(event: InputEvent) -> void:
	if not camp_navigation.visible and not equipment_ui.visible:
		return
	if (
		equipment_ui.has_active_modal()
		or legacy_summary_screen.visible
		or succession_screen.visible
		or event_overlay.visible
	):
		return
	if not event.is_action_pressed("ui_cancel"):
		return
	if equipment_ui.visible and not camp_navigation.visible:
		_close_camp_workspace()
		get_viewport().set_input_as_handled()
		return
	if camp_router.get_current_screen_id() == CampNavigation.OVERVIEW_SCREEN_ID:
		return

	_back_in_camp()
	get_viewport().set_input_as_handled()


func refresh_all() -> void:
	update_survivor()
	update_location()
	update_tool_display()
	crafting_ui.refresh()
	if equipment_ui.visible:
		equipment_ui.refresh()
	update_world_action_buttons()
	update_travel_buttons()
	update_home_access()
	update_locations_journal()
	update_landmarks_journal()
	update_history_journal()
	update_legacy_preview()
	update_completed_lives_journal()
	update_journal_tab_visibility()
	update_discoveries_journal()
	_update_time()
	
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	debug_death_button.disabled = (
		survivor == null
		or not survivor.can_act()
		or ActionManager.is_busy
		or WorldEventManager.has_pending_event()
	)

	if survivor != null:
		update_inventory(
			survivor.inventory
		)


func add_event(event_text: String) -> void:
	var existing_text := event_log.get_parsed_text()
	var has_existing_entries := not existing_text.is_empty()

	if event_text.is_empty():
		if has_existing_entries:
			event_log.append_text(
				"\n\n" + EVENT_SEPARATOR + "\n"
			)
	else:
		if (
			has_existing_entries
			and not existing_text.ends_with("\n")
		):
			event_log.append_text("\n\n")

		event_log.append_text(event_text)

	var last_line: int = maxi(
		event_log.get_line_count() - 1,
		0
	)

	event_log.scroll_to_line(
		last_line
	)


# -------------------------------------------------------------------
# Dynamic controls
# -------------------------------------------------------------------

func build_world_action_buttons() -> void:
	for child: Node in action_list.get_children():
		child.queue_free()

	world_action_buttons.clear()

	for action: ActionData in GameManager.get_available_actions():
		if action == null:
			continue

		var button := Button.new()

		button.name = (
			action.id.to_pascal_case()
			+ "Button"
		)

		button.text = action.display_name
		button.tooltip_text = action.description
		button.custom_minimum_size.y = (
			INTERACTIVE_CONTROL_MINIMUM_HEIGHT
		)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			_on_world_action_pressed.bind(
				action.id
			)
		)

		action_list.add_child(button)
		world_action_buttons[action.id] = button


func build_travel_buttons() -> void:
	for child: Node in travel_list.get_children():
		child.queue_free()

	travel_buttons.clear()

	for connection: TravelConnectionData in (
		GameManager.get_travel_connections()
	):
		if connection == null:
			continue

		if connection.destination_id.is_empty():
			continue

		var destination: LocationData = (
			LocationDatabase.get_location(
				connection.destination_id
			)
		)

		if destination == null:
			continue

		var button := Button.new()

		button.name = (
			"TravelTo"
			+ destination.id.to_pascal_case()
			+ "Button"
		)

		button.text = (
			"Travel to "
			+ destination.display_name
			+ " — "
			+ _format_minutes(
				connection.game_minutes
			)
		)

		button.tooltip_text = connection.description
		button.custom_minimum_size.y = (
			INTERACTIVE_CONTROL_MINIMUM_HEIGHT
		)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			_on_travel_pressed.bind(
				destination.id
			)
		)

		travel_list.add_child(button)
		travel_buttons[destination.id] = button


func rebuild_location_controls() -> void:
	build_world_action_buttons()
	build_travel_buttons()


# -------------------------------------------------------------------
# Main display updates
# -------------------------------------------------------------------

func update_location() -> void:
	var location: LocationData = (
		GameManager.current_location
	)

	if location == null:
		location_label.text = "Unknown Location"
		return

	location_label.text = (
		location.display_name
		+ "\n\n"
		+ location.description
	)


func update_home_access() -> void:
	var civilization: CivilizationData = GameManager.current_civilization
	var location: LocationData = GameManager.current_location
	var survivor: Survivor = GameManager.current_survivor
	var is_at_home := (
		civilization != null
		and location != null
		and location.id == civilization.home_location_id
	)

	home_access_panel.visible = is_at_home
	enter_camp_button.disabled = (
		not is_at_home
		or survivor == null
		or not survivor.can_act()
		or ActionManager.is_busy
		or WorldEventManager.has_pending_event()
	)


func update_world_action_buttons() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var event_pending: bool = (
		WorldEventManager.has_pending_event()
	)
	var survivor_can_act: bool = survivor != null and survivor.can_act()


	for action_id_variant: Variant in world_action_buttons:
		var action_id := str(
			action_id_variant
		)

		var button: Button = (
			world_action_buttons[action_id_variant]
		)

		var action: ActionData = (
			ActionDatabase.get_action(
				action_id
			)
		)

		if action == null:
			button.disabled = true
			continue

		var requirements_met := (
			action.is_tool_requirement_met(
				survivor
			)
		)

		button.disabled = (
			not survivor_can_act
			or
			ActionManager.is_busy
			or event_pending
			or not requirements_met
		)

		if requirements_met:
			button.tooltip_text = action.description
			continue

		if not action.required_tool_id.is_empty():
			var tool: ItemData = (
				ItemDatabase.get_item(
					action.required_tool_id
				)
			)

			if tool != null:
				button.tooltip_text = (
					"Requires equipped "
					+ tool.display_name
				)
			else:
				button.tooltip_text = (
					"Requires a suitable equipped tool."
				)

			continue

		if not action.required_tool_tags.is_empty():
			var tool_type: String = (
				action.required_tool_tags[
					action.required_tool_tags.size() - 1
				].capitalize()
			)

			button.tooltip_text = (
				"Requires equipped "
				+ tool_type
				+ "."
			)

func update_travel_buttons() -> void:
	var event_pending: bool = (
		WorldEventManager.has_pending_event()
	)
	var survivor: Survivor = GameManager.current_survivor
	var survivor_can_act: bool = survivor != null and survivor.can_act()

	for destination_id_variant: Variant in travel_buttons:
		var button: Button = (
			travel_buttons[destination_id_variant]
		)

		button.disabled = (
			not survivor_can_act
			or
			ActionManager.is_busy
			or event_pending
		)


func update_inventory(
	inventory: FrontierInventory
) -> void:
	var inventory_text := "Inventory\n\n"

	if inventory.items.is_empty() and inventory.equipment_instances.is_empty():
		inventory_text += "Empty"
	else:
		for item_id_variant: Variant in inventory.items:
			var item_id := str(
				item_id_variant
			)

			var item_data: ItemData = (
				ItemDatabase.get_item(
					item_id
				)
			)

			var amount: int = (
				inventory.get_item_amount(
					item_id
				)
			)

			if item_data == null:
				inventory_text += (
					item_id
					+ ": "
					+ str(amount)
					+ "\n"
				)
				continue

			inventory_text += (
				item_data.display_name
				+ ": "
				+ str(amount)
				+ "\n"
			)

		for instance: ItemInstance in inventory.equipment_instances:
			if instance == null:
				continue
			var item_data: ItemData = instance.get_item_data()
			var display_name := instance.item_id
			if item_data != null:
				display_name = item_data.display_name
			inventory_text += display_name + " [" + instance.instance_id + "]\n"

	inventory_label.text = inventory_text


func update_survivor() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		skills_label.text = "Skills unavailable."
		return

	var skill_text := "Skills\n\n"

	for skill: SkillProgress in survivor.get_all_skills():
		skill_text += (
			skill.display_name
			+ " — Level "
			+ str(skill.level)
			+ " — XP "
			+ str(skill.xp)
			+ " / "
			+ str(skill.get_xp_needed())
			+ "\n"
		)

	skills_label.text = skill_text


func update_tool_display() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		tool_label.text = "Equipped Tool: None"
		open_equipment_button.disabled = true
		return

	var tool: ItemData = (
		survivor.get_equipped_tool()
	)

	if tool == null:
		tool_label.text = "Equipped Tool: None"
	else:
		var equipped_instance: ItemInstance = survivor.get_equipped_tool_instance()
		tool_label.text = (
			"Equipped Tool: "
			+ tool.display_name
			+ (
				" [" + equipped_instance.instance_id + "]"
				if equipped_instance != null
				else ""
			)
		)

	open_equipment_button.disabled = false


func _on_open_equipment_pressed() -> void:
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		return

	var preferred_instance_id := ""
	var equipped_instance: ItemInstance = survivor.get_equipped_tool_instance()
	if equipped_instance != null:
		preferred_instance_id = equipped_instance.instance_id

	_open_equipment_workspace(preferred_instance_id)


func _on_equipment_repaired(_instance: ItemInstance) -> void:
	refresh_all()
	equipment_ui.refresh(_instance.instance_id)
	if storage_ui.visible:
		storage_ui.refresh_storage()


func _on_equipment_component_replaced(_instance: ItemInstance) -> void:
	refresh_all()
	equipment_ui.refresh(_instance.instance_id)
	if storage_ui.visible:
		storage_ui.refresh_storage()


func _on_equipment_disassembled(_instance_id: String) -> void:
	refresh_all()
	update_history_journal()
	if storage_ui.visible:
		storage_ui.refresh_storage()


func _on_storage_equipment_inspection_requested(
	instance: ItemInstance
) -> void:
	_open_equipment_workspace(instance.instance_id)


func _open_equipment_workspace(instance_id: String = "") -> void:
	equipment_ui.refresh(instance_id)
	if GameManager.is_survivor_at_home():
		_open_camp_screen(CampNavigation.EQUIPMENT_SCREEN_ID)
		return

	equipment_ui.set_camp_navigation_visible(false)
	camp_router.open(CampNavigation.EQUIPMENT_SCREEN_ID, false)
	camp_navigation.visible = false


func _on_equipment_equip_requested(instance_id: String) -> void:
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null or not survivor.equip_tool(instance_id):
		return
	refresh_all()
	equipment_ui.refresh(instance_id)


func _on_equipment_unequip_requested() -> void:
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null or survivor.get_equipped_tool_instance() == null:
		return
	survivor.unequip_tool()
	refresh_all()
	equipment_ui.refresh()


func _update_time() -> void:
	time_label.text = TimeManager.get_time_text()


func _format_minutes(
	total_minutes: int
) -> String:
	if total_minutes < 60:
		return str(total_minutes) + " min"

	var hours: int = total_minutes / 60
	var minutes: int = total_minutes % 60

	if minutes == 0:
		return str(hours) + " hr"

	return (
		str(hours)
		+ " hr "
		+ str(minutes)
		+ " min"
	)


# -------------------------------------------------------------------
# Journal
# -------------------------------------------------------------------

func update_history_journal() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		civilization == null
		or civilization.history_entries.is_empty()
	):
		history_log.text = (
			"No milestones have been recorded."
		)
		return

	var history_text := ""

	for entry: CivilizationHistoryEntry in (
		civilization.history_entries
	):
		if entry == null:
			continue

		if not history_text.is_empty():
			history_text += "\n\n"

		history_text += entry.title
		history_text += (
			"\nDay "
			+ str(entry.day)
			+ " — "
			+ str(entry.hour).pad_zeros(2)
			+ ":"
			+ str(entry.minute).pad_zeros(2)
		)

		if not entry.contributor_name.is_empty():
			history_text += (
				"\nContributor: "
				+ entry.contributor_name
			)

		if not entry.description.is_empty():
			history_text += "\n" + entry.description

	history_log.text = history_text


func update_legacy_preview() -> void:
	var survivor: Survivor = GameManager.current_survivor

	if (
		survivor == null
		or survivor.data == null
		or survivor.data.life_record == null
	):
		legacy_preview_log.text = "No character life record is available."
		return

	var life_record: CharacterLifeRecord = (
		survivor.data.life_record
	)
	var first_day_text := "Not yet recorded"
	var latest_day_text := "Not yet recorded"

	if life_record.first_recorded_day > 0:
		first_day_text = str(
			life_record.first_recorded_day
		)

	if life_record.latest_recorded_day > 0:
		latest_day_text = str(
			life_record.latest_recorded_day
		)

	var credited_milestones := 0
	var character_id := survivor.data.character_id
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if not character_id.is_empty() and civilization != null:
		for entry: CivilizationHistoryEntry in (
			civilization.history_entries
		):
			if (
				entry != null
				and not entry.contributor_id.is_empty()
				and entry.contributor_id == character_id
			):
				credited_milestones += 1

	legacy_preview_log.text = (
		survivor.data.display_name
		+ " — Life Record\n\n"
		+ "First recorded day: "
		+ first_day_text
		+ "\nLatest recorded day: "
		+ latest_day_text
		+ "\n\nSearches completed: "
		+ str(life_record.searches_completed)
		+ "\nItem units gathered: "
		+ str(life_record.item_units_gathered)
		+ "\nCrafting actions completed: "
		+ str(life_record.crafting_actions_completed)
		+ "\nItem units crafted: "
		+ str(life_record.item_units_crafted)
		+ "\nDiscoveries contributed: "
		+ str(life_record.discoveries_contributed)
		+ "\nKnowledge earned: "
		+ str(life_record.knowledge_earned)
		+ "\nSkill levels gained: "
		+ str(life_record.skill_levels_gained)
		+ "\nHistorical milestones credited: "
		+ str(credited_milestones)
	)

	open_legacy_summary_button.disabled = false


func _on_open_legacy_summary_pressed() -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization

	if (
		survivor == null
		or survivor.data == null
		or survivor.data.life_record == null
	):
		return

	var history_entries: Array[CivilizationHistoryEntry] = []

	if civilization != null:
		history_entries = civilization.history_entries

	legacy_summary_screen.show_summary(
		survivor.data,
		history_entries,
		not survivor.data.is_alive
	)


func update_completed_lives_journal() -> void:
	var previous_character_id: String = ""
	if completed_life_selector.selected >= 0:
		previous_character_id = str(
			completed_life_selector.get_item_metadata(
				completed_life_selector.selected
			)
		)

	completed_life_selector.clear()
	var civilization: CivilizationData = GameManager.current_civilization

	if civilization == null or civilization.archived_lives.is_empty():
		completed_lives_log.text = "No completed lives have been recorded."
		completed_life_selector.disabled = true
		open_completed_life_button.disabled = true
		return

	var journal_text: String = ""
	var restored_index: int = -1

	for archived_life: ArchivedCharacterLife in civilization.archived_lives:
		if archived_life == null or not archived_life.is_valid():
			continue

		if not journal_text.is_empty():
			journal_text += "\n\n"

		journal_text += (
			archived_life.display_name
			+ "\nDied on Day "
			+ str(archived_life.life_record.death_day)
			+ " — "
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

	var character_id: String = str(
		completed_life_selector.get_item_metadata(
			completed_life_selector.selected
		)
	)
	var civilization: CivilizationData = GameManager.current_civilization
	if civilization == null:
		return

	for archived_life: ArchivedCharacterLife in civilization.archived_lives:
		if archived_life == null or archived_life.character_id != character_id:
			continue

		legacy_summary_screen.show_archived_summary(
			archived_life,
			civilization.history_entries
		)
		return


func show_final_legacy_summary() -> void:
	_close_camp_workspace()
	_on_open_legacy_summary_pressed()


func _on_debug_death_pressed() -> void:
	GameManager.debug_kill_current_survivor()


func _on_successor_requested() -> void:
	var candidate: Dictionary = GameManager.get_successor_candidate()
	if candidate.is_empty():
		return

	succession_screen.show_candidate(candidate)


func _on_successor_selected(
	display_name: String,
	character_id: String
) -> void:
	if not GameManager.continue_as_successor(
		display_name,
		character_id
	):
		return

	succession_screen.hide_screen()
	legacy_summary_screen.complete_final_summary()
	rebuild_location_controls()
	refresh_all()


func update_locations_journal() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		civilization == null
		or civilization.visited_location_ids.is_empty()
	):
		locations_log.text = (
			"No locations recorded."
		)
		return

	var journal_text := ""

	for location_id: String in (
		civilization.visited_location_ids
	):
		var location: LocationData = (
			LocationDatabase.get_location(
				location_id
			)
		)

		if location == null:
			continue

		if not journal_text.is_empty():
			journal_text += "\n\n"

		journal_text += (
			"[b]"
			+ location.display_name
			+ "[/b]\n"
			+ location.description
		)

	locations_log.text = journal_text


func update_landmarks_journal() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		civilization == null
		or civilization.discovered_landmark_ids.is_empty()
	):
		landmarks_log.text = (
			"No landmarks recorded."
		)
		return

	var journal_text := ""

	for landmark_id: String in (
		civilization.discovered_landmark_ids
	):
		var landmark: LandmarkData = (
			LandmarkDatabase.get_landmark(
				landmark_id
			)
		)

		if landmark == null:
			continue

		if not journal_text.is_empty():
			journal_text += "\n\n"

		journal_text += (
			"[b]"
			+ landmark.display_name
			+ "[/b]\n"
			+ landmark.description
		)

	landmarks_log.text = journal_text


func update_journal_tab_visibility() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return



	var landmarks_tab_index: int = (
		journal_tabs.get_tab_idx_from_control(
			landmarks_tab
		)
	)

	if landmarks_tab_index < 0:
		push_warning(
			"Landmarks tab is not a direct child of JournalTabs."
		)
		return

	journal_tabs.set_tab_hidden(
		landmarks_tab_index,
		civilization.discovered_landmark_ids.is_empty()
	)
	
func update_discoveries_journal() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		civilization == null
		or civilization.discovered_ids.is_empty()
	):
		discoveries_log.text = (
			"No discoveries recorded."
		)
		return

	var journal_text := ""

	for discovery_id: String in civilization.discovered_ids:
		var discovery: DiscoveryData = (
			DiscoveryDatabase.get_discovery(
				discovery_id
			)
		)

		if discovery == null:
			continue

		if not journal_text.is_empty():
			journal_text += "\n\n"

		journal_text += (
			"[b]"
			+ discovery.display_name
			+ "[/b]\n"
			+ discovery.description
		)

	discoveries_log.text = journal_text
	
# -------------------------------------------------------------------
# Action callbacks
# -------------------------------------------------------------------

func _on_world_action_pressed(
	action_id: String
) -> void:
	GameManager.start_world_action(
		action_id
	)


func _on_travel_pressed(
	destination_id: String
) -> void:
	GameManager.start_travel(
		destination_id
	)


func _on_action_started(
	action_name: String
) -> void:
	current_action_label.text = action_name
	action_progress.value = 0.0

	add_event(
		action_name + " begun."
	)


func _on_action_progress_changed(
	progress: float
) -> void:
	action_progress.value = (
		progress * 100.0
	)


func _on_action_completed(
	action_name: String
) -> void:
	current_action_label.text = "Idle"
	action_progress.value = 0.0

	add_event(
		action_name + " completed."
	)
	add_event("")

	rebuild_location_controls()
	refresh_all()


func _on_busy_changed(
	_is_busy: bool
) -> void:
	refresh_all()


func _on_craft_requested(recipe_id: String) -> void:
	GameManager.craft_recipe(recipe_id)


# -------------------------------------------------------------------
# World events
# -------------------------------------------------------------------

func show_world_event(
	event: WorldEventData
) -> void:
	event_title.text = event.display_name
	event_body.text = event.description

	for child: Node in event_options.get_children():
		child.queue_free()

	for option: EventOptionData in event.options:
		if option == null:
			continue

		var button := Button.new()

		button.text = option.display_text
		button.custom_minimum_size.y = (
			INTERACTIVE_CONTROL_MINIMUM_HEIGHT
		)
		button.focus_mode = Control.FOCUS_ALL

		button.pressed.connect(
			_on_event_option_pressed.bind(
				option.id
			)
		)

		event_options.add_child(button)

	event_overlay.visible = true
	refresh_all()


func hide_world_event() -> void:
	event_overlay.visible = false


func _on_world_event_started(
	event: WorldEventData
) -> void:
	show_world_event(event)


func _on_world_event_resolved(
	_event: WorldEventData,
	_option: EventOptionData
) -> void:
	hide_world_event()
	refresh_all()


func _on_event_option_pressed(
	option_id: String
) -> void:
	WorldEventManager.resolve_option(
		option_id
	)


# -------------------------------------------------------------------
# Save and load
# -------------------------------------------------------------------

func _on_save_button_pressed() -> void:
	SaveManager.save_game()


func _on_load_button_pressed() -> void:
	if not SaveManager.load_game():
		return

	if WorldEventManager.has_pending_event():
		show_world_event(
			WorldEventManager.pending_event
		)
	else:
		hide_world_event()

	rebuild_location_controls()
	refresh_all()


func _request_initial_refresh() -> void:
	if GameManager.current_survivor == null:
		return

	rebuild_location_controls()
	refresh_all()

func _on_enter_camp_pressed() -> void:
	if not GameManager.enter_home():
		return

	_open_camp_screen(CampNavigation.OVERVIEW_SCREEN_ID, false)


func _on_leave_home_requested() -> void:
	GameManager.leave_home()
	_close_camp_workspace()

func _on_home_crafting_requested() -> void:
	_open_camp_screen(CampNavigation.CRAFTING_SCREEN_ID)


func _on_crafting_back_requested() -> void:
	_back_in_camp()


func _on_equipment_back_requested() -> void:
	if camp_navigation.visible:
		_back_in_camp()
	else:
		_close_camp_workspace()

func _on_home_storage_requested() -> void:
	_open_camp_screen(CampNavigation.STORAGE_SCREEN_ID)


func _on_storage_back_requested() -> void:
	_back_in_camp()


func _on_camp_screen_requested(screen_id: String) -> void:
	_open_camp_screen(screen_id)


func _open_camp_screen(
	screen_id: String,
	remember_current: bool = true
) -> void:
	if screen_id == CampNavigation.STORAGE_SCREEN_ID:
		storage_ui.refresh_storage()
	elif screen_id == CampNavigation.CRAFTING_SCREEN_ID:
		crafting_ui.refresh()
	elif screen_id == CampNavigation.EQUIPMENT_SCREEN_ID:
		equipment_ui.set_camp_navigation_visible(true)
		equipment_ui.refresh()

	if not camp_router.open(screen_id, remember_current):
		return

	camp_navigation.visible = true
	camp_navigation.set_current_screen(screen_id)


func _back_in_camp() -> void:
	camp_router.back(CampNavigation.OVERVIEW_SCREEN_ID)
	camp_navigation.set_current_screen(
		camp_router.get_current_screen_id()
	)


func _close_camp_workspace() -> void:
	camp_router.close_all()
	camp_navigation.visible = false
