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
	var survivor := GameManager.current_survivor

	if survivor == null:
		storage_log.text = "No storage available."
		return

	var inventory := survivor.inventory

	var text := ""

	if inventory.items.is_empty():
		text = "Storage is empty."
	else:
		for item_id in inventory.items:
			var item := ItemDatabase.get_item(item_id)

			if item == null:
				continue

			text += (
				item.display_name
				+ " x"
				+ str(
					inventory.get_item_amount(
						item_id
					)
				)
				+ "\n"
			)

	storage_log.text = text


func _on_back_pressed() -> void:
	back_requested.emit()
