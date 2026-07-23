extends Control
class_name CraftingUI


signal craft_requested(recipe_id: String, preferred_component_ids: Dictionary)
signal back_requested


const COMPONENT_CHOICE_ROW_SCENE := preload(
	"res://scenes/ui/ComponentChoiceRow.tscn"
)


@onready var recipe_selector: OptionButton = %RecipeSelector
@onready var recipe_label: RichTextLabel = %RecipeLabel
@onready var component_choices: VBoxContainer = %ComponentChoices
@onready var requirements_toggle: Button = %RequirementsToggle
@onready var requirements_label: RichTextLabel = %RequirementsLabel
@onready var details_toggle: Button = %DetailsToggle
@onready var details_label: RichTextLabel = %DetailsLabel
@onready var craft_button: Button = %CraftButton
@onready var back_button: Button = %BackButton

var selected_recipe_id: String = ""
var component_preferences_by_recipe: Dictionary = {}


func _ready() -> void:
	recipe_selector.item_selected.connect(_on_recipe_selected)
	requirements_toggle.toggled.connect(_on_requirements_toggled)
	details_toggle.toggled.connect(_on_details_toggled)
	craft_button.pressed.connect(_on_craft_pressed)
	back_button.pressed.connect(back_requested.emit)
	requirements_toggle.button_pressed = true
	details_toggle.button_pressed = false


func get_default_focus_target() -> Control:
	return recipe_selector


func refresh() -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization

	if survivor == null or civilization == null:
		_show_unavailable("Crafting unavailable.")
		return

	_populate_recipe_selector(civilization)

	if selected_recipe_id.is_empty():
		_show_unavailable("No recipes discovered.")
		return

	var recipe: RecipeData = RecipeDatabase.get_recipe(selected_recipe_id)
	if recipe == null:
		_show_unavailable("Crafting unavailable.")
		return

	recipe_selector.visible = true
	recipe_selector.disabled = false
	craft_button.visible = true
	_sanitize_component_preferences(recipe)
	_rebuild_component_choices(recipe)
	var preferences := _get_component_preferences(recipe.id)
	var plan: CraftingPlan = GameManager.build_crafting_plan(
		recipe,
		preferences
	)
	var primary_result: IngredientData = _get_preview_result(recipe, plan)
	var result_name := recipe.display_name
	if primary_result != null and primary_result.item != null:
		result_name = primary_result.item.display_name
	craft_button.text = "Craft " + result_name
	recipe_label.text = _build_outcome_text(recipe, plan)
	requirements_label.text = _build_requirements_text(recipe, plan)
	details_label.text = _build_details_text(recipe, plan)
	craft_button.disabled = (
		not survivor.can_act()
		or ActionManager.is_busy
		or WorldEventManager.has_pending_event()
		or not plan.can_craft
	)
	craft_button.tooltip_text = (
		plan.unavailable_reason if not plan.can_craft
		else "Consume the listed components and create " + result_name + "."
	)


func _populate_recipe_selector(civilization: CivilizationData) -> void:
	var previous_recipe_id: String = selected_recipe_id
	recipe_selector.clear()

	for recipe_id: String in civilization.unlocked_recipe_ids:
		var recipe: RecipeData = RecipeDatabase.get_recipe(recipe_id)
		if recipe == null:
			continue

		recipe_selector.add_item(recipe.display_name)
		var index: int = recipe_selector.item_count - 1
		recipe_selector.set_item_metadata(index, recipe.id)

	if recipe_selector.item_count <= 0:
		selected_recipe_id = ""
		return

	var selected_index := 0
	for index: int in range(recipe_selector.item_count):
		var recipe_id: String = str(
			recipe_selector.get_item_metadata(index)
		)
		if recipe_id == previous_recipe_id:
			selected_index = index
			break

	recipe_selector.select(selected_index)
	selected_recipe_id = str(
		recipe_selector.get_item_metadata(selected_index)
	)


func _build_outcome_text(recipe: RecipeData, plan: CraftingPlan) -> String:
	var result: IngredientData = _get_preview_result(recipe, plan)
	var heading := recipe.display_name
	var quantity := 1
	if result != null and result.item != null:
		heading = ItemPresentation.colorize_name(result.item)
		quantity = result.amount
	var readiness := "[color=#8fbd72]Ready to craft[/color]"
	if not plan.can_craft:
		readiness = (
			"[color=#d98c7a]Not ready: "
			+ plan.unavailable_reason
			+ "[/color]"
		)
	return (
		"[font_size=22]"
		+ heading
		+ (" ×" + str(quantity) if quantity > 1 else "")
		+ "[/font_size]\n"
		+ readiness
		+ "\n\n"
		+ recipe.description
	)


