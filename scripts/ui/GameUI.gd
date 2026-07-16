extends Control




@onready var event_log: RichTextLabel = %EventLog
@onready var inventory_label: RichTextLabel = %InventoryLabel
@onready var skills_label: Label = %SkillsLabel
@onready var tool_label: Label = %ToolLabel
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

@onready var recipe_label: Label = %RecipeLabel
@onready var craft_button: Button = %CraftButton

var recipe_selector: OptionButton
var selected_recipe_id: String = ""

@onready var event_overlay: CenterContainer = %EventOverlay
@onready var event_title: Label = %EventTitle
@onready var event_body: Label = %EventBody
@onready var event_options: VBoxContainer = %EventOptions

@onready var home_ui: HomeUI = %HomeUI
@onready var crafting_panel: Control = %Crafting
@onready var back_to_home_button: Button = %BackToHomeButton
@onready var storage_ui: StorageUI = %StorageUI

var world_action_buttons: Dictionary = {}
var travel_buttons: Dictionary = {}
var return_home_button: Button

func _ready() -> void:
	GameManager.game_ui = self

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

	storage_ui.visible = false
	event_overlay.visible = false
	home_ui.visible = false
	crafting_panel.visible = false
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

	back_to_home_button.pressed.connect(
		_on_back_to_home_pressed
)
func refresh_all() -> void:
	update_survivor()
	update_location()
	update_tool_display()
	update_crafting()
	update_world_action_buttons()
	update_travel_buttons()
	update_locations_journal()
	update_landmarks_journal()
	update_journal_tab_visibility()
	update_discoveries_journal()
	_update_time()
	
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor != null:
		update_inventory(
			survivor.inventory
		)


func add_event(event_text: String) -> void:
	event_log.append_text(
		"\n" + event_text
	)

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
		button.custom_minimum_size.y = 38

		button.pressed.connect(
			_on_world_action_pressed.bind(
				action.id
			)
		)

		action_list.add_child(button)
		world_action_buttons[action.id] = button

	return_home_button = Button.new()
	return_home_button.name = "ReturnHomeButton"
	return_home_button.text = "Return Home"
	return_home_button.tooltip_text = (
		"Return to the safety of home."
	)
	return_home_button.custom_minimum_size.y = 38

	return_home_button.pressed.connect(
		_on_return_home_pressed
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	var current_location: LocationData = (
		GameManager.current_location
	)

	return_home_button.visible = (
		civilization != null
		and current_location != null
		and current_location.id
		== civilization.home_location_id
	)

	action_list.add_child(
		return_home_button
	)


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
		button.custom_minimum_size.y = 38

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


func update_world_action_buttons() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var event_pending: bool = (
		WorldEventManager.has_pending_event()
	)


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

		var requirements_met := true

		if not action.required_tool_id.is_empty():
			requirements_met = (
				survivor != null
				and survivor.has_equipped_tool(
					action.required_tool_id
				)
			)

		button.disabled = (
			ActionManager.is_busy
			or event_pending
			or not requirements_met
		)

		if requirements_met:
			button.tooltip_text = action.description
			continue

		var tool: ItemData = ItemDatabase.get_item(
			action.required_tool_id
		)

		if tool != null:
			button.tooltip_text = (
				"Requires equipped "
				+ tool.display_name
			)

		if return_home_button != null:
			return_home_button.disabled = (
				ActionManager.is_busy
				or event_pending
		)

func update_travel_buttons() -> void:
	var event_pending: bool = (
		WorldEventManager.has_pending_event()
	)

	for destination_id_variant: Variant in travel_buttons:
		var button: Button = (
			travel_buttons[destination_id_variant]
		)

		button.disabled = (
			ActionManager.is_busy
			or event_pending
		)


func update_inventory(
	inventory: FrontierInventory
) -> void:
	var inventory_text := "Inventory\n\n"

	if inventory.items.is_empty():
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
			+ "\nLevel "
			+ str(skill.level)
			+ " — XP "
			+ str(skill.xp)
			+ " / "
			+ str(skill.get_xp_needed())
			+ "\n\n"
		)

	skills_label.text = skill_text


func update_tool_display() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		tool_label.text = "Equipped Tool: None"
		return

	var tool: ItemData = (
		survivor.get_equipped_tool()
	)

	if tool == null:
		tool_label.text = "Equipped Tool: None"
		return

	tool_label.text = (
		"Equipped Tool: "
		+ tool.display_name
	)


