extends Control
class_name StorageUI


signal back_requested


@onready var storage_log: RichTextLabel = %StorageLog
@onready var back_button: Button = %BackButton


var carried_title: Label
var carried_list: ItemList
var storage_list: ItemList

var amount_spinner: SpinBox
var keep_checkbox: CheckBox

var deposit_button: Button
var take_button: Button
var deposit_all_button: Button

var _is_refreshing := false


func _ready() -> void:
	back_button.pressed.connect(
		_on_back_pressed
	)

	_build_transfer_interface()


func _build_transfer_interface() -> void:
	storage_log.visible = false

	var storage_layout: VBoxContainer = (
		storage_log.get_parent()
	)

	var transfer_row := HBoxContainer.new()
	transfer_row.name = "TransferRow"
	transfer_row.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	transfer_row.add_theme_constant_override(
		"separation",
		16
	)

	storage_layout.add_child(
		transfer_row
	)

	storage_layout.move_child(
		transfer_row,
		back_button.get_index()
	)

	var carried_column := VBoxContainer.new()
	carried_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	transfer_row.add_child(
		carried_column
	)

	carried_title = Label.new()
	carried_title.text = "Expedition Inventory"
	carried_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	carried_column.add_child(
		carried_title
	)

	carried_list = ItemList.new()
	carried_list.custom_minimum_size = Vector2(
		220,
		300
	)
	carried_list.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	carried_list.select_mode = (
		ItemList.SELECT_SINGLE
	)

	carried_list.item_selected.connect(
		_on_carried_item_selected
	)

	carried_column.add_child(
		carried_list
	)

	var controls_column := VBoxContainer.new()
	controls_column.custom_minimum_size.x = 150
	controls_column.alignment = (
		BoxContainer.ALIGNMENT_CENTER
	)
	controls_column.add_theme_constant_override(
		"separation",
		10
	)

	transfer_row.add_child(
		controls_column
	)

	var amount_label := Label.new()
	amount_label.text = "Quantity"
	amount_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	controls_column.add_child(
		amount_label
	)

	amount_spinner = SpinBox.new()
	amount_spinner.min_value = 1
	amount_spinner.max_value = 1
	amount_spinner.value = 1
	amount_spinner.step = 1
	amount_spinner.allow_greater = false
	amount_spinner.allow_lesser = false

	controls_column.add_child(
		amount_spinner
	)

	deposit_button = Button.new()
	deposit_button.text = "Deposit →"
	deposit_button.disabled = true

	deposit_button.pressed.connect(
		_on_deposit_pressed
	)

	controls_column.add_child(
		deposit_button
	)

	take_button = Button.new()
	take_button.text = "← Take"
	take_button.disabled = true

	take_button.pressed.connect(
		_on_take_pressed
	)

	controls_column.add_child(
		take_button
	)

	keep_checkbox = CheckBox.new()
	keep_checkbox.text = "Keep"
	keep_checkbox.disabled = true
	keep_checkbox.tooltip_text = (
		"Kept items are skipped by Deposit All."
	)

	keep_checkbox.toggled.connect(
		_on_keep_toggled
	)

	controls_column.add_child(
		keep_checkbox
	)

	deposit_all_button = Button.new()
	deposit_all_button.text = "Deposit All"
	deposit_all_button.tooltip_text = (
		"Deposit every carried item except those marked Keep."
	)

	deposit_all_button.pressed.connect(
		_on_deposit_all_pressed
	)

	controls_column.add_child(
		deposit_all_button
	)

	var storage_column := VBoxContainer.new()
	storage_column.size_flags_horizontal = (
		Control.SIZE_EXPAND_FILL
	)

	transfer_row.add_child(
		storage_column
	)

	var storage_title := Label.new()
	storage_title.text = "Camp Storage"
	storage_title.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	storage_column.add_child(
		storage_title
	)

	storage_list = ItemList.new()
	storage_list.custom_minimum_size = Vector2(
		220,
		300
	)
	storage_list.size_flags_vertical = (
		Control.SIZE_EXPAND_FILL
	)
	storage_list.select_mode = (
		ItemList.SELECT_SINGLE
	)

	storage_list.item_selected.connect(
		_on_storage_item_selected
	)

	storage_column.add_child(
		storage_list
	)


