extends Control


const INTERACTIVE_CONTROL_MINIMUM_HEIGHT := 42.0
const JOURNAL_WORKSPACE_ID := "exploration.journal"
const EVENT_SEPARATOR := "────────────────────────"
const XP_POPUP_COLOR := Color(0.96, 0.80, 0.32, 1.0)
const XP_POPUP_RISE_DISTANCE := 44.0
const XP_POPUP_DURATION := 0.9
const XP_POPUP_STACK_SPACING := 28.0
const FOREST_BACKGROUND: Texture2D = preload("res://assets/backgrounds/forest.png")
const RIVER_BACKGROUND: Texture2D = preload("res://assets/backgrounds/river.png")
const MEADOW_BACKGROUND: Texture2D = preload("res://assets/backgrounds/meadow.png")
const HOME_BACKGROUND: Texture2D = preload("res://assets/backgrounds/home.png")
const PANEL_BACKGROUND_COLOR := Color(0.045, 0.052, 0.046, 0.78)
const MODAL_BACKGROUND_COLOR := Color(0.04, 0.045, 0.04, 0.94)
const CAMP_NAVIGATION_BACKGROUND_COLOR := Color(0.04, 0.045, 0.04, 1.0)
const PANEL_BORDER_COLOR := Color(0.42, 0.47, 0.38, 0.58)




@onready var legacy_summary_screen: LegacySummaryScreen = %LegacySummaryScreen
@onready var environment_background: TextureRect = %EnvironmentBackground
@onready var succession_screen: SuccessionScreen = %SuccessionScreen
@onready var debug_death_button: Button = %DebugDeathButton
@onready var journal_ui: JournalUI = %JournalUI
@onready var open_journal_button: Button = %OpenJournalButton
@onready var event_log: RichTextLabel = %EventLog
@onready var inventory_left_label: RichTextLabel = %InventoryLeftLabel
@onready var inventory_right_label: RichTextLabel = %InventoryRightLabel
@onready var skills_panel: SkillsPanel = %SkillsPanel
@onready var tool_label: Label = %ToolLabel
@onready var open_equipment_button: Button = %OpenEquipmentButton
@onready var equipment_ui: EquipmentUI = %EquipmentUI
@onready var location_label: Label = %LocationLabel

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
var exploration_router := UIRouter.new()

var world_action_buttons: Dictionary = {}
var travel_buttons: Dictionary = {}
var _active_xp_popups: Array[Label] = []


func show_xp_popup(amount: int, skill_name: String) -> void:
	if amount <= 0:
		return
	for popup_index: int in range(_active_xp_popups.size() - 1, -1, -1):
		if not is_instance_valid(_active_xp_popups[popup_index]):
			_active_xp_popups.remove_at(popup_index)

	var popup := Label.new()
	popup.text = "+" + str(amount) + " " + skill_name + " XP"
	popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	popup.z_index = 100
	popup.add_theme_color_override("font_color", XP_POPUP_COLOR)
	popup.add_theme_color_override("font_outline_color", Color(0.08, 0.07, 0.05, 0.95))
	popup.add_theme_constant_override("outline_size", 4)
	popup.add_theme_font_size_override("font_size", 18)
	add_child(popup)

	popup.reset_size()
	var viewport_size: Vector2 = get_viewport_rect().size
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var stack_index: int = _active_xp_popups.size()
	var stack_above: bool = (
		mouse_position.y
		> 36.0 + float(stack_index) * XP_POPUP_STACK_SPACING
	)
	var vertical_offset: float = (
		-28.0 - float(stack_index) * XP_POPUP_STACK_SPACING
		if stack_above
		else 18.0 + float(stack_index) * XP_POPUP_STACK_SPACING
	)
	var popup_position := mouse_position + Vector2(14.0, vertical_offset)
	popup_position.x = clampf(
		popup_position.x,
		8.0,
		maxf(viewport_size.x - popup.size.x - 8.0, 8.0)
	)
	popup_position.y = clampf(
		popup_position.y,
		8.0,
		maxf(viewport_size.y - popup.size.y - 8.0, 8.0)
	)
	popup.position = popup_position
	_active_xp_popups.append(popup)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		popup,
		"position:y",
		popup.position.y - XP_POPUP_RISE_DISTANCE,
		XP_POPUP_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		popup,
		"modulate:a",
		0.0,
		XP_POPUP_DURATION
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(
		_remove_xp_popup.bind(popup)
	)


