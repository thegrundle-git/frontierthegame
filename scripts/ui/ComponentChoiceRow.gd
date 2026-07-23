extends PanelContainer
class_name ComponentChoiceRow


signal component_selected(component_slot: String, item_id: String)


@onready var slot_label: Label = %SlotLabel
@onready var mode_label: Label = %ModeLabel
@onready var limiting_label: Label = %LimitingLabel
@onready var selected_component_label: Label = %SelectedComponentLabel
@onready var contribution_label: Label = %ContributionLabel
@onready var component_selector: OptionButton = %ComponentSelector

var component_slot: String = ""


func _ready() -> void:
	component_selector.item_selected.connect(_on_item_selected)


func configure(
	slot: String,
	available_components: Array[ItemData],
	preferred_item_id: String,
	resolved_component: ItemData,
	contribution_text: String,
	limits_quality: bool
) -> void:
	component_slot = slot
	slot_label.text = slot.capitalize()
	mode_label.text = (
		"Explicit choice"
		if not preferred_item_id.is_empty()
		else "Automatic"
	)
	limiting_label.visible = limits_quality
	contribution_label.text = contribution_text
	_set_resolved_component(resolved_component)
	component_selector.clear()
	component_selector.add_item("Automatic — best available")
	component_selector.set_item_metadata(0, "")

	var selected_index := 0
	for component: ItemData in available_components:
		if component == null:
			continue
		var amount: int = GameManager.get_accessible_crafting_item_amount(
			component.id
		)
		if amount <= 0:
			continue
		component_selector.add_item(
			component.display_name
			+ " — Quality "
			+ str(maxi(component.material_quality, 0) + 1)
			+ " — "
			+ str(amount)
			+ " available"
		)
		var index := component_selector.item_count - 1
		component_selector.set_item_metadata(index, component.id)
		component_selector.set_item_tooltip(
			index,
			"Material: "
			+ ItemPresentation.get_material_family_label(component)
			+ "\nQuality: "
			+ str(maxi(component.material_quality, 0) + 1)
			+ "\nAvailable: "
			+ str(amount)
		)
		if component.id == preferred_item_id:
			selected_index = index

	component_selector.select(selected_index)
	component_selector.tooltip_text = (
		"Choose a specific "
		+ slot.capitalize()
		+ " or allow Frontier to use the best available option."
	)


func _set_resolved_component(component: ItemData) -> void:
	if component == null:
		selected_component_label.text = "No compatible component available"
		selected_component_label.remove_theme_color_override("font_color")
		return
	selected_component_label.text = (
		component.display_name
		+ "  •  "
		+ ItemPresentation.get_material_family_label(component)
		+ "  •  Quality "
		+ str(maxi(component.material_quality, 0) + 1)
		+ "  •  "
		+ str(GameManager.get_accessible_crafting_item_amount(component.id))
		+ " available"
	)
	selected_component_label.add_theme_color_override(
		"font_color",
		ItemPresentation.get_material_color(component)
	)


func get_default_focus_target() -> Control:
	return component_selector


func _on_item_selected(index: int) -> void:
	if index < 0 or index >= component_selector.item_count:
		return
	component_selected.emit(
		component_slot,
		str(component_selector.get_item_metadata(index))
	)
