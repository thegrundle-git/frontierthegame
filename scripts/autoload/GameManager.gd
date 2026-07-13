extends Node


const STARTING_LOCATION_ID := "forest"

const CRAFT_DURATION_SECONDS := 4.0
const CRAFT_GAME_MINUTES := 45


var current_survivor: Survivor
var survivor_data: SurvivorData

var current_civilization: CivilizationData
var current_location: LocationData

var game_ui: Control

var _game_started := false


func _ready() -> void:
	start_new_game()


func start_new_game() -> void:
	if _game_started:
		push_warning(
			"start_new_game() was called after "
			+ "the game had already started."
		)
		return

	_game_started = true

	current_civilization = load(
		"res://resources/civilizations/"
		+ "first_civilization.tres"
	)

	survivor_data = load(
		"res://resources/characters/"
		+ "first_survivor.tres"
	)

	current_location = (
		LocationDatabase.get_location(
			STARTING_LOCATION_ID
		)
	)

	if current_civilization == null:
		push_error(
			"Failed to load the starting civilization."
		)
		return

	if survivor_data == null:
		push_error(
			"Failed to load the starting survivor."
		)
		return

	if current_location == null:
		push_error(
			"Failed to load starting location: "
			+ STARTING_LOCATION_ID
		)
		return

	var survivor_scene: PackedScene = load(
		"res://scenes/characters/Survivor.tscn"
	)

	if survivor_scene == null:
		push_error(
			"Failed to load Survivor.tscn."
		)
		return

	current_survivor = (
		survivor_scene.instantiate()
	)

	current_survivor.initialize(
		survivor_data
	)


func start_world_action(
	action_id: String
) -> bool:
	if not _can_start_survivor_action():
		return false

	var action := ActionDatabase.get_action(
		action_id
	)

	if action == null:
		return false

	if not _location_allows_action(action_id):
		_add_event(
			"That action is not available here."
		)
		return false

	if not _meets_action_requirements(action):
		return false

	if action.action_script == null:
		push_error(
			"Action has no completion script: "
			+ action.id
		)
		return false

	return ActionManager.start_action(
		action.display_name,
		action.duration_seconds,
		action.game_minutes,
		Callable(
			self,
			"_complete_world_action"
		).bind(action.id)
	)


func _complete_world_action(
	action_id: String
) -> void:
	if current_survivor == null:
		return

	var action := ActionDatabase.get_action(
		action_id
	)

	if action == null:
		return

	if action.action_script == null:
		return

	var action_instance = (
		action.action_script.new()
	)

	if not action_instance.has_method("perform"):
		push_error(
			"Action script has no perform() method: "
			+ action.id
		)
		return

	action_instance.call(
		"perform",
		current_survivor
	)

	_refresh_ui()


func craft_recipe(recipe_id: String) -> bool:
	if not _can_start_survivor_action():
		return false

	var recipe := RecipeDatabase.get_recipe(
		recipe_id
	)

	if recipe == null:
		return false

	if current_civilization == null:
		return false

	if not current_civilization.has_recipe(
		recipe.id
	):
		_add_event(
			"That recipe has not been discovered."
		)
		return false

	if not current_survivor.inventory.can_afford_recipe(
		recipe
	):
		_add_event(
			"Not enough materials to craft "
			+ recipe.display_name
			+ "."
		)
		return false

	return ActionManager.start_action(
		"Crafting " + recipe.display_name,
		CRAFT_DURATION_SECONDS,
		CRAFT_GAME_MINUTES,
		Callable(
			self,
			"_complete_craft"
		).bind(recipe_id)
	)


func _complete_craft(recipe_id: String) -> void:
	if current_survivor == null:
		return

	var recipe := RecipeDatabase.get_recipe(
		recipe_id
	)

	if recipe == null:
		return

	var craft_action := CraftAction.new()

	craft_action.perform(
		current_survivor,
		recipe
	)

	_refresh_ui()


func get_available_actions() -> Array[ActionData]:
	if current_location == null:
		return []

	return current_location.available_actions


func _location_allows_action(
	action_id: String
) -> bool:
	for action in get_available_actions():
		if action == null:
			continue

		if action.id == action_id:
			return true

	return false


func _meets_action_requirements(
	action: ActionData
) -> bool:
	if action.required_tool_id.is_empty():
		return true

	if current_survivor.has_equipped_tool(
		action.required_tool_id
	):
		return true

	var tool_data := ItemDatabase.get_item(
		action.required_tool_id
	)

	if tool_data == null:
		_add_event(
			"A required tool is missing."
		)
		return false

	_add_event(
		current_survivor.data.display_name
		+ " needs an equipped "
		+ tool_data.display_name
		+ " to "
		+ action.display_name.to_lower()
		+ "."
	)

	return false


func _can_start_survivor_action() -> bool:
	if current_survivor == null:
		return false

	if ActionManager.is_busy:
		return false

	return true


func _add_event(message: String) -> void:
	if game_ui != null:
		game_ui.add_event(message)


func _refresh_ui() -> void:
	if game_ui != null:
		game_ui.refresh_all()
