extends Node
class_name ChopTreeAction


const REQUIRED_TOOL_ID := "stone_axe"
const WOOD_LOG_ITEM_ID := "wood_log"

const STRENGTH_XP_REWARD := 2
const STRENGTH_BONUS_LEVEL := 10
const GATHERING_BONUS_LEVEL := 5


func perform(
	survivor: Survivor
) -> bool:
	if survivor == null:
		return false

	if not survivor.has_equipped_tool(
		REQUIRED_TOOL_ID
	):
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
			survivor
		)
	)

	civilization.inventory.add_item(
		WOOD_LOG_ITEM_ID,
		amount
	)

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


func _calculate_log_yield(
	survivor: Survivor
) -> int:
	var amount := 1

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
