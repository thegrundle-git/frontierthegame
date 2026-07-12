extends Control


@onready var event_log: RichTextLabel = $EventLog
@onready var inventory_label: Label = $InventoryLabel
@onready var gathering_label: Label = $GatheringLabel


func _ready() -> void:
	print("GameUI Loaded")

	GameManager.game_ui = self

	update_survivor()

	if GameManager.current_survivor != null:
		update_inventory(GameManager.current_survivor.inventory)


func add_event(event_text: String) -> void:
	event_log.append_text("\n" + event_text)


func update_inventory(inventory: FrontierInventory) -> void:
	var inventory_text := "Inventory\n\n"

	if inventory.items.is_empty():
		inventory_text += "Empty"
	else:
		for item_id in inventory.items:
			var item_data := ItemDatabase.get_item(item_id)
			var amount: int = inventory.items[item_id]

			if item_data == null:
				inventory_text += item_id + ": " + str(amount) + "\n"
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

	var level: int = survivor.data.gathering_level
	var xp: int = survivor.data.gathering_xp
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


func _on_search_button_pressed() -> void:
	GameManager.search_area()
