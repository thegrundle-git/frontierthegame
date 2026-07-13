extends Node
class_name Survivor


var data: SurvivorData
var inventory: FrontierInventory

var equipped_tool_id: String = ""


func initialize(
	survivor_data: SurvivorData
) -> void:
	if survivor_data == null:
		push_error(
			"Cannot initialize Survivor without SurvivorData."
		)
		return

	data = survivor_data

	inventory = FrontierInventory.new()
	add_child(inventory)


func gain_gathering_xp(amount: int) -> void:
	if data == null or amount <= 0:
		return

	data.gathering_xp += amount

	while data.gathering_xp >= _gathering_xp_needed():
		data.gathering_xp -= _gathering_xp_needed()
		data.gathering_level += 1

		_add_event(
			data.display_name
			+ " reached Gathering Level "
			+ str(data.gathering_level)
			+ "!"
		)


func gain_knowledge(amount: int) -> void:
	if amount <= 0:
		return

	if GameManager.current_civilization == null:
		return

	GameManager.current_civilization.knowledge += amount


func equip_tool(item_id: String) -> bool:
	if inventory == null:
		return false

	if not inventory.has_item(item_id):
		return false

	var item_data := ItemDatabase.get_item(item_id)

	if item_data == null:
		return false

	if "tool" not in item_data.tags:
		return false

	equipped_tool_id = item_id

	_add_event(
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

	return ItemDatabase.get_item(
		equipped_tool_id
	)


func _gathering_xp_needed() -> int:
	return data.gathering_level * 10


func _add_event(message: String) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(message)
