extends Node


const STARTING_LOCATION_ID := "forest"

const CRAFT_DURATION_SECONDS := 4.0
const CRAFT_GAME_MINUTES := 45
const SUCCESSOR_NAMES: Array[String] = [
	"Rowan",
	"Mara",
	"Elias",
	"Tamsin"
]


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

	current_survivor = _instantiate_survivor(survivor_data)

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

	var real_duration: float = action.duration_seconds
	if "axe" in action.required_tool_tags:
		real_duration = EquipmentStatCalculator.get_action_duration_seconds(
			current_survivor.get_equipped_tool_instance(),
			action.duration_seconds
		)

	return ActionManager.start_action(
		action.display_name,
		real_duration,
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


func get_successor_candidate() -> Dictionary:
	if current_civilization == null:
		return {}

	var sequence: int = maxi(current_civilization.next_character_sequence, 1)
	var name_index: int = (sequence - 1) % SUCCESSOR_NAMES.size()

	return {
		"character_id": current_civilization.get_next_successor_id(),
		"display_name": SUCCESSOR_NAMES[name_index]
	}


func continue_as_successor(
	successor_name: String,
	successor_id: String
) -> bool:
	if (
		current_survivor == null
		or current_civilization == null
		or current_survivor.can_act()
		or current_survivor.data.life_record == null
		or not current_survivor.data.life_record.is_finalized
		or ActionManager.is_busy
		or WorldEventManager.has_pending_event()
		or successor_name.strip_edges().is_empty()
		or successor_id.is_empty()
		or successor_id != current_civilization.get_next_successor_id()
		or current_civilization.has_archived_character(successor_id)
	):
		return false

	var previous_survivor: Survivor = current_survivor
	var previous_name: String = previous_survivor.data.display_name
	var preserved_inventory: FrontierInventory = previous_survivor.inventory
	var preserved_tool_instance: ItemInstance = previous_survivor.equipped_tool_instance
	var successor_data := SurvivorData.new()
	successor_data.character_id = successor_id
	successor_data.display_name = successor_name.strip_edges()
	successor_data.is_alive = true
	successor_data.life_record = CharacterLifeRecord.new()

	var successor: Survivor = _instantiate_survivor(successor_data)
	if successor == null:
		return false

	if not current_civilization.archive_completed_life(
		previous_survivor.data.character_id,
		previous_name,
		previous_survivor.data.life_record
	):
		successor.free()
		return false

	successor.inventory = preserved_inventory
	successor.equipped_tool_instance = preserved_tool_instance
	current_survivor = successor
	survivor_data = successor_data
	current_civilization.advance_character_sequence()
	survivor_is_at_home = false

	previous_survivor.free()

	_add_event(
		successor_data.display_name
		+ " arrived to continue what "
		+ previous_name
		+ " began."
	)
	_refresh_ui()

	return true


func _instantiate_survivor(data: SurvivorData) -> Survivor:
	if data == null:
		return null

	var survivor_scene: PackedScene = load(
		"res://scenes/characters/Survivor.tscn"
	)

	if survivor_scene == null:
		push_error("Failed to load Survivor.tscn.")
		return null

	var survivor: Survivor = survivor_scene.instantiate()
	survivor.initialize(data)
	survivor.died.connect(_on_survivor_died)

	return survivor


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


func consume_accessible_item(item_id: String, amount: int = 1) -> bool:
	if item_id.is_empty() or amount <= 0:
		return false
	if get_accessible_crafting_item_amount(item_id) < amount:
		return false

	var remaining := amount
	for inventory: FrontierInventory in get_accessible_crafting_inventories():
		if remaining <= 0:
			break
		var amount_to_remove: int = mini(
			remaining,
			inventory.get_item_amount(item_id)
		)
		if amount_to_remove <= 0:
			continue
		if inventory.remove_item(item_id, amount_to_remove):
			remaining -= amount_to_remove
	return remaining == 0


func disassemble_equipment(instance: ItemInstance) -> bool:
	if (
		instance == null
		or not instance.is_valid()
		or current_survivor == null
		or current_civilization == null
		or not current_survivor.can_act()
		or not is_survivor_at_home()
	):
		return false
	var equipped: ItemInstance = current_survivor.get_equipped_tool_instance()
	if equipped != null and equipped.instance_id == instance.instance_id:
		return false
	var owner: FrontierInventory
	for inventory: FrontierInventory in get_accessible_crafting_inventories():
		if inventory.get_equipment_instance(instance.instance_id) != null:
			owner = inventory
			break
	if owner == null:
		return false

	var record: EquipmentDisassemblyRecord = EquipmentDisassemblyService.build_record(
		instance,
		current_survivor.data.character_id,
		current_survivor.data.display_name
	)
	if record == null:
		return false
	var removed: ItemInstance = owner.remove_equipment_instance(instance.instance_id)
	if removed == null:
		return false
	if not current_civilization.record_equipment_disassembly(record):
		owner.add_equipment_instance(removed)
		return false

	for recovered_item_id: String in record.recovered_component_item_ids:
		current_civilization.inventory.add_item(recovered_item_id, 1)

	var item: ItemData = ItemDatabase.get_item(record.item_id)
	var item_name: String = record.item_id
	if item != null:
		item_name = item.display_name
	current_civilization.record_history_event(
		"equipment.disassembled." + record.instance_id,
		"Equipment Disassembled",
		current_survivor.data.display_name + " disassembled " + item_name + ".",
		"crafting",
		current_survivor.data.character_id,
		current_survivor.data.display_name,
		record.disassembled_day,
		record.disassembled_hour,
		record.disassembled_minute
	)
	if game_ui != null:
		game_ui.add_event(
			current_survivor.data.display_name + " disassembled " + item_name + "."
		)
	return true


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
	consumed_components: Dictionary = {},
	component_records: Array[EquipmentComponentRecord] = []
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

					_record_consumed_component(
						component_records,
						component,
						ingredient.component_slot,
						amount_to_remove
					)

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

			if ingredient.item.is_tool_component():
				_record_consumed_component(
					component_records,
					ingredient.item,
					ingredient.item.component_slot,
					amount_to_remove
				)

			remaining -= amount_to_remove

	return true


func _record_consumed_component(
	records: Array[EquipmentComponentRecord],
	item: ItemData,
	component_slot: String,
	amount: int
) -> void:
	if item == null or component_slot.is_empty() or amount <= 0:
		return

	for record: EquipmentComponentRecord in records:
		if (
			record != null
			and record.component_slot == component_slot
			and record.item_id == item.id
		):
			record.amount += amount
			return

	var record: EquipmentComponentRecord = EquipmentComponentRecord.new()
	record.component_slot = component_slot
	record.item_id = item.id
	record.material_id = item.material_id
	record.material_quality = maxi(item.material_quality, 0)
	record.amount = amount
	records.append(record)

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
