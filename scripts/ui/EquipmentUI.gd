extends Control
class_name EquipmentUI


signal back_requested
signal equip_requested(instance_id: String)
signal unequip_requested
signal equipment_repaired(instance: ItemInstance)
signal equipment_component_replaced(instance: ItemInstance)
signal equipment_disassembled(instance_id: String)


const EQUIPMENT_SLOT_SCENE := preload("res://scenes/ui/EquipmentSlot.tscn")


@onready var selection_scroll: ScrollContainer = %SelectionScroll
@onready var equipped_title: Label = %EquippedTitle
@onready var equipped_slots: HBoxContainer = %EquippedSlots
@onready var pack_title: Label = %PackTitle
@onready var pack_slots: GridContainer = %PackSlots
@onready var storage_title: Label = %StorageTitle
@onready var storage_slots: GridContainer = %StorageSlots
@onready var empty_label: Label = %EmptyLabel
@onready var equip_button: Button = %EquipButton
@onready var unequip_button: Button = %UnequipButton
@onready var back_button: Button = %BackButton
@onready var details: EquipmentDetailsScreen = %EquipmentDetails

var _selected_instance_id: String = ""
var _slots_by_instance_id: Dictionary = {}
var _ordered_instance_ids: Array[String] = []


func _ready() -> void:
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
	return selection_scroll


func has_active_modal() -> bool:
	return details.has_active_confirmation()


func set_camp_navigation_visible(has_navigation: bool) -> void:
	offset_top = 146.0 if has_navigation else 90.0


func refresh(preferred_instance_id: String = "") -> void:
	if not preferred_instance_id.is_empty():
		_selected_instance_id = preferred_instance_id

	_clear_slots()
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		_show_empty_state()
		return

	var equipped: ItemInstance = survivor.get_equipped_tool_instance()
	if equipped != null:
		_add_instance(equipped, "Equipped", equipped_slots)

	for instance: ItemInstance in survivor.inventory.equipment_instances:
		if instance != null:
			_add_instance(instance, "Expedition Pack", pack_slots)

	if GameManager.is_survivor_at_home():
		var civilization: CivilizationData = GameManager.current_civilization
		if civilization != null and civilization.inventory != null:
			for instance: ItemInstance in civilization.inventory.equipment_instances:
				if instance != null:
					_add_instance(instance, "Camp Storage", storage_slots)

	_update_section_visibility()
	if _ordered_instance_ids.is_empty():
		_show_empty_state()
		return

	empty_label.visible = false
	selection_scroll.visible = true
	if not _slots_by_instance_id.has(_selected_instance_id):
		_selected_instance_id = _ordered_instance_ids[0]
	_select_instance(_selected_instance_id)


func focus_selected_slot() -> void:
	var slot: EquipmentSlot = _slots_by_instance_id.get(_selected_instance_id)
	if slot != null and slot.is_visible_in_tree():
		slot.call_deferred("grab_focus")


func _clear_slots() -> void:
	_slots_by_instance_id.clear()
	_ordered_instance_ids.clear()
	for container: Container in [equipped_slots, pack_slots, storage_slots]:
		for child: Node in container.get_children():
			container.remove_child(child)
			child.queue_free()


func _add_instance(
	instance: ItemInstance,
	source: String,
	container: Container
) -> void:
	if not instance.is_valid():
		return
	var slot: EquipmentSlot = EQUIPMENT_SLOT_SCENE.instantiate()
	container.add_child(slot)
	slot.configure(instance, source)
	slot.instance_selected.connect(_select_instance)
	_slots_by_instance_id[instance.instance_id] = slot
	_ordered_instance_ids.append(instance.instance_id)


func _update_section_visibility() -> void:
	var has_equipped: bool = equipped_slots.get_child_count() > 0
	var has_pack: bool = pack_slots.get_child_count() > 0
	var has_storage: bool = storage_slots.get_child_count() > 0
	equipped_title.visible = has_equipped
	equipped_slots.visible = has_equipped
	pack_title.visible = has_pack
	pack_slots.visible = has_pack
	storage_title.visible = has_storage
	storage_slots.visible = has_storage


func _select_instance(instance_id: String) -> void:
	if not _slots_by_instance_id.has(instance_id):
		return
	_selected_instance_id = instance_id
	for slot_id: String in _slots_by_instance_id:
		var slot: EquipmentSlot = _slots_by_instance_id[slot_id]
		slot.set_selected(slot_id == instance_id)

	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		return
	var instance: ItemInstance = survivor.get_accessible_equipment_instance(
		instance_id
	)
	if instance == null:
		refresh()
		return
	details.show_instance(instance)
	_update_equip_controls(instance, survivor)


func _update_equip_controls(instance: ItemInstance, survivor: Survivor) -> void:
	var equipped: ItemInstance = survivor.get_equipped_tool_instance()
	var is_equipped := (
		equipped != null and equipped.instance_id == instance.instance_id
	)
	var item: ItemData = instance.get_item_data()
	var is_tool := item != null and "tool" in item.tags
	var can_change := survivor.can_act() and not ActionManager.is_busy
	equip_button.disabled = not can_change or not is_tool or is_equipped
	unequip_button.disabled = not can_change or equipped == null


func _show_empty_state() -> void:
	_selected_instance_id = ""
	selection_scroll.visible = false
	empty_label.visible = true
	equip_button.disabled = true
	unequip_button.disabled = true
	details.clear_instance()


func _on_equip_pressed() -> void:
	if not _selected_instance_id.is_empty():
		equip_requested.emit(_selected_instance_id)


func _on_equipment_disassembled(instance_id: String) -> void:
	var previous_index: int = _ordered_instance_ids.find(instance_id)
	if _selected_instance_id == instance_id:
		_selected_instance_id = ""
	refresh()
	if not _ordered_instance_ids.is_empty():
		var next_index: int = clampi(previous_index, 0, _ordered_instance_ids.size() - 1)
		_select_instance(_ordered_instance_ids[next_index])
	equipment_disassembled.emit(instance_id)