func _build_requirements_text(
	recipe: RecipeData,
	plan: CraftingPlan
) -> String:
	var lines: Array[String] = []
	for ingredient: IngredientData in recipe.ingredients:
		if ingredient == null or not ingredient.is_valid():
			continue
		var owned: int = (
			GameManager.get_accessible_crafting_ingredient_amount(ingredient)
		)
		var ingredient_name := "Unknown"
		if ingredient.uses_component_slot():
			ingredient_name = ingredient.component_slot.capitalize()
		else:
			ingredient_name = ItemPresentation.colorize_name(ingredient.item)
		lines.append(
			ingredient_name
			+ ": "
			+ str(owned)
			+ " / "
			+ str(ingredient.amount)
		)

	if not plan.component_records.is_empty():
		lines.append("\nSelected components:")
		for record: EquipmentComponentRecord in plan.component_records:
			var item: ItemData = record.get_item_data()
			if item == null:
				continue
			lines.append(
				"• "
				+ record.component_slot.capitalize()
				+ ": "
				+ ItemPresentation.colorize_name(item)
				+ (" ×" + str(record.amount) if record.amount > 1 else "")
			)
	return "\n".join(lines)


func _build_details_text(recipe: RecipeData, plan: CraftingPlan) -> String:
	var result: IngredientData = _get_preview_result(recipe, plan)
	if result == null or result.item == null:
		return (
			"The finished material variant will be shown when its defining "
			+ "component is available."
		)

	var item: ItemData = result.item
	var lines: Array[String] = [
		"Material: " + ItemPresentation.get_material_family_label(item),
	]
	var preview: ItemInstance = plan.build_preview_instance()
	if preview != null:
		var efficiency := EquipmentStatCalculator.get_tool_efficiency(preview)
		var handling := EquipmentStatCalculator.get_handling_rating(preview)
		var stability := EquipmentStatCalculator.get_stability_rating(preview)
		var quality := EquipmentStatCalculator.get_overall_quality(preview)
		lines.append("Efficiency: " + str(efficiency))
		lines.append("Handling: " + str(handling))
		lines.append("Stability: " + str(stability))
		lines.append("Overall quality: " + str(quality))

		var chop_action: ActionData = ActionDatabase.get_action("chop_tree")
		if chop_action != null and "axe" in item.tags:
			var duration := EquipmentStatCalculator.get_action_duration_seconds(
				preview,
				chop_action.duration_seconds
			)
			lines.append("Chop Tree duration: %.2f seconds" % duration)
		_append_equipped_comparison(lines, preview, chop_action.duration_seconds)

	lines.append("\nConstruction history begins after crafting.")
	return "\n".join(lines)


func _get_preview_result(
	recipe: RecipeData,
	plan: CraftingPlan
) -> IngredientData:
	if (
		not recipe.variant_component_slot.is_empty()
		and not plan.selected_components.has(recipe.variant_component_slot)
	):
		return null
	return plan.get_primary_result()


func _append_equipped_comparison(
	lines: Array[String],
	preview: ItemInstance,
	base_duration: float
) -> void:
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		return
	var equipped: ItemInstance = survivor.get_equipped_tool_instance()
	if equipped == null:
		lines.append("\nCompared with equipped: No tool equipped")
		return
	var item: ItemData = equipped.get_item_data()
	if item == null or "axe" not in item.tags:
		lines.append("\nCompared with equipped: Different tool type")
		return
	lines.append("\nCompared with equipped " + item.display_name + ":")
	lines.append(
		"• Efficiency: "
		+ _format_delta(
			EquipmentStatCalculator.get_tool_efficiency(preview)
			- EquipmentStatCalculator.get_tool_efficiency(equipped)
		)
	)
	lines.append(
		"• Handling: "
		+ _format_delta(
			EquipmentStatCalculator.get_handling_rating(preview)
			- EquipmentStatCalculator.get_handling_rating(equipped)
		)
	)
	lines.append(
		"• Stability: "
		+ _format_delta(
			EquipmentStatCalculator.get_stability_rating(preview)
			- EquipmentStatCalculator.get_stability_rating(equipped)
		)
	)
	var preview_duration := EquipmentStatCalculator.get_action_duration_seconds(
		preview,
		base_duration
	)
	var equipped_duration := EquipmentStatCalculator.get_action_duration_seconds(
		equipped,
		base_duration
	)
	lines.append(
		"• Chop duration: %+.2f seconds" % (
			preview_duration - equipped_duration
		)
	)


