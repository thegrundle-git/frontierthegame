extends Resource
class_name ArchivedCharacterLife


@export var character_id: String = ""
@export var display_name: String = ""
@export var life_record: CharacterLifeRecord


func is_valid() -> bool:
	return (
		not character_id.is_empty()
		and not display_name.is_empty()
		and life_record != null
		and life_record.is_finalized
	)
