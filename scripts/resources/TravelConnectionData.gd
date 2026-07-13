extends Resource
class_name TravelConnectionData


@export var destination_id: String = ""

@export var duration_seconds: float = 3.0
@export var game_minutes: int = 120

@export_group("Progression")
@export var skill_id: String = "exploration"
@export var xp_reward: int = 2

@export_group("Presentation")
@export_multiline
var description: String = ""
