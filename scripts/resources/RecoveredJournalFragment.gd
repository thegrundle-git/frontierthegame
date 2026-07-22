extends Resource
class_name RecoveredJournalFragment


@export var fragment_id: String = ""
@export var location_id: String = ""
@export var location_name: String = ""
@export var recovered_by_id: String = ""
@export var recovered_by_name: String = ""
@export var day: int = 1
@export var hour: int = 0
@export var minute: int = 0


func is_valid() -> bool:
	return not fragment_id.is_empty()
