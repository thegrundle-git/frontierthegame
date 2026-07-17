extends Resource
class_name CharacterLifeRecord


@export var searches_completed: int = 0
@export var item_units_gathered: int = 0
@export var crafting_actions_completed: int = 0
@export var item_units_crafted: int = 0
@export var discoveries_contributed: int = 0
@export var knowledge_earned: int = 0
@export var skill_levels_gained: int = 0
@export var first_recorded_day: int = 0
@export var latest_recorded_day: int = 0


func record_search(day: int) -> bool:
	searches_completed += 1
	_record_day(day)

	return true


func record_gathered_units(
	amount: int,
	day: int
) -> bool:
	if amount <= 0:
		return false

	item_units_gathered += amount
	_record_day(day)

	return true


func record_crafting(
	action_output_units: int,
	day: int
) -> bool:
	if action_output_units <= 0:
		return false

	crafting_actions_completed += 1
	item_units_crafted += action_output_units
	_record_day(day)

	return true


func record_discovery(day: int) -> bool:
	discoveries_contributed += 1
	_record_day(day)

	return true


func record_knowledge(
	amount: int,
	day: int
) -> bool:
	if amount <= 0:
		return false

	knowledge_earned += amount
	_record_day(day)

	return true


func record_skill_levels_gained(
	amount: int,
	day: int
) -> bool:
	if amount <= 0:
		return false

	skill_levels_gained += amount
	_record_day(day)

	return true


func _record_day(day: int) -> void:
	var normalized_day := maxi(day, 1)

	if first_recorded_day == 0:
		first_recorded_day = normalized_day

	latest_recorded_day = maxi(
		latest_recorded_day,
		normalized_day
	)
