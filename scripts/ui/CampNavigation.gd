extends PanelContainer
class_name CampNavigation


signal screen_requested(screen_id: String)
signal leave_requested


const OVERVIEW_SCREEN_ID := "camp.overview"
const STORAGE_SCREEN_ID := "camp.storage"
const CRAFTING_SCREEN_ID := "camp.crafting"


@onready var overview_button: Button = %OverviewButton
@onready var storage_button: Button = %StorageButton
@onready var crafting_button: Button = %CraftingButton
@onready var leave_button: Button = %LeaveButton


func _ready() -> void:
	overview_button.pressed.connect(
		_request_screen.bind(OVERVIEW_SCREEN_ID)
	)
	storage_button.pressed.connect(
		_request_screen.bind(STORAGE_SCREEN_ID)
	)
	crafting_button.pressed.connect(
		_request_screen.bind(CRAFTING_SCREEN_ID)
	)
	leave_button.pressed.connect(leave_requested.emit)


func set_current_screen(screen_id: String) -> void:
	overview_button.disabled = screen_id == OVERVIEW_SCREEN_ID
	storage_button.disabled = screen_id == STORAGE_SCREEN_ID
	crafting_button.disabled = screen_id == CRAFTING_SCREEN_ID


func _request_screen(screen_id: String) -> void:
	screen_requested.emit(screen_id)
