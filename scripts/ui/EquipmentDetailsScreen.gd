extends Control
class_name EquipmentDetailsScreen

signal equipment_repaired(instance: ItemInstance)
signal equipment_component_replaced(instance: ItemInstance)


@onready var title_label: Label = %TitleLabel
@onready var identity_label: Label = %IdentityLabel
@onready var provenance_label: Label = %ProvenanceLabel
@onready var components_log: RichTextLabel = %ComponentsLog
@onready var repair_selector: OptionButton = %RepairSelector
@onready var repair_status: Label = %RepairStatus
@onready var repair_button: Button = %RepairButton
@onready var replacement_slot_selector: OptionButton = %ReplacementSlotSelector
@onready var replacement_item_selector: OptionButton = %ReplacementItemSelector
@onready var replacement_status: Label = %ReplacementStatus
@onready var replace_button: Button = %ReplaceButton
@onready var close_button: Button = %CloseButton

var _previous_focus: Control
var _instance: ItemInstance


func _ready() -> void:
	close_button.pressed.connect(hide_details)
	repair_selector.item_selected.connect(_on_repair_selection_changed)
	repair_button.pressed.connect(_on_repair_pressed)
	replacement_slot_selector.item_selected.connect(_on_replacement_slot_changed)
	replacement_item_selector.item_selected.connect(_on_replacement_item_changed)
	replace_button.pressed.connect(_on_replace_pressed)
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

	if not visible:
		_previous_focus = get_viewport().gui_get_focus_owner()
	_instance = instance
	title_label.text = item.display_name
	var efficiency: int = EquipmentStatCalculator.get_tool_efficiency(instance)
	identity_label.text = (
		"Instance: " + instance.instance_id
		+ "\nMaterial: " + _display_value(instance.material_id)
		+ "\nTool efficiency: " + str(efficiency)
		+ "\n" + _get_efficiency_source_text(instance)
		+ "\nOverall condition: "
		+ str(EquipmentDurabilityCalculator.get_overall_condition_percent(instance))
		+ "%"
		+ "\nUsable: "
		+ ("Yes" if EquipmentDurabilityCalculator.is_usable(instance) else "No")
	)
	var maker: String = instance.crafted_by_name
	if maker.is_empty():
		maker = "Unknown"
	provenance_label.text = (
		"Crafted by: " + maker
		+ "\nCrafted: Day " + str(instance.crafted_day)
		+ " — " + "%02d:%02d" % [instance.crafted_hour, instance.crafted_minute]
	)
	provenance_label.text += (
		"\nMaintenance count: " + str(instance.maintenance_count)
		+ "\nLast maintained: " + _get_last_maintenance_text(instance)
	)
	components_log.text = _build_components_text(instance)
	_refresh_repair_controls()
	_refresh_replacement_controls()
	visible = true
	move_to_front()
	close_button.grab_focus()


func hide_details() -> void:
	if not visible:
		return
	visible = false
	if is_instance_valid(_previous_focus):
		_previous_focus.grab_focus()


func _refresh_repair_controls() -> void:
	repair_selector.clear()
	if _instance == null:
		repair_status.text = "No equipment selected."
		repair_button.disabled = true
		return

	if _instance.component_history_known:
		for component: EquipmentComponentRecord in _instance.components:
			if component == null or not component.is_valid():
				continue
			var condition: EquipmentComponentCondition = (
				EquipmentDurabilityCalculator.get_component_condition(
					_instance,
					component.record_id
				)
			)
			if condition == null or condition.current_condition >= condition.maximum_condition:
				continue
			var item: ItemData = component.get_item_data()
			var label: String = component.component_slot.capitalize()
			if item != null:
				label += " — " + item.display_name
			repair_selector.add_item(label)
			repair_selector.set_item_metadata(
				repair_selector.item_count - 1,
				component.record_id
			)
	else:
		var legacy_cost: String = EquipmentDurabilityCalculator.get_repair_item_id(_instance)
		if not legacy_cost.is_empty():
			repair_selector.add_item("Tool condition")
			repair_selector.set_item_metadata(0, "")

	_update_repair_status()


func _on_repair_selection_changed(_index: int) -> void:
	_update_repair_status()


