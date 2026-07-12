extends Control

@onready var event_log = $EventLog
@onready var inventory_label = $InventoryLabel

func _ready():

	print("GameUI Loaded")

	GameManager.game_ui = self
func add_event(text):

	event_log.append_text("\n" + text)
	
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

			inventory_text += item_data.display_name
			inventory_text += ": "
			inventory_text += str(amount)
			inventory_text += "\n"

	inventory_label.text = inventory_text
func _on_search_button_pressed():

	GameManager.search_area()
