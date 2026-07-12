extends Control


const STONE_AXE_RECIPE_ID := "stone_axe_recipe"


@onready var event_log: RichTextLabel = $EventLog
@onready var inventory_label: Label = $InventoryLabel
@onready var gathering_label: Label = $GatheringLabel

@onready var time_label: Label = $TimeLabel
@onready var current_action_label: Label = (
	$CurrentActionLabel
)

@onready var action_progress: ProgressBar = (
	$ActionProgress
)

@onready var search_button: Button = (
	$ActionPanel/ActionList/SearchButton
)

@onready var recipe_label: Label = (
	$CraftPanel/CraftList/RecipeLabel
)

@onready var craft_button: Button = (
	$CraftPanel/CraftList/CraftButton
)


func _ready() -> void:
	print("GameUI Loaded")

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

	refresh_all()

	_update_time()
	_on_busy_changed(ActionManager.is_busy)

	current_action_label.text = "Idle"
	action_progress.value = 0.0

func refresh_all() -> void:
	update_survivor()

	var survivor := GameManager.current_survivor

	if survivor != null:
		update_inventory(survivor.inventory)

	update_crafting()
	_update_time()


func add_event(event_text: String) -> void:
	event_log.append_text(
		"\n" + event_text
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
		if ingredient == null or ingredient.item == null:
			continue

		var owned := (
			survivor.inventory.get_item_amount(
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
		or not survivor.inventory.can_afford_recipe(
			recipe
		)
	)


func _update_time() -> void:
	time_label.text = TimeManager.get_time_text()


func _on_action_started(
	action_name: String
) -> void:
	current_action_label.text = action_name
	action_progress.value = 0.0

	add_event(action_name + " begun.")


func _on_action_progress_changed(
	progress: float
) -> void:
	action_progress.value = progress * 100.0


func _on_action_completed(
	action_name: String
) -> void:
	current_action_label.text = "Idle"
	action_progress.value = 0.0

	add_event(action_name + " completed.")

	refresh_all()


func _on_busy_changed(is_busy: bool) -> void:
	search_button.disabled = is_busy

	if is_busy:
		craft_button.disabled = true
	else:
		update_crafting()


func _on_search_button_pressed() -> void:
	GameManager.search_area()


func _on_craft_button_pressed() -> void:
	GameManager.craft_recipe(
		STONE_AXE_RECIPE_ID
	)
