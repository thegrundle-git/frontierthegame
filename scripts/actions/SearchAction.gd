extends Node
class_name SearchAction


func perform(survivor: Survivor) -> void:
	var roll := randi_range(1, 100)

	var item_id := ""
	var amount := 0
	var event_text := ""

	if roll <= 45:
		item_id = "stick"
		amount = 1
		event_text = (
			survivor.data.display_name
			+ " searched beneath the brush and found a usable stick."
		)

	elif roll <= 75:
		item_id = "stone"
		amount = 1
		event_text = (
			survivor.data.display_name
			+ " uncovered a loose stone among the dirt and roots."
		)

	elif roll <= 90:
		item_id = "berry"
		amount = 1
		event_text = (
			survivor.data.display_name
			+ " found a cluster of wild berries."
		)

	else:
		event_text = (
			survivor.data.display_name
			+ " searched the area but found nothing useful."
		)

	survivor.gain_gathering_xp(2)
	survivor.gain_knowledge(1)

	if not item_id.is_empty():
		survivor.inventory.add_item(item_id, amount)

	if GameManager.game_ui:
		GameManager.game_ui.add_event(event_text)

		if not item_id.is_empty():
			var item_data := ItemDatabase.get_item(item_id)

			if item_data != null:
				GameManager.game_ui.add_event(
					"Found: "
					+ item_data.display_name
					+ " x"
					+ str(amount)
				)

		GameManager.game_ui.update_inventory(
			survivor.inventory
		)

		GameManager.game_ui.update_survivor()
