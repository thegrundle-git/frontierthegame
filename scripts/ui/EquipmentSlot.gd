extends Button
class_name EquipmentSlot


signal instance_selected(instance_id: String)


@onready var icon_rect: TextureRect = %IconRect
@onready var abbreviation_label: Label = %AbbreviationLabel
@onready var name_label: Label = %NameLabel
@onready var condition_bar: ProgressBar = %ConditionBar
@onready var status_label: Label = %StatusLabel

var _instance_id: String = ""


func _ready() -> void:
	pressed.connect(_on_pressed)


func configure(instance: ItemInstance, source: String) -> void:
	if instance == null or not instance.is_valid():
		return

	_instance_id = instance.instance_id
	var item: ItemData = instance.get_item_data()
	var display_name := instance.item_id
	if item != null:
		display_name = item.display_name

	name_label.text = display_name
	if item != null and item.icon != null:
		icon_rect.texture = item.icon
		icon_rect.visible = true
		abbreviation_label.visible = false
	else:
		icon_rect.texture = null
		icon_rect.visible = false
		abbreviation_label.visible = true
		abbreviation_label.text = _build_abbreviation(display_name)

	var condition_percent: int = (
		EquipmentDurabilityCalculator.get_overall_condition_percent(instance)
	)
	var is_usable: bool = EquipmentDurabilityCalculator.is_usable(instance)
	condition_bar.value = condition_percent
	status_label.text = str(condition_percent) + "%"
	if not is_usable:
		status_label.text = "FAILED"
		modulate = Color(0.82, 0.62, 0.62, 1.0)
	else:
		modulate = Color.WHITE

	tooltip_text = (
		display_name
		+ "\nSource: " + source
		+ "\nMaterial: " + _display_value(instance.material_id)
		+ "\nCondition: " + str(condition_percent) + "%"
		+ "\nUsable: " + ("Yes" if is_usable else "No")
		+ "\nInstance: " + instance.instance_id
	)


func get_equipment_instance_id() -> String:
	return _instance_id


func set_selected(is_selected: bool) -> void:
	button_pressed = is_selected


func _on_pressed() -> void:
	if not _instance_id.is_empty():
		instance_selected.emit(_instance_id)


func _build_abbreviation(display_name: String) -> String:
	var words: PackedStringArray = display_name.split(" ", false)
	if words.is_empty():
		return "?"
	if words.size() == 1:
		return words[0].left(2).to_upper()
	return (words[0].left(1) + words[1].left(1)).to_upper()


func _display_value(value: String) -> String:
	if value.is_empty():
		return "Unknown"
	return value.replace("_", " ").capitalize()
