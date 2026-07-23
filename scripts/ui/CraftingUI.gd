extends Control
class_name CraftingUI


signal craft_requested(recipe_id: String)
signal back_requested


@onready var recipe_selector: OptionButton = %RecipeSelector
@onready var recipe_label: RichTextLabel = %RecipeLabel
@onready var craft_button: Button = %CraftButton
@onready var back_button: Button = %BackButton

var selected_recipe_id: String = ""


func _ready() -> void:
	recipe_selector.item_selected.connect(_on_recipe_selected)
	craft_button.pressed.connect(_on_craft_pressed)
	back_button.pressed.connect(back_requested.emit)


func get_default_focus_target() -> Control:
	return recipe_selector


func refresh() -> void:
	var survivor: Survivor = GameManager.current_survivor
	var civilization: CivilizationData = GameManager.current_civilization

	if survivor == null or civilization == null:
		_show_unavailable("Crafting unavailable.")
		return

	_populate_recipe_selector(civilization)

	if selected_recipe_id.is_empty():
		_show_unavailable("No recipes discovered.")
		return

	var recipe: RecipeData = RecipeDatabase.get_recipe(selected_recipe_id)
	if recipe == null:
		_show_unavailable("Crafting unavailable.")
		return

	recipe_selector.visible = true
	recipe_selector.disabled = false
	craft_button.visible = true
	craft_button.text = "Craft " + recipe.display_name
	recipe_label.text = _build_recipe_text(recipe)
	craft_button.disabled = (
		not survivor.can_act()
		or ActionManager.is_busy
		or WorldEventManager.has_pending_event()
		or not GameManager.can_afford_recipe_from_accessible_inventories(recipe)
	)


func _populate_recipe_selector(civilization: CivilizationData) -> void:
	var previous_recipe_id: String = selected_recipe_id
	recipe_selector.clear()

	for recipe_id: String in civilization.unlocked_recipe_ids:
		var recipe: RecipeData = RecipeDatabase.get_recipe(recipe_id)
		if recipe == null:
			continue

		recipe_selector.add_item(recipe.display_name)
		var index: int = recipe_selector.item_count - 1
		recipe_selector.set_item_metadata(index, recipe.id)

	if recipe_selector.item_count <= 0:
		selected_recipe_id = ""
		return

	var selected_index := 0
	for index: int in range(recipe_selector.item_count):
		var recipe_id: String = str(
			recipe_selector.get_item_metadata(index)
		)
		if recipe_id == previous_recipe_id:
			selected_index = index
			break

	recipe_selector.select(selected_index)
	selected_recipe_id = str(
		recipe_selector.get_item_metadata(selected_index)
	)


func _build_recipe_text(recipe: RecipeData) -> String:
	var recipe_text := (
		_build_result_heading(recipe)
		+ "\n\n"
		+ recipe.description
		+ "\n\nRequires:\n"
	)

	for ingredient: IngredientData in recipe.ingredients:
		if ingredient == null or not ingredient.is_valid():
			continue

		var owned: int = (
			GameManager.get_accessible_crafting_ingredient_amount(ingredient)
		)
		var ingredient_name := ""
		if ingredient.uses_component_slot():
			ingredient_name = (
				ingredient.component_slot.capitalize()
				+ " (best available)"
			)
		else:
			ingredient_name = ItemPresentation.colorize_name(ingredient.item)

		recipe_text += (
			ingredient_name
			+ ": "
			+ str(owned)
			+ " / "
			+ str(ingredient.amount)
			+ "\n"
		)

	return recipe_text


func _build_result_heading(recipe: RecipeData) -> String:
	for result: IngredientData in recipe.results:
		if result != null and result.is_valid() and result.item != null:
			return ItemPresentation.colorize_name(result.item, recipe.display_name)
	return recipe.display_name


func _show_unavailable(message: String) -> void:
	recipe_selector.clear()
	recipe_selector.visible = true
	recipe_selector.disabled = false
	recipe_label.text = message
	craft_button.disabled = true
	craft_button.visible = false


func _on_recipe_selected(index: int) -> void:
	if index < 0 or index >= recipe_selector.item_count:
		return

	selected_recipe_id = str(recipe_selector.get_item_metadata(index))
	refresh()


func _on_craft_pressed() -> void:
	if selected_recipe_id.is_empty():
		return

	craft_requested.emit(selected_recipe_id)
