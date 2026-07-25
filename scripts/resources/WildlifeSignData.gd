extends Resource
class_name WildlifeSignData


@export var id: String = ""
@export var display_name: String = ""

@export_range(1, 100, 1)
var identification_level: int = 1

@export_range(0, 100, 1)
var knowledge_reward: int = 1

@export_multiline
var unidentified_description: String = ""

@export_multiline
var identified_description: String = ""


func is_valid() -> bool:
	return (
		not id.is_empty()
		and not display_name.is_empty()
		and identification_level >= 1
	)
