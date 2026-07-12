extends Node
class_name Survivor


var data: SurvivorData
var inventory: FrontierInventory


func initialize(survivor_data: SurvivorData) -> void:
	data = survivor_data

	inventory = load(
		"res://scripts/inventory/Inventory.gd"
	).new()

	add_child(inventory)

	print("Survivor initialized:")
	print(data.display_name)


func gain_gathering_xp(amount: int) -> void:
	data.gathering_xp += amount

	while data.gathering_xp >= data.gathering_level * 10:
		data.gathering_xp -= data.gathering_level * 10
		data.gathering_level += 1

		var message := (
			data.display_name
			+ " reached Gathering Level "
			+ str(data.gathering_level)
			+ "!"
		)

		print(message)

		if GameManager.game_ui:
			GameManager.game_ui.add_event(message)


func gain_knowledge(amount: int) -> void:
	if GameManager.current_civilization == null:
		return

	GameManager.current_civilization.knowledge += amount
