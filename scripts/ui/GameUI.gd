extends Control


const STONE_AXE_RECIPE_ID := "stone_axe_recipe"


@onready var event_log: RichTextLabel = $EventLog
@onready var inventory_label: Label = $InventoryLabel
@onready var gathering_label: Label = $GatheringLabel

@onready var recipe_label: Label = (
	$CraftPanel/CraftList/RecipeLabel
)

@onready var craft_button: Button = (
	$CraftPanel/CraftList/CraftButton
)


func _ready() -> void:
	print("GameUI Loaded")

	GameManager.game_ui = self

	refresh_all()


func refresh_all() -> void:
	update_survivor()

	var survivor := GameManager.current_survivor

	if survivor != null:
		update_inventory(survivor.inventory)

	update_crafting()


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
		not survivor.inventory.can_afford_recipe(
			recipe
		)
	)


func _on_search_button_pressed() -> void:
	GameManager.search_area()


func _on_craft_button_pressed() -> void:
	GameManager.craft_recipe(
		STONE_AXE_RECIPE_ID
	)
