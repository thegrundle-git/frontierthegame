extends Node
class_name Survivor


const BASE_CARRY_WEIGHT := 20.0
const CARRY_WEIGHT_PER_STRENGTH_LEVEL := 2.0

const SKILL_ORDER: Array[String] = [
	"strength",
	"gathering",
	"crafting",
	"exploration"
]


var data: SurvivorData
var inventory: FrontierInventory

var equipped_tool_id: String = ""

var skills: Dictionary = {}


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

	_initialize_skills()


func _initialize_skills() -> void:
	skills.clear()

	_create_skill(
		"strength",
		"Strength"
	)

	_create_skill(
		"gathering",
		"Gathering"
	)

	_create_skill(
		"crafting",
		"Crafting"
	)

	_create_skill(
		"exploration",
		"Exploration"
	)


func _create_skill(
	skill_id: String,
	display_name: String
) -> void:
	var skill := SkillProgress.new()

	skill.setup(
		skill_id,
		display_name
	)

	skills[skill_id] = skill


func gain_skill_xp(
	skill_id: String,
	amount: int
) -> void:
	if amount <= 0:
		return

	var skill: SkillProgress = get_skill(
		skill_id
	)

	if skill == null:
		push_warning(
			"Unknown skill ID: "
			+ skill_id
		)
		return

	var levels_gained: int = (
		skill.add_xp(amount)
	)

	_add_event(
		"+"
		+ str(amount)
		+ " "
		+ skill.display_name
		+ " XP"
	)

	if levels_gained > 0:
		_add_event(
			data.display_name
			+ " reached "
			+ skill.display_name
			+ " Level "
			+ str(skill.level)
			+ "!"
		)


func get_skill(
	skill_id: String
) -> SkillProgress:
	if not skills.has(skill_id):
		return null

	return skills[skill_id]


func get_all_skills() -> Array[SkillProgress]:
	var result: Array[SkillProgress] = []

	for skill_id: String in SKILL_ORDER:
		var skill: SkillProgress = (
			get_skill(skill_id)
		)

		if skill != null:
			result.append(skill)

	return result


func gain_gathering_xp(
	amount: int
) -> void:
	gain_skill_xp(
		"gathering",
		amount
	)


func gain_strength_xp(
	amount: int
) -> void:
	gain_skill_xp(
		"strength",
		amount
	)


func get_carry_weight_capacity() -> float:
	var strength: SkillProgress = (
		get_skill(
			"strength"
		)
	)

	if strength == null:
		return BASE_CARRY_WEIGHT

	return (
		BASE_CARRY_WEIGHT
		+ (
			float(strength.level)
			* CARRY_WEIGHT_PER_STRENGTH_LEVEL
		)
	)


func gain_knowledge(
	amount: int
) -> void:
	if amount <= 0:
		return

	if GameManager.current_civilization == null:
		return

	GameManager.current_civilization.knowledge += amount


func equip_tool(
	item_id: String
) -> bool:
	if item_id.is_empty():
		return false

	if equipped_tool_id == item_id:
		return true

	var item_data: ItemData = (
		ItemDatabase.get_item(
			item_id
		)
	)

	if item_data == null:
		return false

	if "tool" not in item_data.tags:
		return false

	var source_inventory: FrontierInventory = (
		_find_accessible_inventory_with_item(
			item_id
		)
	)

	if source_inventory == null:
		return false

	if not equipped_tool_id.is_empty():
		unequip_tool()

	if not source_inventory.remove_item(
		item_id,
		1
	):
		return false

	equipped_tool_id = item_id

	_add_event(
		data.display_name
		+ " equipped "
		+ item_data.display_name
		+ "."
	)

	return true


func unequip_tool() -> bool:
	if equipped_tool_id.is_empty():
		return false

	if inventory == null:
		return false

	var previous_tool_id := equipped_tool_id

	inventory.add_item(
		previous_tool_id,
		1
	)

	equipped_tool_id = ""

	var item_data: ItemData = (
		ItemDatabase.get_item(
			previous_tool_id
		)
	)

	if item_data != null:
		_add_event(
			data.display_name
			+ " unequipped "
			+ item_data.display_name
			+ "."
		)

	return true


func normalize_equipped_tool_ownership() -> void:
	if equipped_tool_id.is_empty():
		return

	if (
		inventory != null
		and inventory.has_item(
			equipped_tool_id
		)
	):
		inventory.remove_item(
			equipped_tool_id,
			1
		)
		return

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		civilization != null
		and civilization.inventory != null
		and civilization.inventory.has_item(
			equipped_tool_id
		)
	):
		civilization.inventory.remove_item(
			equipped_tool_id,
			1
		)


func _find_accessible_inventory_with_item(
	item_id: String
) -> FrontierInventory:
	for accessible_inventory: FrontierInventory in (
		GameManager.get_accessible_crafting_inventories()
	):
		if accessible_inventory.has_item(
			item_id
		):
			return accessible_inventory

	return null


func has_equipped_tool(
	item_id: String
) -> bool:
	return equipped_tool_id == item_id


func get_equipped_tool() -> ItemData:
	if equipped_tool_id.is_empty():
		return null

	return ItemDatabase.get_item(
		equipped_tool_id
	)


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
