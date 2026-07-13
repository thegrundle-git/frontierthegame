extends Control


const STONE_AXE_RECIPE_ID := (
	"stone_axe_recipe"
)


@onready var event_log: RichTextLabel = (
	$EventLog
)

@onready var inventory_label: Label = (
	$InventoryLabel
)

@onready var gathering_label: Label = (
	$GatheringLabel
)

@onready var tool_label: Label = (
	$ToolLabel
)

@onready var location_label: Label = (
	$LocationLabel
)

@onready var time_label: Label = (
	$TimeLabel
)

@onready var current_action_label: Label = (
	$CurrentActionLabel
)

@onready var action_progress: ProgressBar = (
	$ActionProgress
)

@onready var action_list: VBoxContainer = (
	$ActionPanel/ActionList
)

@onready var recipe_label: Label = (
	$CraftPanel/CraftList/RecipeLabel
)

@onready var craft_button: Button = (
	$CraftPanel/CraftList/CraftButton
)


var world_action_buttons: Dictionary = {}


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
	refresh_all()

	current_action_label.text = "Idle"
	action_progress.value = 0.0


func refresh_all() -> void:
	update_survivor()
	update_location()
	update_tool_display()
	update_crafting()
	update_world_action_buttons()
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

		button.pressed.connect(
			_on_world_action_pressed.bind(
				action.id
			)
		)

		action_list.add_child(button)

		world_action_buttons[action.id] = button


func update_location() -> void:
	var location := GameManager.current_location

	if location == null:
		location_label.text = (
			"Unknown Location"
		)
		return

	location_label.text = (
		location.display_name
		+ "\n\n"
		+ location.description
	)


func update_world_action_buttons() -> void:
	var survivor := GameManager.current_survivor

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

		if (
			not action.required_tool_id.is_empty()
		):
			requirements_met = (
				survivor != null
				and survivor.has_equipped_tool(
					action.required_tool_id
				)
			)

		button.disabled = (
			ActionManager.is_busy
			or not requirements_met
		)

		if requirements_met:
			button.tooltip_text = (
				action.description
			)
		else:
			var tool := ItemDatabase.get_item(
				action.required_tool_id
			)

			if tool != null:
				button.tooltip_text = (
					"Requires equipped "
					+ tool.display_name
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

			var amount := (
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
	var survivor := GameManager.current_survivor

	if survivor == null:
		return

	var level: int = (
		survivor.data.gathering_level
	)

	var xp: int = (
		survivor.data.gathering_xp
	)

	var xp_needed: int = level * 10

	gathering_label.text = (
		"Gathering\n"
		+ "Level "
		+ str(level)
		+ "\nXP "
		+ str(xp)
		+ " / "
		+ str(xp_needed)
	)


func update_tool_display() -> void:
	var survivor := GameManager.current_survivor

	if survivor == null:
		tool_label.text = (
			"Equipped Tool: None"
		)
		return

	var tool := survivor.get_equipped_tool()

	if tool == null:
		tool_label.text = (
			"Equipped Tool: None"
		)
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
	var civilization := (
		GameManager.current_civilization
	)

	if (
		recipe == null
		or survivor == null
		or civilization == null
	):
		recipe_label.text = (
			"Crafting unavailable."
		)

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

		var owned := (
			survivor.inventory
			.get_item_amount(
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
		or not survivor.inventory
		.can_afford_recipe(recipe)
	)


func _update_time() -> void:
	time_label.text = (
		TimeManager.get_time_text()
	)


func _on_world_action_pressed(
	action_id: String
) -> void:
	GameManager.start_world_action(
		action_id
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

	refresh_all()


func _on_busy_changed(
	_is_busy: bool
) -> void:
	refresh_all()


func _on_craft_button_pressed() -> void:
	GameManager.craft_recipe(
		STONE_AXE_RECIPE_ID
	)
