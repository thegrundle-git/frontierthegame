extends Control
class_name StorageUI


signal back_requested
signal equipment_inspection_requested(instance: ItemInstance)


enum SelectionSide {
	NONE,
	PACK,
	STORAGE,
}

const ITEM_PREFIX := "item:"
const INSTANCE_PREFIX := "instance:"
const EQUIPPED_PREFIX := "equipped:"


@onready var pack_title: Label = %PackTitle
@onready var pack_list: ItemList = %PackList
@onready var storage_list: ItemList = %StorageList
@onready var amount_spinner: SpinBox = %AmountSpinner
@onready var deposit_button: Button = %DepositButton
@onready var take_button: Button = %TakeButton
@onready var keep_checkbox: CheckBox = %KeepCheckbox
@onready var inspect_equipment_button: Button = %InspectEquipmentButton
@onready var deposit_all_button: Button = %DepositAllButton
@onready var back_button: Button = %BackButton

var _is_refreshing := false
var _selected_side: SelectionSide = SelectionSide.NONE
var _selected_token: String = ""
var _selected_equipment: ItemInstance


func _ready() -> void:
	pack_list.item_selected.connect(_on_pack_item_selected)
	storage_list.item_selected.connect(_on_storage_item_selected)
	deposit_button.pressed.connect(_on_deposit_pressed)
	take_button.pressed.connect(_on_take_pressed)
	keep_checkbox.toggled.connect(_on_keep_toggled)
	inspect_equipment_button.pressed.connect(
		_on_inspect_equipment_pressed
	)
	deposit_all_button.pressed.connect(_on_deposit_all_pressed)
	back_button.pressed.connect(back_requested.emit)


func get_default_focus_target() -> Control:
	return pack_list


func refresh_storage(
	preferred_side: SelectionSide = SelectionSide.NONE,
	preferred_token: String = ""
) -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization
	if survivor == null or civilization == null:
		return

	if preferred_side == SelectionSide.NONE:
		preferred_side = _selected_side
	if preferred_token.is_empty():
		preferred_token = _selected_token

	_is_refreshing = true
	pack_title.text = survivor.data.display_name + "'s Pack"
	_populate_inventory_list(pack_list, survivor.inventory, true)
	_add_equipped_instance(pack_list, survivor.get_equipped_tool_instance())
	_populate_inventory_list(storage_list, civilization.inventory, false)
	_reset_selection_controls()
	deposit_all_button.disabled = (
		survivor.inventory.items.is_empty()
		and survivor.inventory.equipment_instances.is_empty()
	)

	var selected_index := -1
	if preferred_side == SelectionSide.PACK:
		selected_index = _find_token_index(pack_list, preferred_token)
		if selected_index >= 0:
			pack_list.select(selected_index)
	elif preferred_side == SelectionSide.STORAGE:
		selected_index = _find_token_index(storage_list, preferred_token)
		if selected_index >= 0:
			storage_list.select(selected_index)

	_is_refreshing = false
	if selected_index >= 0:
		_set_selection(preferred_side, preferred_token)


func _populate_inventory_list(
	item_list: ItemList,
	inventory: FrontierInventory,
	show_keep_status: bool
) -> void:
	item_list.clear()
	if inventory == null:
		_add_empty_entry(item_list)
		return

	var item_ids: Array = inventory.items.keys()
	item_ids.sort()
	var has_resources := false
	for item_id_variant: Variant in item_ids:
		var item_id := str(item_id_variant)
		var amount: int = inventory.get_item_amount(item_id)
		if amount <= 0:
			continue
		if not has_resources:
			_add_section_header(item_list, "Resources")
			has_resources = true

		var item_data: ItemData = ItemDatabase.get_item(item_id)
		var display_name := item_id
		if item_data != null:
			display_name = item_data.display_name
		var item_text := display_name + " x" + str(amount)
		if show_keep_status and inventory.is_item_kept(item_id):
			item_text = "[Keep] " + item_text

		var index: int = item_list.add_item(item_text)
		item_list.set_item_metadata(index, ITEM_PREFIX + item_id)
		ItemPresentation.apply_item_list_color(item_list, index, item_data)
		if item_data != null:
			item_list.set_item_tooltip(
				index,
				display_name + "\nMaterial family: "
				+ ItemPresentation.get_material_family_label(item_data)
			)

	var has_equipment := false
	for instance: ItemInstance in inventory.equipment_instances:
		if instance == null or not instance.is_valid():
			continue
		if not has_equipment:
			_add_section_header(item_list, "Equipment")
			has_equipment = true
		_add_equipment_entry(item_list, instance, INSTANCE_PREFIX)

	if not has_resources and not has_equipment:
		_add_empty_entry(item_list)


