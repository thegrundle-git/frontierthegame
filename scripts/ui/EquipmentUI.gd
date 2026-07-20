extends Control
class_name EquipmentUI


signal back_requested
signal equip_requested(instance_id: String)
signal unequip_requested
signal equipment_repaired(instance: ItemInstance)
signal equipment_component_replaced(instance: ItemInstance)
signal equipment_disassembled(instance_id: String)


@onready var equipment_list: ItemList = %EquipmentList
@onready var empty_label: Label = %EmptyLabel
@onready var equip_button: Button = %EquipButton
@onready var unequip_button: Button = %UnequipButton
@onready var back_button: Button = %BackButton
@onready var details: EquipmentDetailsScreen = %EquipmentDetails

var _selected_instance_id: String = ""


func _ready() -> void:
	equipment_list.item_selected.connect(_on_item_selected)
	equip_button.pressed.connect(_on_equip_pressed)
	unequip_button.pressed.connect(unequip_requested.emit)
	back_button.pressed.connect(back_requested.emit)
	details.equipment_repaired.connect(equipment_repaired.emit)
	details.equipment_component_replaced.connect(
		equipment_component_replaced.emit
	)
	details.equipment_disassembled.connect(_on_equipment_disassembled)
	details.set_embedded_mode(true)


func get_default_focus_target() -> Control:
	return equipment_list


func has_active_modal() -> bool:
	return details.has_active_confirmation()


func set_camp_navigation_visible(has_navigation: bool) -> void:
	offset_top = 146.0 if has_navigation else 90.0


func refresh(preferred_instance_id: String = "") -> void:
	if not preferred_instance_id.is_empty():
		_selected_instance_id = preferred_instance_id

	var survivor: Survivor = GameManager.current_survivor
	equipment_list.clear()

	if survivor == null:
		_show_empty_state()
		return

	var equipped: ItemInstance = survivor.get_equipped_tool_instance()
	if equipped != null:
		_add_instance(equipped, "Equipped")

	for instance: ItemInstance in survivor.inventory.equipment_instances:
		if instance != null:
			_add_instance(instance, "Expedition Pack")

	var civilization: CivilizationData = GameManager.current_civilization
	if civilization != null and civilization.inventory != null:
		for instance: ItemInstance in civilization.inventory.equipment_instances:
			if instance != null:
				_add_instance(instance, "Camp Storage")

	if equipment_list.item_count <= 0:
		_show_empty_state()
		return

	empty_label.visible = false
	equipment_list.visible = true
	var selected_index := _find_instance_index(_selected_instance_id)
	if selected_index < 0:
		selected_index = 0

	equipment_list.select(selected_index)
	_show_selected_index(selected_index)


func _add_instance(instance: ItemInstance, source: String) -> void:
	if not instance.is_valid():
		return

	var item: ItemData = instance.get_item_data()
	var display_name: String = instance.item_id
	if item != null:
		display_name = item.display_name

	var index: int = equipment_list.add_item(
		display_name + " — " + source
	)
	equipment_list.set_item_metadata(index, instance.instance_id)
	equipment_list.set_item_tooltip(
		index,
		display_name + " [" + instance.instance_id + "]\n" + source
	)


func _find_instance_index(instance_id: String) -> int:
	if instance_id.is_empty():
		return -1

	for index: int in range(equipment_list.item_count):
		if str(equipment_list.get_item_metadata(index)) == instance_id:
			return index

	return -1


func _show_selected_index(index: int) -> void:
	if index < 0 or index >= equipment_list.item_count:
		return

	_selected_instance_id = str(equipment_list.get_item_metadata(index))
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		return

	var instance: ItemInstance = survivor.get_accessible_equipment_instance(
		_selected_instance_id
	)
	if instance == null:
		refresh()
		return

	details.show_instance(instance)
	_update_equip_controls(instance, survivor)


func _update_equip_controls(instance: ItemInstance, survivor: Survivor) -> void:
	var equipped: ItemInstance = survivor.get_equipped_tool_instance()
	var is_equipped := (
		equipped != null
		and equipped.instance_id == instance.instance_id
	)
	var item: ItemData = instance.get_item_data()
	var is_tool := item != null and "tool" in item.tags
	var can_change := survivor.can_act() and not ActionManager.is_busy

	equip_button.disabled = not can_change or not is_tool or is_equipped
	unequip_button.disabled = not can_change or equipped == null


func _show_empty_state() -> void:
	_selected_instance_id = ""
	equipment_list.visible = false
	empty_label.visible = true
	equip_button.disabled = true
	unequip_button.disabled = true
	details.clear_instance()


func _on_item_selected(index: int) -> void:
	_show_selected_index(index)


func _on_equip_pressed() -> void:
	if _selected_instance_id.is_empty():
		return
	equip_requested.emit(_selected_instance_id)


func _on_equipment_disassembled(instance_id: String) -> void:
	var previous_index := 0
	var selected_indices: PackedInt32Array = equipment_list.get_selected_items()
	if not selected_indices.is_empty():
		previous_index = selected_indices[0]

	if _selected_instance_id == instance_id:
		_selected_instance_id = ""
	refresh()
	if equipment_list.item_count > 0:
		var next_index := mini(previous_index, equipment_list.item_count - 1)
		equipment_list.select(next_index)
		_show_selected_index(next_index)
	equipment_disassembled.emit(instance_id)
