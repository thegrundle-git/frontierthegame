extends Resource
class_name LocationData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var available_actions: Array[ActionData] = []
@export var travel_connections: Array[TravelConnectionData] = []

@export_group("Searching")
@export var search_loot: Array[SearchLootEntryData] = []

@export_range(0, 1000, 1)
var empty_search_weight: int = 10
