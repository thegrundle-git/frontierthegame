extends Button
class_name DraggableComponentItem


signal component_drag_started(item_id: String)
signal component_drag_finished(successful: bool)


const PAYLOAD_TYPE := "frontier.crafting_component"

var component: ItemData


func configure(item: ItemData) -> void:
	component = item
	if component == null:
		text = "Unavailable component"
		disabled = true
		return
	var amount: int = GameManager.get_accessible_crafting_item_amount(
		component.id
	)
	text = (
		component.display_name
		+ "\nQuality "
		+ str(maxi(component.material_quality, 0) + 1)
		+ " • "
		+ str(amount)
		+ " available"
	)
	tooltip_text = (
		component.component_slot.capitalize()
		+ "\nMaterial: "
		+ ItemPresentation.get_material_family_label(component)
		+ "\nQuality: "
		+ str(maxi(component.material_quality, 0) + 1)
		+ "\nAvailable: "
		+ str(amount)
	)
	add_theme_color_override(
		"font_color",
		ItemPresentation.get_material_color(component)
	)


func _get_drag_data(_at_position: Vector2) -> Variant:
	if component == null:
		return null
	var preview := Label.new()
	preview.text = component.display_name
	preview.add_theme_color_override(
		"font_color",
		ItemPresentation.get_material_color(component)
	)
	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(150, 40)
	preview_panel.add_child(preview)
	set_drag_preview(preview_panel)
	component_drag_started.emit(component.id)
	return {
		"type": PAYLOAD_TYPE,
		"item_id": component.id,
		"component_slot": component.component_slot,
	}


func _notification(what: int) -> void:
	if what != NOTIFICATION_DRAG_END or component == null:
		return
	component_drag_finished.emit(get_viewport().gui_is_drag_successful())
	if is_inside_tree() and not is_queued_for_deletion():
		grab_focus.call_deferred()
