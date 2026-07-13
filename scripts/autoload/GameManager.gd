extends Node


const SEARCH_DURATION_SECONDS := 3.0
const SEARCH_GAME_MINUTES := 30

const CRAFT_DURATION_SECONDS := 4.0
const CRAFT_GAME_MINUTES := 45

const CHOP_DURATION_SECONDS := 5.0
const CHOP_GAME_MINUTES := 120


var current_survivor: Survivor
var survivor_data: SurvivorData
var current_civilization: CivilizationData

var game_ui: Control

var _game_started := false


func _ready() -> void:
	start_new_game()


func start_new_game() -> void:
	if _game_started:
		push_warning(
			"start_new_game() was called after the game had already started."
		)
		return

	_game_started = true

	current_civilization = load(
		"res://resources/civilizations/first_civilization.tres"
	)

	survivor_data = load(
		"res://resources/characters/first_survivor.tres"
	)

	if current_civilization == null:
		push_error(
			"Failed to load the starting civilization."
		)
		return

	if survivor_data == null:
		push_error(
			"Failed to load the starting survivor data."
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
	current_survivor.initialize(survivor_data)


func search_area() -> bool:
	if not _can_start_survivor_action():
		return false

	return ActionManager.start_action(
		"Searching the wilderness",
		SEARCH_DURATION_SECONDS,
		SEARCH_GAME_MINUTES,
		Callable(self, "_complete_search")
	)


func _complete_search() -> void:
	if current_survivor == null:
		return

	var search := SearchAction.new()
	search.perform(current_survivor)


func craft_recipe(recipe_id: String) -> bool:
	if not _can_start_survivor_action():
		return false

	var recipe := RecipeDatabase.get_recipe(recipe_id)

	if recipe == null:
		return false

	if current_civilization == null:
		return false

	if not current_civilization.has_recipe(recipe.id):
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

	var recipe := RecipeDatabase.get_recipe(recipe_id)

	if recipe == null:
		return

	var craft_action := CraftAction.new()

	craft_action.perform(
		current_survivor,
		recipe
	)

	_refresh_ui()


func chop_tree() -> bool:
	if not _can_start_survivor_action():
		return false

	if not current_survivor.has_equipped_tool(
		"stone_axe"
	):
		_add_event(
			current_survivor.data.display_name
			+ " needs an equipped Stone Axe to chop trees."
		)
		return false

	return ActionManager.start_action(
		"Chopping a tree",
		CHOP_DURATION_SECONDS,
		CHOP_GAME_MINUTES,
		Callable(self, "_complete_chop_tree")
	)


func _complete_chop_tree() -> void:
	if current_survivor == null:
		return

	var chop_action := ChopTreeAction.new()
	chop_action.perform(current_survivor)


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
