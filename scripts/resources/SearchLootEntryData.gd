extends Resource
class_name SearchLootEntryData


@export var item: ItemData

@export_range(0, 1000, 1)
var weight: int = 1

@export_range(1, 999, 1)
var minimum_amount: int = 1

@export_range(1, 999, 1)
var maximum_amount: int = 1


func get_random_amount() -> int:
	var safe_minimum: int = maxi(
		minimum_amount,
		1
	)

	var safe_maximum: int = maxi(
		maximum_amount,
		safe_minimum
	)

	return randi_range(
		safe_minimum,
		safe_maximum
	)
