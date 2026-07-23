extends Resource
class_name EventOptionData


@export var id: String = ""
@export var display_text: String = ""

@export_group("Choice Guidance")
@export_multiline
var intent_text: String = ""
@export_multiline
var reward_hint: String = ""
@export_multiline
var cost_or_risk_text: String = ""
@export_multiline
var uncertainty_text: String = ""

@export_multiline
var result_text: String = ""

@export var rewards: Array[IngredientData] = []

@export_group("Progression")
@export var skill_id: String = ""
@export var xp_reward: int = 0
@export var knowledge_reward: int = 0

@export_group("Time")
@export var game_minutes: int = 0