func refresh_storage() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		survivor == null
		or civilization == null
	):
		return

	_is_refreshing = true

	carried_title.text = (
		survivor.data.display_name
		+ "'s Pack"
	)

	_populate_item_list(
		carried_list,
		survivor.inventory,
		true
	)

	_populate_item_list(
		storage_list,
		civilization.inventory,
		false
	)

	deposit_button.disabled = true
	take_button.disabled = true
	keep_checkbox.disabled = true
	keep_checkbox.button_pressed = false

	deposit_all_button.disabled = (
		survivor.inventory.items.is_empty()
	)

	amount_spinner.min_value = 1
	amount_spinner.max_value = 1
	amount_spinner.value = 1

	_is_refreshing = false


func _populate_item_list(
	item_list: ItemList,
	inventory: FrontierInventory,
	show_keep_status: bool
) -> void:
	item_list.clear()

	if inventory == null:
		return

	var item_ids: Array = inventory.items.keys()
	item_ids.sort()

	for item_id_variant: Variant in item_ids:
		var item_id := str(
			item_id_variant
		)

		var amount: int = (
			inventory.get_item_amount(
				item_id
			)
		)

		if amount <= 0:
			continue

		var item_data: ItemData = (
			ItemDatabase.get_item(
				item_id
			)
		)

		var display_name := item_id

		if item_data != null:
			display_name = item_data.display_name

		var item_text := (
			display_name
			+ " x"
			+ str(amount)
		)

		if (
			show_keep_status
			and inventory.is_item_kept(item_id)
		):
			item_text = "★ " + item_text

		var index: int = (
			item_list.add_item(
				item_text
			)
		)

		item_list.set_item_metadata(
			index,
			item_id
		)


func _on_carried_item_selected(
	index: int
) -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		return

	var item_id := str(
		carried_list.get_item_metadata(
			index
		)
	)

	var amount: int = (
		survivor.inventory.get_item_amount(
			item_id
		)
	)

	amount_spinner.max_value = maxi(
		amount,
		1
	)
	amount_spinner.value = 1

	deposit_button.disabled = amount <= 0
	take_button.disabled = true

	_is_refreshing = true

	keep_checkbox.disabled = amount <= 0
	keep_checkbox.button_pressed = (
		survivor.inventory.is_item_kept(
			item_id
		)
	)

	_is_refreshing = false


func _on_storage_item_selected(
	index: int
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	var item_id := str(
		storage_list.get_item_metadata(
			index
		)
	)

	var amount: int = (
		civilization.inventory.get_item_amount(
			item_id
		)
	)

	amount_spinner.max_value = maxi(
		amount,
		1
	)
	amount_spinner.value = 1

	take_button.disabled = amount <= 0
	deposit_button.disabled = true
	keep_checkbox.disabled = true

	_is_refreshing = true
	keep_checkbox.button_pressed = false
	_is_refreshing = false


func _on_deposit_pressed() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		survivor == null
		or civilization == null
	):
		return

	var item_id := _get_selected_item_id(
		carried_list
	)

	if item_id.is_empty():
		return

	survivor.inventory.transfer_item_to(
		civilization.inventory,
		item_id,
		int(amount_spinner.value)
	)

	_refresh_after_transfer()


func _on_take_pressed() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		survivor == null
		or civilization == null
	):
		return

	var item_id := _get_selected_item_id(
		storage_list
	)

	if item_id.is_empty():
		return

	civilization.inventory.transfer_item_to(
		survivor.inventory,
		item_id,
		int(amount_spinner.value)
	)

	_refresh_after_transfer()


func _on_deposit_all_pressed() -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if (
		survivor == null
		or civilization == null
	):
		return

	survivor.inventory.transfer_all_to(
		civilization.inventory,
		true
	)

	_refresh_after_transfer()


func _on_keep_toggled(
	is_kept: bool
) -> void:
	if _is_refreshing:
		return

	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		return

	var item_id := _get_selected_item_id(
		carried_list
	)

	if item_id.is_empty():
		return

	survivor.inventory.set_item_kept(
		item_id,
		is_kept
	)

	refresh_storage()


func _get_selected_item_id(
	item_list: ItemList
) -> String:
	var selected: PackedInt32Array = (
		item_list.get_selected_items()
	)

	if selected.is_empty():
		return ""

	return str(
		item_list.get_item_metadata(
			selected[0]
		)
	)


func _refresh_after_transfer() -> void:
	refresh_storage()

	if GameManager.game_ui != null:
		GameManager.game_ui.refresh_all()


func _on_back_pressed() -> void:
	back_requested.emit()