func _update_repair_status() -> void:
	var survivor: Survivor = GameManager.current_survivor
	if repair_selector.item_count <= 0 or _instance == null:
		repair_status.text = "No damaged components require maintenance."
		repair_button.disabled = true
		return
	var record_id: String = str(repair_selector.get_item_metadata(repair_selector.selected))
	var cost_id: String = EquipmentDurabilityCalculator.get_repair_item_id(_instance, record_id)
	var cost_item: ItemData = ItemDatabase.get_item(cost_id)
	var cost_name: String = cost_item.display_name if cost_item != null else cost_id
	var at_camp: bool = GameManager.is_survivor_at_home()
	var can_afford: bool = GameManager.get_accessible_crafting_item_amount(cost_id) >= 1
	repair_status.text = "Cost: 1 " + cost_name
	if not at_camp:
		repair_status.text += "\nMaintenance is available at Camp."
	elif not can_afford:
		repair_status.text += "\nRequired material is unavailable."
	repair_button.disabled = (
		survivor == null
		or not survivor.can_act()
		or ActionManager.is_busy
		or not at_camp
		or cost_id.is_empty()
		or not can_afford
	)


func _on_repair_pressed() -> void:
	if _instance == null or repair_selector.selected < 0:
		return
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null or not survivor.can_act() or not GameManager.is_survivor_at_home():
		return
	var record_id: String = str(repair_selector.get_item_metadata(repair_selector.selected))
	var cost_id: String = EquipmentDurabilityCalculator.get_repair_item_id(_instance, record_id)
	if cost_id.is_empty() or not GameManager.consume_accessible_item(cost_id, 1):
		_update_repair_status()
		return
	if not EquipmentDurabilityCalculator.repair(_instance, record_id):
		return
	_instance.maintenance_count += 1
	_instance.last_maintained_day = maxi(TimeManager.day, 1)
	_instance.last_maintained_by_id = survivor.data.character_id
	_instance.last_maintained_by_name = survivor.data.display_name
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			survivor.data.display_name + " maintained "
			+ _instance.get_item_data().display_name + "."
		)
	equipment_repaired.emit(_instance)
	show_instance(_instance)


func _get_last_maintenance_text(instance: ItemInstance) -> String:
	if instance == null or instance.maintenance_count <= 0:
		return "Never"
	var maintainer: String = instance.last_maintained_by_name
	if maintainer.is_empty():
		maintainer = "Unknown"
	return "Day " + str(instance.last_maintained_day) + " by " + maintainer


func _refresh_replacement_controls() -> void:
	replacement_slot_selector.clear()
	replacement_item_selector.clear()
	if _instance == null or not _instance.component_history_known:
		replacement_status.text = "Component replacement requires known construction history."
		replace_button.disabled = true
		return
	for component: EquipmentComponentRecord in _instance.components:
		if component == null or not component.is_valid():
			continue
		replacement_slot_selector.add_item(component.component_slot.capitalize())
		replacement_slot_selector.set_item_metadata(
			replacement_slot_selector.item_count - 1,
			component.component_slot
		)
	_populate_replacement_items()


func _on_replacement_slot_changed(_index: int) -> void:
	_populate_replacement_items()


func _populate_replacement_items() -> void:
	replacement_item_selector.clear()
	if replacement_slot_selector.selected < 0:
		_update_replacement_status()
		return
	var component_slot: String = str(
		replacement_slot_selector.get_item_metadata(
			replacement_slot_selector.selected
		)
	)
	for item: ItemData in ItemDatabase.get_components_for_slot(component_slot):
		if GameManager.get_accessible_crafting_item_amount(item.id) <= 0:
			continue
		if not EquipmentComponentReplacementService.can_replace(
			_instance,
			component_slot,
			item
		):
			continue
		replacement_item_selector.add_item(item.display_name)
		replacement_item_selector.set_item_metadata(
			replacement_item_selector.item_count - 1,
			item.id
		)
	_update_replacement_status()


func _on_replacement_item_changed(_index: int) -> void:
	_update_replacement_status()


