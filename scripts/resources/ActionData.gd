extends Resource
class_name ActionData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var duration_seconds: float = 1.0
@export var game_minutes: int = 0

@export var required_tool_id: String = ""

@export_group("Progression")
@export var skill_id: String = ""
@export var xp_reward: int = 0

@export_group("Resolution")
@export var action_script: Script