func update_crafting() -> void:
	_ensure_recipe_selector()

	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		survivor == null
		or civilization == null
	):
		recipe_selector.visible = false
		recipe_label.text = "Crafting unavailable."
		craft_button.disabled = true
		craft_button.visible = false
		return

	_populate_recipe_selector(
		civilization
	)

	if selected_recipe_id.is_empty():
		recipe_selector.visible = false
		recipe_label.text = (
			"Crafting\n\n"
			+ "No recipes discovered."
		)
		craft_button.disabled = true
		craft_button.visible = false
		return

	var recipe: RecipeData = (
		RecipeDatabase.get_recipe(
			selected_recipe_id
		)
	)

	if recipe == null:
		recipe_selector.visible = false
		recipe_label.text = "Crafting unavailable."
		craft_button.disabled = true
		craft_button.visible = false
		return

	recipe_selector.visible = true
	recipe_selector.disabled = false
	craft_button.visible = true
	craft_button.text = (
		"Craft "
		+ recipe.display_name
	)

	var recipe_text := (
		recipe.display_name
		+ "\n\n"
		+ recipe.description
		+ "\n\nRequires:\n"
	)

	for ingredient: IngredientData in recipe.ingredients:
		if (
			ingredient == null
			or ingredient.item == null
		):
			continue

		var owned: int = (
	GameManager.get_accessible_crafting_item_amount(
		ingredient.item.id
	)
)

		recipe_text += (
			ingredient.item.display_name
			+ ": "
			+ str(owned)
			+ " / "
			+ str(ingredient.amount)
			+ "\n"
		)

	recipe_label.text = recipe_text

	craft_button.disabled = (
		ActionManager.is_busy
		or WorldEventManager.has_pending_event()
		or not GameManager.can_afford_recipe_from_accessible_inventories(
	recipe
)
	)


func _ensure_recipe_selector() -> void:
	if is_instance_valid(
		recipe_selector
	):
		return

	recipe_selector = OptionButton.new()
	recipe_selector.name = "RecipeSelector"
	recipe_selector.custom_minimum_size.y = 38

	recipe_selector.item_selected.connect(
		_on_recipe_selected
	)

	var crafting_layout: VBoxContainer = (
		recipe_label.get_parent()
	)

	crafting_layout.add_child(
		recipe_selector
	)

	crafting_layout.move_child(
		recipe_selector,
		recipe_label.get_index()
	)


func _populate_recipe_selector(
	civilization: CivilizationData
) -> void:
	var previous_recipe_id := (
		selected_recipe_id
	)

	recipe_selector.clear()

	for recipe_id: String in (
		civilization.unlocked_recipe_ids
	):
		var recipe: RecipeData = (
			RecipeDatabase.get_recipe(
				recipe_id
			)
		)

		if recipe == null:
			continue

		recipe_selector.add_item(
			recipe.display_name
		)

		var index: int = (
			recipe_selector.item_count - 1
		)

		recipe_selector.set_item_metadata(
			index,
			recipe.id
		)

	if recipe_selector.item_count <= 0:
		selected_recipe_id = ""
		return

	var selected_index := 0

	for index: int in range(
		recipe_selector.item_count
	):
		var recipe_id := str(
			recipe_selector.get_item_metadata(
				index
			)
		)

		if recipe_id == previous_recipe_id:
			selected_index = index
			break

	recipe_selector.select(
		selected_index
	)

	selected_recipe_id = str(
		recipe_selector.get_item_metadata(
			selected_index
		)
	)


func _on_recipe_selected(
	index: int
) -> void:
	if (
		index < 0
		or index >= recipe_selector.item_count
	):
		return

	selected_recipe_id = str(
		recipe_selector.get_item_metadata(
			index
		)
	)

	update_crafting()


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

	rebuild_location_controls()
	refresh_all()


func _on_busy_changed(
	_is_busy: bool
) -> void:
	refresh_all()


func _on_craft_button_pressed() -> void:
	if selected_recipe_id.is_empty():
		return

	GameManager.craft_recipe(
		selected_recipe_id
	)


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
		button.custom_minimum_size.y = 42

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

func _on_return_home_pressed() -> void:
	crafting_panel.visible = false
	home_ui.visible = true

func _on_leave_home_requested() -> void:
	crafting_panel.visible = false
	home_ui.visible = false

func _on_home_crafting_requested() -> void:
	home_ui.visible = false
	crafting_panel.visible = true
	update_crafting()


func _on_back_to_home_pressed() -> void:
	crafting_panel.visible = false
	home_ui.visible = true

func _on_home_storage_requested() -> void:
	home_ui.visible = false

	storage_ui.refresh_storage()

	storage_ui.visible = true


func _on_storage_back_requested() -> void:
	storage_ui.visible = false

	home_ui.visible = true