func _add_equipped_instance(
	item_list: ItemList,
	instance: ItemInstance
) -> void:
	if instance == null or not instance.is_valid():
		return
	if (
		item_list.item_count == 1
		and str(item_list.get_item_metadata(0)).is_empty()
	):
		item_list.clear()
	_add_section_header(item_list, "Equipped")
	_add_equipment_entry(item_list, instance, EQUIPPED_PREFIX)


func _add_equipment_entry(
	item_list: ItemList,
	instance: ItemInstance,
	prefix: String
) -> void:
	var item_data: ItemData = instance.get_item_data()
	var display_name: String = instance.item_id
	if item_data != null:
		display_name = item_data.display_name
	var index: int = item_list.add_item(display_name)
	item_list.set_item_metadata(index, prefix + instance.instance_id)
	ItemPresentation.apply_item_list_color(item_list, index, item_data)
	item_list.set_item_tooltip(
		index,
		display_name + " [" + instance.instance_id + "]"
		+ "\nMaterial family: "
		+ ItemPresentation.get_material_family_label(item_data)
	)


func _add_section_header(item_list: ItemList, title: String) -> void:
	var index: int = item_list.add_item("— " + title + " —")
	item_list.set_item_disabled(index, true)
	item_list.set_item_metadata(index, "")


func _add_empty_entry(item_list: ItemList) -> void:
	var index: int = item_list.add_item("No items")
	item_list.set_item_disabled(index, true)
	item_list.set_item_metadata(index, "")


func _on_pack_item_selected(index: int) -> void:
	if _is_refreshing:
		return
	storage_list.deselect_all()
	_set_selection(
		SelectionSide.PACK,
		str(pack_list.get_item_metadata(index))
	)


func _on_storage_item_selected(index: int) -> void:
	if _is_refreshing:
		return
	pack_list.deselect_all()
	_set_selection(
		SelectionSide.STORAGE,
		str(storage_list.get_item_metadata(index))
	)


func _set_selection(side: SelectionSide, token: String) -> void:
	_selected_side = side
	_selected_token = token
	_selected_equipment = null
	_reset_selection_controls(false)
	if token.is_empty():
		return

	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization
	if survivor == null or civilization == null:
		return

	if token.begins_with(EQUIPPED_PREFIX):
		_selected_equipment = survivor.get_equipped_tool_instance()
		inspect_equipment_button.disabled = _selected_equipment == null
		return

	if token.begins_with(INSTANCE_PREFIX):
		var instance_id: String = token.trim_prefix(INSTANCE_PREFIX)
		var inventory: FrontierInventory = (
			survivor.inventory
			if side == SelectionSide.PACK
			else civilization.inventory
		)
		_selected_equipment = inventory.get_equipment_instance(instance_id)
		amount_spinner.max_value = 1
		deposit_button.disabled = (
			side != SelectionSide.PACK or _selected_equipment == null
		)
		take_button.disabled = (
			side != SelectionSide.STORAGE or _selected_equipment == null
		)
		inspect_equipment_button.disabled = _selected_equipment == null
		return

	if not token.begins_with(ITEM_PREFIX):
		return

	var item_id: String = token.trim_prefix(ITEM_PREFIX)
	var inventory: FrontierInventory = (
		survivor.inventory
		if side == SelectionSide.PACK
		else civilization.inventory
	)
	var amount: int = inventory.get_item_amount(item_id)
	amount_spinner.max_value = maxi(amount, 1)
	deposit_button.disabled = side != SelectionSide.PACK or amount <= 0
	take_button.disabled = side != SelectionSide.STORAGE or amount <= 0
	if side == SelectionSide.PACK:
		_is_refreshing = true
		keep_checkbox.disabled = amount <= 0
		keep_checkbox.button_pressed = inventory.is_item_kept(item_id)
		_is_refreshing = false


