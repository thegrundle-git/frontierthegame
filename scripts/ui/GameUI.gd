extends Control


const STONE_AXE_RECIPE_ID := "stone_axe_recipe"


@onready var event_log: RichTextLabel = %EventLog
@onready var inventory_label: Label = %InventoryLabel
@onready var skills_label: Label = %SkillsLabel
@onready var tool_label: Label = %ToolLabel
@onready var location_label: Label = %LocationLabel

@onready var time_label: Label = %TimeLabel
@onready var current_action_label: Label = %CurrentActionLabel
@onready var action_progress: ProgressBar = %ActionProgress

@onready var action_list: VBoxContainer = %ActionList
@onready var travel_list: VBoxContainer = %TravelList

@onready var recipe_label: Label = %RecipeLabel
@onready var craft_button: Button = %CraftButton
@onready var event_overlay: CenterContainer = %EventOverlay
@onready var event_title: Label = %EventTitle
@onready var event_body: Label = %EventBody
@onready var event_options: VBoxContainer = %EventOptions

var world_action_buttons: Dictionary = {}
var travel_buttons: Dictionary = {}


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

	build_world_action_buttons()
	build_travel_buttons()
	refresh_all()

	current_action_label.text = "Idle"
	action_progress.value = 0.0
	WorldEventManager.event_started.connect(
		_on_world_event_started
	)

	WorldEventManager.event_resolved.connect(
		_on_world_event_resolved
	)

	event_overlay.visible = false

func refresh_all() -> void:
	update_survivor()
	update_location()
	update_tool_display()
	update_crafting()
	update_world_action_buttons()
	update_travel_buttons()
	_update_time()

	var survivor := GameManager.current_survivor

	if survivor != null:
		update_inventory(
			survivor.inventory
		)


func add_event(event_text: String) -> void:
	event_log.append_text(
		"\n" + event_text
	)

	event_log.scroll_to_line(
		max(
			event_log.get_line_count() - 1,
			0
		)
	)


func build_world_action_buttons() -> void:
	for child in action_list.get_children():
		child.queue_free()

	world_action_buttons.clear()

	for action in GameManager.get_available_actions():
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


func build_travel_buttons() -> void:
	for child in travel_list.get_children():
		child.queue_free()

	travel_buttons.clear()

	for connection in GameManager.get_travel_connections():
		if connection == null:
			continue

		if connection.destination_id.is_empty():
			continue

		var destination := LocationDatabase.get_location(
			connection.destination_id
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


func update_location() -> void:
	var location := GameManager.current_location

	if location == null:
		location_label.text = "Unknown Location"
		return

	location_label.text = (
		location.display_name
		+ "\n\n"
		+ location.description
	)


func update_world_action_buttons() -> void:
	var survivor := GameManager.current_survivor
	var event_pending := (
		WorldEventManager.has_pending_event()
	)

	for action_id in world_action_buttons:
		var button: Button = (
			world_action_buttons[action_id]
		)

		var action := ActionDatabase.get_action(
			action_id
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
		else:
			var tool := ItemDatabase.get_item(
				action.required_tool_id
			)

			if tool != null:
				button.tooltip_text = (
					"Requires equipped "
					+ tool.display_name
				)
func update_travel_buttons() -> void:
	var event_pending := (
		WorldEventManager.has_pending_event()
	)

	for destination_id in travel_buttons:
		var button: Button = (
			travel_buttons[destination_id]
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
		for item_id in inventory.items:
			var item_data := ItemDatabase.get_item(
				item_id
			)

			var amount := inventory.get_item_amount(
				item_id
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
	var survivor := GameManager.current_survivor

	if survivor == null:
		skills_label.text = "Skills unavailable."
		return

	var skill_text := "Skills\n\n"

	for skill in survivor.get_all_skills():
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
	var survivor := GameManager.current_survivor

	if survivor == null:
		tool_label.text = "Equipped Tool: None"
		return

	var tool := survivor.get_equipped_tool()

	if tool == null:
		tool_label.text = "Equipped Tool: None"
		return

	tool_label.text = (
		"Equipped Tool: "
		+ tool.display_name
	)


func update_crafting() -> void:
	var recipe := RecipeDatabase.get_recipe(
		STONE_AXE_RECIPE_ID
	)

	var survivor := GameManager.current_survivor
	var civilization := GameManager.current_civilization

	if (
		recipe == null
		or survivor == null
		or civilization == null
	):
		recipe_label.text = "Crafting unavailable."
		craft_button.disabled = true
		return

	if not civilization.has_recipe(recipe.id):
		recipe_label.text = (
			"Crafting\n\n"
			+ "No recipes discovered."
		)

		craft_button.disabled = true
		craft_button.visible = false
		return

	craft_button.visible = true

	var recipe_text := (
		"Crafting\n\n"
		+ recipe.display_name
		+ "\n\nRequires:\n"
	)

	for ingredient in recipe.ingredients:
		if (
			ingredient == null
			or ingredient.item == null
		):
			continue

		var owned := survivor.inventory.get_item_amount(
			ingredient.item.id
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
		or not survivor.inventory.can_afford_recipe(
			recipe
		)
	)
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
	action_progress.value = progress * 100.0


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
	GameManager.craft_recipe(
		STONE_AXE_RECIPE_ID
	)
func show_world_event(
	event: WorldEventData
) -> void:
	event_title.text = event.display_name
	event_body.text = event.description

	for child in event_options.get_children():
		child.queue_free()

	for option in event.options:
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


func _on_event_option_pressed(
	option_id: String
) -> void:
	WorldEventManager.resolve_option(
		option_id
	)
