extends VBoxContainer
class_name SkillsPanel

const SKILL_CELL_SCENE := preload("res://scenes/ui/SkillCell.tscn")
const PRESENTATIONS: Array[SkillPresentationData] = [
	preload("res://resources/ui/skills/strength.tres"),
	preload("res://resources/ui/skills/gathering.tres"),
	preload("res://resources/ui/skills/crafting.tres"),
	preload("res://resources/ui/skills/exploration.tres")
]

@onready var skill_grid: GridContainer = %SkillGrid
@onready var empty_label: Label = %EmptyLabel

var _skills: Dictionary = {}
var _presentations: Dictionary = {}

func _ready() -> void:
	for presentation: SkillPresentationData in PRESENTATIONS:
		if presentation != null and not presentation.skill_id.is_empty():
			_presentations[presentation.skill_id] = presentation

func refresh(survivor: Survivor) -> void:
	_clear_grid()
	_skills.clear()
	if survivor == null:
		empty_label.text = "Skills unavailable."
		empty_label.visible = true
		return
	var skills: Array[SkillProgress] = survivor.get_all_skills()
	empty_label.visible = skills.is_empty()
	if skills.is_empty():
		empty_label.text = "No skills recorded."
		return
	for skill: SkillProgress in skills:
		if skill == null:
			continue
		_skills[skill.id] = skill
		var cell: SkillCell = SKILL_CELL_SCENE.instantiate() as SkillCell
		skill_grid.add_child(cell)
		cell.configure(skill, _get_presentation(skill.id))

func _get_presentation(skill_id: String) -> SkillPresentationData:
	if not _presentations.has(skill_id):
		return null
	return _presentations[skill_id] as SkillPresentationData

func _clear_grid() -> void:
	for child: Node in skill_grid.get_children():
		skill_grid.remove_child(child)
		child.queue_free()