func _reset_selection_controls(clear_identity: bool = true) -> void:
	if clear_identity:
		_selected_side = SelectionSide.NONE
		_selected_token = ""
	_selected_equipment = null
	amount_spinner.min_value = 1
	amount_spinner.max_value = 1
	amount_spinner.value = 1
	deposit_button.disabled = true
	take_button.disabled = true
	keep_checkbox.disabled = true
	keep_checkbox.button_pressed = false
	inspect_equipment_button.disabled = true


func _on_deposit_pressed() -> void:
	_transfer_selected(SelectionSide.PACK, SelectionSide.STORAGE)


func _on_take_pressed() -> void:
	_transfer_selected(SelectionSide.STORAGE, SelectionSide.PACK)


func _transfer_selected(
	from_side: SelectionSide,
	to_side: SelectionSide
) -> void:
	if _selected_side != from_side or _selected_token.is_empty():
		return
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization
	if survivor == null or civilization == null:
		return

	var source: FrontierInventory = (
		survivor.inventory
		if from_side == SelectionSide.PACK
		else civilization.inventory
	)
	var destination: FrontierInventory = (
		civilization.inventory
		if to_side == SelectionSide.STORAGE
		else survivor.inventory
	)
	var transferred := false
	if _selected_token.begins_with(INSTANCE_PREFIX):
		transferred = source.transfer_equipment_instance_to(
			destination,
			_selected_token.trim_prefix(INSTANCE_PREFIX)
		)
	elif _selected_token.begins_with(ITEM_PREFIX):
		transferred = source.transfer_item_to(
			destination,
			_selected_token.trim_prefix(ITEM_PREFIX),
			int(amount_spinner.value)
		) > 0
	if transferred:
		_refresh_after_transfer(to_side, _selected_token)


func _on_deposit_all_pressed() -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization
	if survivor == null or civilization == null:
		return

	survivor.inventory.transfer_all_to(civilization.inventory, true)
	var carried_instances: Array[ItemInstance] = (
		survivor.inventory.equipment_instances.duplicate()
	)
	for instance: ItemInstance in carried_instances:
		if instance != null:
			survivor.inventory.transfer_equipment_instance_to(
				civilization.inventory,
				instance.instance_id
			)
	_refresh_after_transfer()


func _on_keep_toggled(is_kept: bool) -> void:
	if _is_refreshing or _selected_side != SelectionSide.PACK:
		return
	if not _selected_token.begins_with(ITEM_PREFIX):
		return
	var survivor: Survivor = GameManager.current_survivor
	if survivor == null:
		return
	survivor.inventory.set_item_kept(
		_selected_token.trim_prefix(ITEM_PREFIX),
		is_kept
	)
	refresh_storage(SelectionSide.PACK, _selected_token)


func _on_inspect_equipment_pressed() -> void:
	if _selected_equipment == null or not _selected_equipment.is_valid():
		return
	equipment_inspection_requested.emit(_selected_equipment)


func _find_token_index(item_list: ItemList, token: String) -> int:
	if token.is_empty():
		return -1
	for index: int in range(item_list.item_count):
		if str(item_list.get_item_metadata(index)) == token:
			return index
	return -1


func _refresh_after_transfer(
	preferred_side: SelectionSide = SelectionSide.NONE,
	preferred_token: String = ""
) -> void:
	refresh_storage(preferred_side, preferred_token)
	if GameManager.game_ui != null:
		GameManager.game_ui.refresh_all()