func _format_delta(value: int) -> String:
	return "%+d" % value


func _show_unavailable(message: String) -> void:
	recipe_selector.clear()
	recipe_selector.visible = true
	recipe_selector.disabled = false
	recipe_label.text = message
	_clear_component_choices()
	component_choices.visible = false
	requirements_label.text = ""
	details_label.text = ""
	craft_button.disabled = true
	craft_button.visible = false


func _on_recipe_selected(index: int) -> void:
	if index < 0 or index >= recipe_selector.item_count:
		return

	selected_recipe_id = str(recipe_selector.get_item_metadata(index))
	refresh()


func _on_craft_pressed() -> void:
	if selected_recipe_id.is_empty():
		return

	craft_requested.emit(
		selected_recipe_id,
		_get_component_preferences(selected_recipe_id).duplicate(true)
	)


func _rebuild_component_choices(recipe: RecipeData) -> void:
	_clear_component_choices()
	var preferences := _get_component_preferences(recipe.id)
	var seen_slots: Array[String] = []
	for ingredient: IngredientData in recipe.ingredients:
		if (
			ingredient == null
			or not ingredient.uses_component_slot()
			or ingredient.component_slot in seen_slots
		):
			continue
		seen_slots.append(ingredient.component_slot)
		var row := COMPONENT_CHOICE_ROW_SCENE.instantiate() as ComponentChoiceRow
		if row == null:
			continue
		component_choices.add_child(row)
		row.configure(
			ingredient.component_slot,
			ItemDatabase.get_components_for_slot(ingredient.component_slot),
			str(preferences.get(ingredient.component_slot, ""))
		)
		row.component_selected.connect(_on_component_selected)
	component_choices.visible = not seen_slots.is_empty()


func _clear_component_choices() -> void:
	for child: Node in component_choices.get_children():
		component_choices.remove_child(child)
		child.queue_free()


func _get_component_preferences(recipe_id: String) -> Dictionary:
	if not component_preferences_by_recipe.has(recipe_id):
		component_preferences_by_recipe[recipe_id] = {}
	return component_preferences_by_recipe[recipe_id] as Dictionary


func _sanitize_component_preferences(recipe: RecipeData) -> void:
	var preferences := _get_component_preferences(recipe.id)
	var valid_slots: Array[String] = []
	for ingredient: IngredientData in recipe.ingredients:
		if ingredient == null or not ingredient.uses_component_slot():
			continue
		valid_slots.append(ingredient.component_slot)
		var selected_id := str(
			preferences.get(ingredient.component_slot, "")
		)
		if selected_id.is_empty():
			continue
		if not ItemDatabase.has_item(selected_id):
			preferences.erase(ingredient.component_slot)
			continue
		var component: ItemData = ItemDatabase.get_item(selected_id)
		if (
			component == null
			or component.component_slot != ingredient.component_slot
			or GameManager.get_accessible_crafting_item_amount(selected_id)
				< ingredient.amount
		):
			preferences.erase(ingredient.component_slot)

	for slot_value: Variant in preferences.keys():
		if str(slot_value) not in valid_slots:
			preferences.erase(slot_value)


func _on_component_selected(component_slot: String, item_id: String) -> void:
	if selected_recipe_id.is_empty():
		return
	var preferences := _get_component_preferences(selected_recipe_id)
	if item_id.is_empty():
		preferences.erase(component_slot)
	else:
		preferences[component_slot] = item_id
	refresh()


func _on_requirements_toggled(expanded: bool) -> void:
	requirements_label.visible = expanded
	requirements_toggle.text = (
		"Requirements and components ▼"
		if expanded
		else "Requirements and components ▶"
	)


func _on_details_toggled(expanded: bool) -> void:
	details_label.visible = expanded
	details_toggle.text = (
		"Statistics and comparison ▼"
		if expanded
		else "Statistics and comparison ▶"
	)
