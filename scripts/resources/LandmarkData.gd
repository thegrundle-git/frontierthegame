extends Resource
class_name LandmarkData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var location_ids: Array[String] = []

@export_range(0, 1000, 1)
var discovery_weight: int = 10

@export var one_time: bool = true

@export_group("Event")
@export var event_id: String = ""
