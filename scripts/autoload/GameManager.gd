extends Node


const STARTING_LOCATION_ID := "forest"

const CRAFT_DURATION_SECONDS := 4.0
const CRAFT_GAME_MINUTES := 45


var current_survivor: Survivor
var survivor_data: SurvivorData

var current_civilization: CivilizationData
var current_location: LocationData

var game_ui: Control

var pending_startup_messages: Array[String] = []

var _game_started := false

var track_animals_action := TrackAnimalsAction.new()

var should_load_save_on_start := false
var game_session_prepared := false
var survivor_is_at_home := false

func _ready() -> void:
	pass
	


func start_new_game() -> void:
	if _game_started:
		push_warning(
			"start_new_game() was called after "
			+ "the game had already started."
		)
		return

	_game_started = true

	var starting_civilization: CivilizationData = load(
		"res://resources/civilizations/"
		+ "first_civilization.tres"
	)

	if starting_civilization != null:
		current_civilization = (
			starting_civilization.duplicate(true)
		)
	else:
		current_civilization = null

	var starting_survivor_data: SurvivorData = load(
		"res://resources/characters/"
		+ "first_survivor.tres"
	)

	if starting_survivor_data != null:
		survivor_data = (
			starting_survivor_data.duplicate(true)
		)
	else:
		survivor_data = null

	current_location = LocationDatabase.get_location(
		STARTING_LOCATION_ID
	)

	_record_location_visit(
	current_location
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

	current_survivor = survivor_scene.instantiate()

	current_survivor.initialize(
		survivor_data
	)
	current_survivor.died.connect(
		_on_survivor_died
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
	var action: ActionData = (
		ActionDatabase.get_action(
			action_id
		)
	)

	if action == null:
		push_error(
			"Completed unknown action: "
			+ action_id
		)
		return

	if action.action_script == null:
		push_error(
			"Action has no completion script: "
			+ action.id
		)
		return

	var action_instance: Object = (
		action.action_script.new()
	)

	if action_instance == null:
		push_error(
			"Failed to create action-script instance: "
			+ action.id
		)
		return

	if not action_instance.has_method("perform"):
		push_error(
			"Action script has no perform() method: "
			+ action.id
		)
		return

	var result_variant: Variant = (
		action_instance.call(
			"perform",
			current_survivor
		)
	)

	var result: bool = bool(
		result_variant
	)

	if not result:
		push_warning(
			"Action failed to complete: "
			+ action.id
		)

	_award_skill_xp(
		action.skill_id,
		action.xp_reward
	)

	_refresh_ui()
func start_travel(
	destination_id: String
) -> bool:
	if not _can_start_survivor_action():
		return false

	var connection := _get_travel_connection(
		destination_id
	)

	if connection == null:
		_add_event(
			"That destination cannot be reached from here."
		)
		return false

	var destination := LocationDatabase.get_location(
		connection.destination_id
	)

	if destination == null:
		push_error(
			"Unknown travel destination: "
			+ connection.destination_id
		)
		return false

	return ActionManager.start_action(
		"Traveling to "
		+ destination.display_name,
		connection.duration_seconds,
		connection.game_minutes,
		Callable(
			self,
			"_complete_travel"
		).bind(destination_id)
	)


func _complete_travel(
	destination_id: String
) -> void:
	var connection: TravelConnectionData = (
		_get_travel_connection(
			destination_id
		)
	)

	if connection == null:
		push_error(
			"Travel connection disappeared before completion: "
			+ destination_id
		)
		return

	var destination: LocationData = (
		LocationDatabase.get_location(
			connection.destination_id
		)
	)

	if destination == null:
		push_error(
			"Unknown travel destination: "
			+ connection.destination_id
		)
		return

	current_location = destination

	_record_location_visit(
		current_location
)

	DiscoveryManager.check_discoveries()

	_add_event(
		current_survivor.data.display_name
		+ " arrived at "
		+ current_location.display_name
		+ "."
	)

	_award_skill_xp(
		connection.skill_id,
		connection.xp_reward
	)

	_refresh_ui()

func craft_recipe(
	recipe_id: String
) -> bool:
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

	if not can_afford_recipe_from_accessible_inventories(
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


func _complete_craft(
	recipe_id: String
) -> void:
	if current_survivor == null:
		return

	var recipe := RecipeDatabase.get_recipe(
		recipe_id
	)

	if recipe == null:
		return

	var craft_action := CraftAction.new()

	var succeeded := craft_action.perform(
		current_survivor,
		recipe
	)

	if succeeded:
		_award_skill_xp(
			recipe.skill_id,
			recipe.xp_reward
		)

	_refresh_ui()


func _award_skill_xp(
	skill_id: String,
	amount: int
) -> void:
	if current_survivor == null:
		return

	if skill_id.is_empty() or amount <= 0:
		return

	current_survivor.gain_skill_xp(
		skill_id,
		amount
	)


func get_available_actions() -> Array[ActionData]:
	var available_actions: Array[ActionData] = []

	if current_location == null:
		return available_actions

	for action: ActionData in current_location.available_actions:
		if action == null:
			continue

		if not _is_action_unlocked(action):
			continue

		available_actions.append(action)

	return available_actions
	
func _is_action_unlocked(
	action: ActionData
) -> bool:
	if current_civilization == null:
		return false

	match action.id:
		"track_animals":
			return current_civilization.has_discovery(
				"animal_tracks"
			)

		_:
			return true

func get_travel_connections() -> Array[TravelConnectionData]:
	if current_location == null:
		return []

	return current_location.travel_connections


func _get_travel_connection(
	destination_id: String
) -> TravelConnectionData:
	for connection in get_travel_connections():
		if connection == null:
			continue

		if connection.destination_id == destination_id:
			return connection

	return null


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

	if not current_survivor.can_act():
		_add_event(
			current_survivor.data.display_name
			+ " can no longer perform actions."
		)
		return false

	if ActionManager.is_busy:
		return false

	if WorldEventManager.has_pending_event():
		return false

	return true


func debug_kill_current_survivor() -> bool:
	if not OS.is_debug_build():
		return false

	if not _can_start_survivor_action():
		return false

	return current_survivor.die("Debug test")


func _on_survivor_died(
	survivor: Survivor,
	cause: String
) -> void:
	_add_event(
		survivor.data.display_name
		+ " died: "
		+ cause
		+ "."
	)

	survivor_is_at_home = false
	_refresh_ui()

	if game_ui != null and game_ui.has_method(
		"show_final_legacy_summary"
	):
		game_ui.call_deferred(
			"show_final_legacy_summary"
		)


func _add_event(message: String) -> void:
	if game_ui != null:
		game_ui.add_event(message)


func _refresh_ui() -> void:
	if game_ui != null:
		game_ui.refresh_all()
func prepare_new_game() -> void:
	_reset_runtime_state()

	should_load_save_on_start = false
	game_session_prepared = true


func prepare_saved_game() -> void:
	_reset_runtime_state()

	should_load_save_on_start = true
	game_session_prepared = true


func initialize_prepared_game() -> void:
	if not game_session_prepared:
		prepare_new_game()

	if _game_started:
		return

	_initialize_game()


func _initialize_game() -> void:
	ActionDatabase.load_actions()
	LocationDatabase.load_locations()
	ItemDatabase.load_items()
	RecipeDatabase.load_recipes()
	DiscoveryDatabase.load_discoveries()
	WorldEventDatabase.load_events()
	LandmarkDatabase.load_landmarks()
	
	start_new_game()

	if should_load_save_on_start:
		call_deferred("_load_prepared_save")

	call_deferred("_refresh_game_ui_after_start")


func _load_prepared_save() -> void:
	if not SaveManager.load_game():
		_add_event(
			"The saved game could not be loaded."
		)


func _refresh_game_ui_after_start() -> void:
	if game_ui == null:
		return

	game_ui.rebuild_location_controls()
	game_ui.refresh_all()


func _reset_runtime_state() -> void:
	_game_started = false

	current_survivor = null
	survivor_data = null
	current_civilization = null
	current_location = null
	game_ui = null
	survivor_is_at_home = false

	ActionManager.is_busy = false
	ActionManager.current_action_name = ""
	ActionManager.current_progress = 0.0

	WorldEventManager.pending_event = null
	WorldEventManager.completed_event_ids.clear()

	TimeManager.day = 1
	TimeManager.hour = 8
	TimeManager.minute = 0

func _record_location_visit(
	location: LocationData
) -> bool:
	if location == null:
		return false

	if current_civilization == null:
		return false

	var first_visit: bool = (
		current_civilization.record_location_visit(
			location.id
		)
	)

	if not first_visit:
		return false

	_queue_or_add_event(
		location.display_name
		+ " has been recorded in the Journal."
	)

	if not location.first_visit_text.is_empty():
		_queue_or_add_event(
			location.first_visit_text
		)

	return true
	

func _queue_or_add_event(
	message: String
) -> void:
	if game_ui != null:
		game_ui.add_event(message)
		return

	pending_startup_messages.append(message)
	
func flush_pending_startup_messages() -> void:
	if game_ui == null:
		return

	for message in pending_startup_messages:
		game_ui.add_event(message)

	pending_startup_messages.clear()

func is_at_home_location() -> bool:
	if current_civilization == null:
		return false

	if current_location == null:
		return false

	return (
		current_location.id
		== current_civilization.home_location_id
	)


func enter_home() -> bool:
	if current_survivor == null or not current_survivor.can_act():
		return false

	if not is_at_home_location():
		return false

	survivor_is_at_home = true

	return true


func leave_home() -> void:
	survivor_is_at_home = false


func is_survivor_at_home() -> bool:
	return (
		survivor_is_at_home
		and is_at_home_location()
	)


func get_accessible_crafting_inventories(
) -> Array[FrontierInventory]:
	var inventories: Array[FrontierInventory] = []

	if current_survivor == null:
		return inventories

	if (
		is_survivor_at_home()
		and current_civilization != null
		and current_civilization.inventory != null
	):
		inventories.append(
			current_civilization.inventory
		)

	if current_survivor.inventory != null:
		inventories.append(
			current_survivor.inventory
		)

	return inventories


func get_accessible_crafting_item_amount(
	item_id: String
) -> int:
	var total := 0

	for inventory: FrontierInventory in (
		get_accessible_crafting_inventories()
	):
		total += inventory.get_item_amount(
			item_id
		)

	return total


func can_afford_recipe_from_accessible_inventories(
	recipe: RecipeData
) -> bool:
	if recipe == null:
		return false

	for ingredient: IngredientData in recipe.ingredients:
		if (
			ingredient == null
			or not ingredient.is_valid()
		):
			return false

		var available := _get_accessible_ingredient_amount(
			ingredient
		)

		if available < ingredient.amount:
			return false

	return true


func consume_recipe_ingredients_from_accessible_inventories(
	recipe: RecipeData,
	consumed_components: Dictionary = {}
) -> bool:
	if not can_afford_recipe_from_accessible_inventories(
		recipe
	):
		return false

	var inventories: Array[FrontierInventory] = (
		get_accessible_crafting_inventories()
	)

	for ingredient: IngredientData in recipe.ingredients:
		var remaining: int = ingredient.amount

		if ingredient.uses_component_slot():
			var candidates: Array[ItemData] = (
				ItemDatabase.get_components_for_slot(
					ingredient.component_slot
				)
			)

			for component: ItemData in candidates:
				if remaining <= 0:
					break

				for inventory: FrontierInventory in inventories:
					if remaining <= 0:
						break

					var amount_to_remove: int = mini(
						remaining,
						inventory.get_item_amount(
							component.id
						)
					)

					if amount_to_remove <= 0:
						continue

					inventory.remove_item(
						component.id,
						amount_to_remove
					)

					if not consumed_components.has(
						ingredient.component_slot
					):
						consumed_components[
							ingredient.component_slot
						] = component

					remaining -= amount_to_remove

			continue

		for inventory: FrontierInventory in inventories:
			if remaining <= 0:
				break

			var amount_to_remove: int = mini(
				remaining,
				inventory.get_item_amount(
					ingredient.item.id
				)
			)

			if amount_to_remove <= 0:
				continue

			inventory.remove_item(
				ingredient.item.id,
				amount_to_remove
			)

			remaining -= amount_to_remove

	return true

func get_accessible_crafting_ingredient_amount(
	ingredient: IngredientData
) -> int:
	return _get_accessible_ingredient_amount(
		ingredient
	)

func _get_accessible_ingredient_amount(
	ingredient: IngredientData
) -> int:
	if ingredient == null:
		return 0

	if not ingredient.uses_component_slot():
		if ingredient.item == null:
			return 0

		return get_accessible_crafting_item_amount(
			ingredient.item.id
		)

	var total := 0
	var candidates: Array[ItemData] = (
		ItemDatabase.get_components_for_slot(
			ingredient.component_slot
		)
	)

	for component: ItemData in candidates:
		total += get_accessible_crafting_item_amount(
			component.id
		)

	return total
