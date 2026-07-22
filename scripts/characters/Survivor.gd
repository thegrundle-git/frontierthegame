extends Node
class_name Survivor


signal died(survivor: Survivor, cause: String)


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

var equipped_tool_instance: ItemInstance

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

	if data.life_record == null:
		data.life_record = CharacterLifeRecord.new()
	else:
		data.life_record = data.life_record.duplicate(
			true
		) as CharacterLifeRecord

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
	if not can_act():
		return
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

	if levels_gained > 0:
		AudioFeedbackManager.play_level_up(skill_id)
	else:
		AudioFeedbackManager.play_xp_gained(skill_id)

	if GameManager.game_ui != null:
		GameManager.game_ui.show_xp_popup(
			amount,
			skill.display_name
		)

	if (
		levels_gained > 0
		and data != null
		and data.life_record != null
		and data.life_record.record_skill_levels_gained(
			levels_gained,
			TimeManager.day
		)
	):
		_refresh_legacy_preview()

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
	if not can_act():
		return
	if amount <= 0:
		return

	if GameManager.current_civilization == null:
		return

	GameManager.current_civilization.knowledge += amount

	if (
		data != null
		and data.life_record != null
		and data.life_record.record_knowledge(
			amount,
			TimeManager.day
		)
	):
		_refresh_legacy_preview()


func equip_tool(
	instance_id: String
) -> bool:
	if not can_act():
		return false
	if instance_id.is_empty():
		return false

	if (
		equipped_tool_instance != null
		and equipped_tool_instance.instance_id == instance_id
	):
		return true

	var source_inventory: FrontierInventory = (
		_find_accessible_inventory_with_instance(instance_id)
	)
	if source_inventory == null:
		return false

	var instance: ItemInstance = source_inventory.get_equipment_instance(instance_id)
	if instance == null:
		return false

	var item_data: ItemData = instance.get_item_data()
	if item_data == null or "tool" not in item_data.tags:
		return false

	if equipped_tool_instance != null:
		unequip_tool()

	instance = source_inventory.remove_equipment_instance(instance_id)
	if instance == null:
		return false

	equipped_tool_instance = instance

	_add_event(
		data.display_name
		+ " equipped "
		+ item_data.display_name
		+ "."
	)

	return true


func unequip_tool() -> bool:
	if not can_act():
		return false
	if equipped_tool_instance == null:
		return false

	if inventory == null:
		return false

	var previous_instance: ItemInstance = equipped_tool_instance
	var item_data: ItemData = previous_instance.get_item_data()
	if not inventory.add_equipment_instance(previous_instance):
		return false

	equipped_tool_instance = null

	if item_data != null:
		_add_event(
			data.display_name
			+ " unequipped "
			+ item_data.display_name
			+ "."
		)

	return true


func can_act() -> bool:
	return data != null and data.is_alive


func die(cause: String) -> bool:
	if not can_act() or data.life_record == null:
		return false

	if not data.life_record.finalize_life(
		cause,
		TimeManager.day,
		TimeManager.hour,
		TimeManager.minute
	):
		return false

	data.is_alive = false
	died.emit(self, data.life_record.cause_of_death)

	return true


func _find_accessible_inventory_with_instance(
	instance_id: String
) -> FrontierInventory:
	for accessible_inventory: FrontierInventory in (
		GameManager.get_accessible_crafting_inventories()
	):
		if accessible_inventory.get_equipment_instance(instance_id) != null:
			return accessible_inventory

	return null


func has_equipped_tool(
	item_id: String
) -> bool:
	return (
		equipped_tool_instance != null
		and equipped_tool_instance.item_id == item_id
	)


func get_equipped_tool() -> ItemData:
	if equipped_tool_instance == null:
		return null

	return equipped_tool_instance.get_item_data()


func get_equipped_tool_instance() -> ItemInstance:
	return equipped_tool_instance


func get_accessible_equipment_instance(instance_id: String) -> ItemInstance:
	if instance_id.is_empty():
		return null
	if (
		equipped_tool_instance != null
		and equipped_tool_instance.instance_id == instance_id
	):
		return equipped_tool_instance
	for accessible_inventory: FrontierInventory in (
		GameManager.get_accessible_crafting_inventories()
	):
		var instance: ItemInstance = (
			accessible_inventory.get_equipment_instance(instance_id)
		)
		if instance != null:
			return instance
	return null


func _refresh_legacy_preview() -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.update_legacy_preview()


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
