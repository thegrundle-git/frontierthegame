extends Button
class_name SkillCell

@onready var icon_rect: TextureRect = %IconRect
@onready var name_label: Label = %NameLabel
@onready var level_label: Label = %LevelLabel
@onready var xp_bar: ProgressBar = %XPBar

var _skill_id: String = ""

func _ready() -> void:
	tooltip_text = "Skill details unavailable."

func configure(skill: SkillProgress, presentation: SkillPresentationData) -> void:
	if skill == null:
		return
	_skill_id = skill.id
	name_label.text = skill.display_name
	level_label.text = "Level " + str(skill.level)
	var xp_needed: int = skill.get_xp_needed()
	xp_bar.max_value = maxi(xp_needed, 1)
	xp_bar.value = clampi(skill.xp, 0, xp_needed)
	xp_bar.tooltip_text = str(skill.xp) + " / " + str(xp_needed) + " XP"
	if presentation == null:
		icon_rect.texture = null
		tooltip_text = xp_bar.tooltip_text
		return
	icon_rect.texture = presentation.icon
	tooltip_text = skill.display_name + " — Level " + str(skill.level) + "\n" + xp_bar.tooltip_text + "\n\n" + presentation.description + "\n\n" + presentation.effect_summary

func get_skill_id() -> String:
	return _skill_id


func _make_custom_tooltip(for_text: String) -> Object:
	var popup := PanelContainer.new()
	popup.custom_minimum_size = Vector2(340.0, 150.0)
	popup.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	popup.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.09, 0.095, 0.105, 1.0)
	panel_style.border_color = Color(0.55, 0.5, 0.36, 1.0)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	popup.add_theme_stylebox_override("panel", panel_style)

	var label := Label.new()
	label.custom_minimum_size = Vector2(312.0, 126.0)
	label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	label.text = for_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.94, 0.92, 0.84, 1.0))
	label.add_theme_font_size_override("font_size", 14)
	popup.add_child(label)

	return popup
