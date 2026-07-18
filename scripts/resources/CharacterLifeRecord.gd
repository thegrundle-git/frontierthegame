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
@export var is_finalized: bool = false
@export var death_day: int = 0
@export var death_hour: int = 0
@export var death_minute: int = 0
@export var cause_of_death: String = ""


func record_search(day: int) -> bool:
	if is_finalized:
		return false
	searches_completed += 1
	_record_day(day)

	return true


func record_gathered_units(
	amount: int,
	day: int
) -> bool:
	if is_finalized:
		return false
	if amount <= 0:
		return false

	item_units_gathered += amount
	_record_day(day)

	return true


func record_crafting(
	action_output_units: int,
	day: int
) -> bool:
	if is_finalized:
		return false
	if action_output_units <= 0:
		return false

	crafting_actions_completed += 1
	item_units_crafted += action_output_units
	_record_day(day)

	return true


func record_discovery(day: int) -> bool:
	if is_finalized:
		return false
	discoveries_contributed += 1
	_record_day(day)

	return true


func record_knowledge(
	amount: int,
	day: int
) -> bool:
	if is_finalized:
		return false
	if amount <= 0:
		return false

	knowledge_earned += amount
	_record_day(day)

	return true


func record_skill_levels_gained(
	amount: int,
	day: int
) -> bool:
	if is_finalized:
		return false
	if amount <= 0:
		return false

	skill_levels_gained += amount
	_record_day(day)

	return true


func finalize_life(
	cause: String,
	day: int,
	hour: int,
	minute: int
) -> bool:
	if is_finalized or cause.strip_edges().is_empty():
		return false

	death_day = maxi(day, 1)
	death_hour = clampi(hour, 0, 23)
	death_minute = clampi(minute, 0, 59)
	cause_of_death = cause.strip_edges()
	is_finalized = true
	_record_day(death_day)

	return true


func _record_day(day: int) -> void:
	var normalized_day := maxi(day, 1)

	if first_recorded_day == 0:
		first_recorded_day = normalized_day

	latest_recorded_day = maxi(
		latest_recorded_day,
		normalized_day
	)
