extends Node
class_name Survivor


var data: SurvivorData
var inventory: FrontierInventory

var equipped_tool_id: String = ""


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


func equip_tool(item_id: String) -> bool:
	if not inventory.has_item(item_id):
		return false

	var item_data := ItemDatabase.get_item(item_id)

	if item_data == null:
		return false

	if "tool" not in item_data.tags:
		return false

	equipped_tool_id = item_id

	if GameManager.game_ui:
		GameManager.game_ui.add_event(
			data.display_name
			+ " equipped "
			+ item_data.display_name
			+ "."
		)

	return true


func has_equipped_tool(item_id: String) -> bool:
	return equipped_tool_id == item_id


func get_equipped_tool() -> ItemData:
	if equipped_tool_id.is_empty():
		return null

	return ItemDatabase.get_item(equipped_tool_id)
