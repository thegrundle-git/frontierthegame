extends Control
class_name EquipmentDetailsScreen


@onready var title_label: Label = %TitleLabel
@onready var identity_label: Label = %IdentityLabel
@onready var provenance_label: Label = %ProvenanceLabel
@onready var components_log: RichTextLabel = %ComponentsLog
@onready var close_button: Button = %CloseButton

var _previous_focus: Control


func _ready() -> void:
	close_button.pressed.connect(hide_details)
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_details()
		get_viewport().set_input_as_handled()


func show_instance(instance: ItemInstance) -> void:
	if instance == null or not instance.is_valid():
		return

	var item: ItemData = instance.get_item_data()
	if item == null:
		return

	_previous_focus = get_viewport().gui_get_focus_owner()
	title_label.text = item.display_name
	identity_label.text = (
		"Instance: " + instance.instance_id
		+ "\nMaterial: " + _display_value(instance.material_id)
		+ "\nTool efficiency: " + str(item.tool_efficiency)
	)
	var maker: String = instance.crafted_by_name
	if maker.is_empty():
		maker = "Unknown"
	provenance_label.text = (
		"Crafted by: " + maker
		+ "\nCrafted: Day " + str(instance.crafted_day)
		+ " — " + "%02d:%02d" % [instance.crafted_hour, instance.crafted_minute]
	)
	components_log.text = _build_components_text(instance)
	visible = true
	move_to_front()
	close_button.grab_focus()


func hide_details() -> void:
	if not visible:
		return
	visible = false
	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()


func _build_components_text(instance: ItemInstance) -> String:
	if not instance.component_history_known:
		return "Component history unavailable."
	if instance.components.is_empty():
		return "No components were recorded."

	var component_text: String = ""
	for component: EquipmentComponentRecord in instance.components:
		if component == null or not component.is_valid():
			continue
		var item: ItemData = component.get_item_data()
		var component_name: String = component.item_id
		if item != null:
			component_name = item.display_name
		if not component_text.is_empty():
			component_text += "\n\n"
		component_text += (
			component.component_slot.capitalize()
			+ ": " + component_name
			+ "\nMaterial: " + _display_value(component.material_id)
			+ "\nQuality: " + str(component.material_quality)
		)
		if component.amount > 1:
			component_text += "\nQuantity: " + str(component.amount)

	return component_text


func _display_value(value: String) -> String:
	if value.is_empty():
		return "Unknown"
	return value.replace("_", " ").capitalize()
