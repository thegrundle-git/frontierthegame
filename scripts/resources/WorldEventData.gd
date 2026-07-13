extends Resource
class_name WorldEventData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export_range(0.0, 100.0, 0.1)
var trigger_chance_percent: float = 10.0

@export var trigger_action_ids: Array[String] = []
@export var location_ids: Array[String] = []

@export var once_only: bool = false

@export var options: Array[EventOptionData] = []
