extends Control
class_name HomeUI


signal leave_home_requested
signal crafting_requested


@onready var fire_button: Button = %FireButton
@onready var storage_button: Button = %StorageButton
@onready var crafting_button: Button = %CraftingButton
@onready var cooking_button: Button = %CookingButton
@onready var rest_button: Button = %RestButton
@onready var leave_home_button: Button = %LeaveHomeButton


func _ready() -> void:
	leave_home_button.pressed.connect(
		_on_leave_home_button_pressed
	)

	crafting_button.pressed.connect(
		_on_crafting_button_pressed
	)


func _on_leave_home_button_pressed() -> void:
	leave_home_requested.emit()


func _on_crafting_button_pressed() -> void:
	crafting_requested.emit()