func _update_replacement_status() -> void:
	var survivor: Survivor = GameManager.current_survivor
	if replacement_slot_selector.selected < 0 or replacement_item_selector.selected < 0:
		replacement_status.text = "No compatible available component can be installed."
		replace_button.disabled = true
		return
	var component_slot: String = str(
		replacement_slot_selector.get_item_metadata(replacement_slot_selector.selected)
	)
	var replacement_id: String = str(
		replacement_item_selector.get_item_metadata(replacement_item_selector.selected)
	)
	var replacement: ItemData = ItemDatabase.get_item(replacement_id)
	var result: ItemData = EquipmentComponentReplacementService.get_result_item(
		_instance,
		component_slot,
		replacement
	)
	var recovered: bool = (
		EquipmentComponentReplacementService.will_recover_removed_component(
			_instance,
			component_slot
		)
	)
	var preview := "Consumes: 1 " + replacement.display_name
	if result != null:
		preview += "\nResult: " + result.display_name
	preview += "\nEfficiency: " + str(replacement.material_quality if component_slot == "head" else EquipmentStatCalculator.get_tool_efficiency(_instance))
	preview += "\nRemoved component: " + ("Recovered" if recovered else "Not recovered because it is damaged")
	replacement_status.text = preview
	replace_button.disabled = (
		survivor == null
		or not survivor.can_act()
		or ActionManager.is_busy
		or not GameManager.is_survivor_at_home()
	)


func _on_replace_pressed() -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization
	if survivor == null or civilization == null or not GameManager.is_survivor_at_home():
		return
	if replacement_slot_selector.selected < 0 or replacement_item_selector.selected < 0:
		return
	var component_slot: String = str(
		replacement_slot_selector.get_item_metadata(replacement_slot_selector.selected)
	)
	var replacement_id: String = str(
		replacement_item_selector.get_item_metadata(replacement_item_selector.selected)
	)
	var replacement: ItemData = ItemDatabase.get_item(replacement_id)
	var removed: EquipmentComponentRecord = (
		EquipmentComponentReplacementService.get_active_component(_instance, component_slot)
	)
	if removed == null or replacement == null:
		return
	var recovered: bool = (
		EquipmentComponentReplacementService.will_recover_removed_component(
			_instance,
			component_slot
		)
	)
	if not GameManager.consume_accessible_item(replacement.id, 1):
		_refresh_replacement_controls()
		return
	if not EquipmentComponentReplacementService.replace_component(
		_instance,
		component_slot,
		replacement,
		survivor.data.character_id,
		survivor.data.display_name,
		recovered
	):
		return
	if recovered:
		civilization.inventory.add_item(removed.item_id, 1)
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(
			survivor.data.display_name + " replaced the " + component_slot
			+ " on " + _instance.get_item_data().display_name + "."
		)
	equipment_component_replaced.emit(_instance)
	show_instance(_instance)


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
		var condition: EquipmentComponentCondition = (
			EquipmentDurabilityCalculator.get_component_condition(
				instance,
				component.record_id
			)
		)
		if condition != null:
			component_text += (
				"\nCondition: "
				+ str(condition.current_condition)
				+ " / " + str(condition.maximum_condition)
				+ " (" + str(condition.get_condition_percent()) + "%)"
			)
			if condition.is_failed():
				component_text += " — FAILED"
		if component.amount > 1:
			component_text += "\nQuantity: " + str(component.amount)

	if not instance.component_replacements.is_empty():
		component_text += "\n\nReplacement history:"
		for replacement: EquipmentComponentReplacementRecord in instance.component_replacements:
			if replacement == null or not replacement.is_valid():
				continue
			var removed_item: ItemData = replacement.removed_component.get_item_data()
			var installed_item: ItemData = replacement.installed_component.get_item_data()
			var removed_name: String = replacement.removed_component.item_id
			var installed_name: String = replacement.installed_component.item_id
			if removed_item != null:
				removed_name = removed_item.display_name
			if installed_item != null:
				installed_name = installed_item.display_name
			component_text += (
				"\nDay " + str(replacement.replacement_day)
				+ ": " + removed_name + " → " + installed_name
				+ " by " + replacement.replaced_by_name
				+ ("; removed part recovered" if replacement.removed_component_recovered else "; removed part not recovered")
			)
	return component_text


func _get_efficiency_source_text(instance: ItemInstance) -> String:
	var component: EquipmentComponentRecord = (
		EquipmentStatCalculator.get_efficiency_component(instance)
	)
	if component == null:
		if not instance.component_history_known:
			return "Source: Base tool data — component history unavailable"
		return "Source: Base tool data — no valid head component recorded"

	var item: ItemData = component.get_item_data()
	var component_name: String = component.item_id
	if item != null:
		component_name = item.display_name
	return (
		"Derived from: " + component_name
		+ " — head quality " + str(component.material_quality)
	)


func _display_value(value: String) -> String:
	if value.is_empty():
		return "Unknown"
	return value.replace("_", " ").capitalize()
