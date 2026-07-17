extends Resource
class_name ItemData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var category: String = ""

@export var weight: float = 0.0
@export var stack_size: int = 99

@export var icon: Texture2D

@export var tags: Array[String] = []

@export_group("Modular Crafting")
@export var component_slot: String = ""
@export var material_id: String = ""
@export var material_quality: int = 0
@export_group("Tool Performance")
@export var tool_efficiency: int = 0

func is_tool_component() -> bool:
	return not component_slot.is_empty()
