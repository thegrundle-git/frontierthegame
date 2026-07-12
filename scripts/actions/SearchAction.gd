extends Node
class_name SearchAction


func perform(survivor: Survivor) -> void:
	print(survivor.data.display_name + " searched the ground.")

	survivor.inventory.add_item("stick", 1)
	survivor.gain_gathering_xp(2)
	survivor.gain_knowledge(1)

	if GameManager.game_ui:
		GameManager.game_ui.add_event(
			survivor.data.display_name + " searched the wilderness."
		)

		GameManager.game_ui.add_event(
			"Found: Stick x1"
		)

		GameManager.game_ui.update_inventory(
			survivor.inventory
		)
