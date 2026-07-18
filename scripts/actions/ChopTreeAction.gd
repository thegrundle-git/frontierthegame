extends Node
class_name ChopTreeAction


const WOOD_LOG_ITEM_ID := "wood_log"

const STRENGTH_XP_REWARD := 2
const STRENGTH_BONUS_LEVEL := 10
const GATHERING_BONUS_LEVEL := 5


func perform(
	survivor: Survivor
) -> bool:
	if survivor == null:
		return false

	var equipped_axe: ItemInstance = _get_equipped_axe(
		survivor
	)

	if equipped_axe == null:
		_add_event(
			"A suitable axe must be equipped before chopping trees."
		)
		return false

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		push_error(
			"Cannot store gathered wood without a civilization."
		)
		return false

	var amount: int = (
		_calculate_log_yield(
			survivor,
			equipped_axe
		)
	)
	var previous_log_amount := (
		survivor.inventory.get_item_amount(
			WOOD_LOG_ITEM_ID
		)
	)

	survivor.inventory.add_item(
		WOOD_LOG_ITEM_ID,
		amount
	)

	var gathered_units := (
		survivor.inventory.get_item_amount(
			WOOD_LOG_ITEM_ID
		)
		- previous_log_amount
	)

	if (
		survivor.data != null
		and survivor.data.life_record != null
		and survivor.data.life_record.record_gathered_units(
			gathered_units,
			TimeManager.day
		)
		and GameManager.game_ui != null
	):
		GameManager.game_ui.update_legacy_preview()

	survivor.gain_strength_xp(
		STRENGTH_XP_REWARD
	)

	survivor.gain_knowledge(2)

	DiscoveryManager.record_item_observation(
		WOOD_LOG_ITEM_ID
	)

	DiscoveryManager.check_discoveries()

	_add_event(
		survivor.data.display_name
		+ " felled a small tree and cut away the usable timber."
	)

	var wood_log: ItemData = (
		ItemDatabase.get_item(
			WOOD_LOG_ITEM_ID
		)
	)

	if wood_log != null:
		_add_event(
			"Gathered: "
			+ wood_log.display_name
			+ " x"
			+ str(amount)
		)

	return true


func _get_equipped_axe(
	survivor: Survivor
) -> ItemInstance:
	var equipped_instance: ItemInstance = survivor.get_equipped_tool_instance()
	if equipped_instance == null:
		return null

	var equipped_item: ItemData = equipped_instance.get_item_data()

	if equipped_item == null:
		return null

	if "tool" not in equipped_item.tags:
		return null

	if "axe" not in equipped_item.tags:
		return null

	return equipped_instance


func _calculate_log_yield(
	survivor: Survivor,
	equipped_axe: ItemInstance
) -> int:
	var amount := maxi(
		EquipmentStatCalculator.get_tool_efficiency(equipped_axe),
		1
	)

	var gathering: SkillProgress = (
		survivor.get_skill(
			"gathering"
		)
	)

	if (
		gathering != null
		and gathering.level >= GATHERING_BONUS_LEVEL
	):
		amount += 1

	var strength: SkillProgress = (
		survivor.get_skill(
			"strength"
		)
	)

	if (
		strength != null
		and strength.level >= STRENGTH_BONUS_LEVEL
	):
		amount += 1

	return amount


func _add_event(
	message: String
) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			message
		)
