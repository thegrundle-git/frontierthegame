extends Control
class_name StorageUI


signal back_requested


@onready var storage_log: RichTextLabel = %StorageLog
@onready var back_button: Button = %BackButton


func _ready() -> void:
	back_button.pressed.connect(
		_on_back_pressed
	)


func refresh_storage() -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		storage_log.text = "No storage available."
		return

	var inventory: FrontierInventory = (
		civilization.inventory
	)

	if inventory == null:
		storage_log.text = "No storage available."
		return

	var storage_text := ""

	if inventory.items.is_empty():
		storage_text = "Storage is empty."
	else:
		for item_id_variant: Variant in inventory.items:
			var item_id := str(
				item_id_variant
			)

			var item: ItemData = (
				ItemDatabase.get_item(
					item_id
				)
			)

			var amount: int = (
				inventory.get_item_amount(
					item_id
				)
			)

			if item == null:
				storage_text += (
					item_id
					+ " x"
					+ str(amount)
					+ "\n"
				)
				continue

			storage_text += (
				item.display_name
				+ " x"
				+ str(amount)
				+ "\n"
			)

	storage_log.text = storage_text


func _on_back_pressed() -> void:
	back_requested.emit()
