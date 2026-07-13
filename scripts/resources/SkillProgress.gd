extends Resource
class_name SkillProgress


var id: String = ""
var display_name: String = ""

var level: int = 1
var xp: int = 0


func setup(
	skill_id: String,
	skill_display_name: String
) -> void:
	id = skill_id
	display_name = skill_display_name


func get_xp_needed() -> int:
	return level * 10


func add_xp(amount: int) -> int:
	if amount <= 0:
		return 0

	xp += amount

	var levels_gained := 0

	while xp >= get_xp_needed():
		xp -= get_xp_needed()
		level += 1
		levels_gained += 1

	return levels_gained