func _remove_xp_popup(popup: Label) -> void:
	_active_xp_popups.erase(popup)
	if is_instance_valid(popup):
		popup.queue_free()

func _ready() -> void:
	GameManager.game_ui = self
	_apply_environment_surface_styles(self)
	_update_environment_background()

	open_equipment_button.pressed.connect(_on_open_equipment_pressed)
	enter_camp_button.pressed.connect(_on_enter_camp_pressed)
	open_journal_button.pressed.connect(_on_open_journal_pressed)
	journal_ui.back_requested.connect(_on_journal_back_requested)
	journal_ui.legacy_summary_requested.connect(_on_open_legacy_summary_pressed)
	journal_ui.completed_life_requested.connect(
		_on_journal_completed_life_requested
	)
	equipment_ui.equipment_repaired.connect(
		_on_equipment_repaired
	)
	equipment_ui.equipment_component_replaced.connect(
		_on_equipment_component_replaced
	)
	equipment_ui.equipment_disassembled.connect(
		_on_equipment_disassembled
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
	exploration_router.register_screen(
		JOURNAL_WORKSPACE_ID,
		journal_ui,
		journal_ui.get_default_focus_target()
	)

	event_overlay.visible = false
	camp_router.close_all()
	exploration_router.close_all()
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
	if (
		not camp_navigation.visible
		and not equipment_ui.visible
		and not journal_ui.visible
	):
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
	if journal_ui.visible:
		_close_journal_workspace()
		get_viewport().set_input_as_handled()
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
	_update_environment_background()
	update_survivor()
	update_location()
	update_tool_display()
	crafting_ui.refresh()
	if equipment_ui.visible:
		equipment_ui.refresh()
	update_world_action_buttons()
	update_travel_buttons()
	update_home_access()
	journal_ui.refresh()
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
	var existing_text: String = event_log.get_parsed_text()
	var has_existing_entries: bool = not existing_text.is_empty()

	if event_text.is_empty():
		if has_existing_entries:
			event_log.append_text("\n" + EVENT_SEPARATOR + "\n")
	else:
		if has_existing_entries and not existing_text.ends_with("\n"):
			event_log.append_text("\n")
		event_log.append_text(event_text)

	var last_line: int = maxi(event_log.get_line_count() - 1, 0)
	event_log.scroll_to_line(last_line)


func update_history_journal() -> void:
	journal_ui.refresh()


func update_legacy_preview() -> void:
	journal_ui.refresh()


func update_completed_lives_journal() -> void:
	journal_ui.refresh()


func update_locations_journal() -> void:
	journal_ui.refresh()


func update_landmarks_journal() -> void:
	journal_ui.refresh()


func update_journal_tab_visibility() -> void:
	journal_ui.refresh()


func update_discoveries_journal() -> void:
	journal_ui.refresh()


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
	var entries: Array[String] = []

	if inventory.items.is_empty() and inventory.equipment_instances.is_empty():
		inventory_left_label.text = "Empty"
		inventory_right_label.text = ""
		return

	var stack_entries: Array[String] = []
	for item_id_variant: Variant in inventory.items:
		var item_id := str(item_id_variant)
		var item_data: ItemData = ItemDatabase.get_item(item_id)
		var amount: int = inventory.get_item_amount(item_id)
		var display_name := item_id
		if item_data != null:
			display_name = item_data.display_name
		stack_entries.append(display_name + ": " + str(amount))

	stack_entries.sort()
	entries.append_array(stack_entries)

	var equipment_entries: Array[String] = []
	for instance: ItemInstance in inventory.equipment_instances:
		if instance == null:
			continue
		var item_data: ItemData = instance.get_item_data()
		var display_name := instance.item_id
		if item_data != null:
			display_name = item_data.display_name
		equipment_entries.append(display_name + " [" + instance.instance_id + "]")

	equipment_entries.sort()
	entries.append_array(equipment_entries)

	var split_index: int = ceili(float(entries.size()) / 2.0)
	var left_entries: PackedStringArray = PackedStringArray(entries.slice(0, split_index))
	var right_entries: PackedStringArray = PackedStringArray(
		entries.slice(split_index, entries.size())
	)
	inventory_left_label.text = "\n".join(left_entries)
	inventory_right_label.text = "\n".join(right_entries)


func update_survivor() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	skills_panel.refresh(survivor)


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
	equipment_ui.focus_selected_slot()


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


func _on_journal_completed_life_requested(character_id: String) -> void:
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
	exploration_router.close_all()
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
	event_body.text = NarrativeGenerator.render_contextual_text(
		event.description
	)

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


func _on_open_journal_pressed() -> void:
	journal_ui.refresh()
	exploration_router.open(JOURNAL_WORKSPACE_ID, false)


func _on_journal_back_requested() -> void:
	_close_journal_workspace()


func _close_journal_workspace() -> void:
	exploration_router.close_all()
	open_journal_button.call_deferred("grab_focus")


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
	_update_environment_background()
	if screen_id == CampNavigation.EQUIPMENT_SCREEN_ID:
		equipment_ui.focus_selected_slot()


func _back_in_camp() -> void:
	camp_router.back(CampNavigation.OVERVIEW_SCREEN_ID)
	camp_navigation.set_current_screen(
		camp_router.get_current_screen_id()
	)


func _close_camp_workspace() -> void:
	camp_router.close_all()
	camp_navigation.visible = false
	_update_environment_background()


func _update_environment_background() -> void:
	if environment_background == null:
		return

	var selected_texture: Texture2D = FOREST_BACKGROUND
	if not camp_router.get_current_screen_id().is_empty():
		selected_texture = HOME_BACKGROUND
	else:
		var location: LocationData = GameManager.current_location
		if location != null:
			match location.id:
				"river":
					selected_texture = RIVER_BACKGROUND
				"meadow":
					selected_texture = MEADOW_BACKGROUND

	environment_background.texture = selected_texture
	_update_workspace_backgrounds(selected_texture)


func _update_workspace_backgrounds(texture: Texture2D) -> void:
	for workspace: Control in [
		home_ui,
		crafting_ui,
		storage_ui,
		equipment_ui,
		journal_ui
	]:
		if workspace == null:
			continue
		var background := workspace.get_node_or_null("Background") as TextureRect
		if background != null:
			background.texture = texture


func _apply_environment_surface_styles(node: Node) -> void:
	if node is PanelContainer:
		var panel := node as PanelContainer
		var panel_style := StyleBoxFlat.new()
		if panel.name == "CampNavigation":
			panel_style.bg_color = CAMP_NAVIGATION_BACKGROUND_COLOR
		elif _is_modal_panel(panel):
			panel_style.bg_color = MODAL_BACKGROUND_COLOR
		else:
			panel_style.bg_color = PANEL_BACKGROUND_COLOR
		panel_style.border_color = PANEL_BORDER_COLOR
		panel_style.set_border_width_all(1)
		panel_style.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", panel_style)
	elif node is ColorRect and node.name == "Background":
		var background := node as ColorRect
		background.color.a = 0.16

	for child: Node in node.get_children():
		_apply_environment_surface_styles(child)


func _is_modal_panel(panel: PanelContainer) -> bool:
	return panel.name in [
		"EventPanel",
		"SummaryPanel",
		"Panel",
		"DisassemblyConfirmation"
	]
