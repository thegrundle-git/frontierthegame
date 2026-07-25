extends Resource
class_name WeightedWildlifeSignEntryData


@export var sign: WildlifeSignData

@export_range(0, 1000, 1)
var weight: int = 1


func is_valid() -> bool:
	return (
		sign != null
		and sign.is_valid()
		and weight > 0
	)
