extends Resource
class_name ActionData


@export var id: String = ""
@export var display_name: String = ""

@export_multiline
var description: String = ""

@export var duration_seconds: float = 1.0
@export var game_minutes: int = 0

@export_group("Tool Requirement")
@export var required_tool_id: String = ""
@export var required_tool_tags: Array[String] = []

@export_group("Progression")
@export var skill_id: String = ""
@export var xp_reward: int = 0

@export_group("Resolution")
@export var action_script: Script


func has_tool_requirement() -> bool:
	return (
		not required_tool_id.is_empty()
		or not required_tool_tags.is_empty()
	)


func is_tool_requirement_met(
	survivor: Survivor
) -> bool:
	if not has_tool_requirement():
		return true

	if survivor == null:
		return false

	var equipped_tool: ItemData = (
		survivor.get_equipped_tool()
	)

	if equipped_tool == null:
		return false

	var equipped_instance: ItemInstance = survivor.get_equipped_tool_instance()
	if not EquipmentDurabilityCalculator.is_usable(equipped_instance):
		return false

	if (
		not required_tool_id.is_empty()
		and equipped_tool.id != required_tool_id
	):
		return false

	for required_tag: String in required_tool_tags:
		if required_tag not in equipped_tool.tags:
			return false

	return true
