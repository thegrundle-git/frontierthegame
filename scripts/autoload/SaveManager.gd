extends Node


const SAVE_PATH := "user://frontier_save.json"
const SAVE_VERSION := 3


func save_game() -> bool:
	if not _can_save():
		push_warning("The current game is not ready to save.")
		return false

	var save_data := _build_save_data()

	var json_text := JSON.stringify(
		save_data,
		"\t"
	)

	var save_file := FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if save_file == null:
		push_error(
			"Could not open the save file for writing."
		)
		return false

	save_file.store_string(json_text)
	save_file.close()

	_add_event("Game saved.")

	print("Game saved to: ", SAVE_PATH)

	return true


func load_game() -> bool:
	if not save_exists():
		_add_event("No save file was found.")
		return false

	var save_file := FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if save_file == null:
		push_error(
			"Could not open the save file for reading."
		)
		return false

	var json_text := save_file.get_as_text()
	save_file.close()

	var parsed_data = JSON.parse_string(
		json_text
	)

	if parsed_data == null:
		push_error(
			"The save file contains invalid JSON."
		)
		return false

	if parsed_data is not Dictionary:
		push_error(
			"The save file does not contain a valid save dictionary."
		)
		return false

	if not _validate_save_data(parsed_data):
		return false

	_apply_save_data(parsed_data)

	_add_event("Game loaded.")

	if GameManager.game_ui != null:
		GameManager.game_ui.rebuild_location_controls()
		GameManager.game_ui.refresh_all()

	print("Game loaded from: ", SAVE_PATH)

	return true

func save_exists() -> bool:
	return FileAccess.file_exists(
		SAVE_PATH
	)


func delete_save() -> bool:
	if not save_exists():
		return false

	var absolute_path := ProjectSettings.globalize_path(
		SAVE_PATH
	)

	var error := DirAccess.remove_absolute(
		absolute_path
	)

	return error == OK


func get_save_path() -> String:
	return SAVE_PATH


func _build_save_data() -> Dictionary:
	var survivor := GameManager.current_survivor
	var civilization := GameManager.current_civilization
	var location := GameManager.current_location

	return {
		"save_version": SAVE_VERSION,
		"time": {
			"day": TimeManager.day,
			"hour": TimeManager.hour,
			"minute": TimeManager.minute
		},
		"current_location_id": location.id,
		"survivor": {
			"display_name": survivor.data.display_name,
			"equipped_tool_id": survivor.equipped_tool_id,
			"inventory": _serialize_inventory(
				survivor.inventory
			),
			"kept_item_ids": (
				survivor.inventory.kept_item_ids.duplicate()
			),
			"skills": _serialize_skills(
				survivor
			)
		},
		"civilization": {
			"display_name": civilization.display_name,
			"inventory": _serialize_inventory(
				civilization.inventory
			),
			"discovered_landmark_ids": civilization.discovered_landmark_ids.duplicate(),
			"knowledge": civilization.knowledge,
			"visited_location_ids": civilization.visited_location_ids.duplicate(),
			"observed_item_ids": civilization.observed_item_ids.duplicate(),
			"discovered_ids": civilization.discovered_ids.duplicate(),
			"unlocked_recipe_ids": civilization.unlocked_recipe_ids.duplicate(),
			"wilderness_search_count": civilization.wilderness_search_count,
			"history_entries": _serialize_history_entries(
				civilization.history_entries
			),
		},
		"world_events": {
			"completed_event_ids": WorldEventManager.completed_event_ids.duplicate()
		}
	}


func _serialize_inventory(
	inventory: FrontierInventory
) -> Dictionary:
	var inventory_data: Dictionary = {}

	for item_id in inventory.items:
		inventory_data[item_id] = (
			inventory.get_item_amount(item_id)
		)

	return inventory_data


func _serialize_skills(
	survivor: Survivor
) -> Dictionary:
	var skill_data: Dictionary = {}

	for skill in survivor.get_all_skills():
		skill_data[skill.id] = {
			"level": skill.level,
			"xp": skill.xp
		}

	return skill_data


func _serialize_history_entries(
	history_entries: Array[CivilizationHistoryEntry]
) -> Array[Dictionary]:
	var history_data: Array[Dictionary] = []

	for entry: CivilizationHistoryEntry in history_entries:
		if entry == null:
			continue

		history_data.append({
			"event_id": entry.event_id,
			"title": entry.title,
			"description": entry.description,
			"category": entry.category,
			"contributor_id": entry.contributor_id,
			"contributor_name": entry.contributor_name,
			"day": entry.day,
			"hour": entry.hour,
			"minute": entry.minute,
		})

	return history_data


func _apply_save_data(
	save_data: Dictionary
) -> void:
	_apply_time_data(
		save_data.get(
			"time",
			{}
		)
	)

	_apply_location_data(
		str(
			save_data.get(
				"current_location_id",
				"forest"
			)
		)
	)

	_apply_survivor_data(
		save_data.get(
			"survivor",
			{}
		)
	)

	_apply_civilization_data(
		save_data.get(
			"civilization",
			{}
		)
	)

	if GameManager.current_survivor != null:
		GameManager.current_survivor.normalize_equipped_tool_ownership()

	_apply_world_event_data(
		save_data.get(
			"world_events",
			{}
		)
	)

	TimeManager.time_changed.emit()
func _apply_time_data(
	time_data: Dictionary
) -> void:
	TimeManager.day = max(
		int(time_data.get("day", 1)),
		1
	)

	TimeManager.hour = clamp(
		int(time_data.get("hour", 8)),
		0,
		23
	)

	TimeManager.minute = clamp(
		int(time_data.get("minute", 0)),
		0,
		59
	)


func _apply_location_data(
	location_id: String
) -> void:
	var location := LocationDatabase.get_location(
		location_id
	)

	if location == null:
		push_warning(
			"Saved location was not found: "
			+ location_id
			+ ". Using Forest."
		)

		location = LocationDatabase.get_location(
			"forest"
		)

	GameManager.current_location = location


func _apply_survivor_data(
	survivor_data: Dictionary
) -> void:
	var survivor: Survivor = (
		GameManager.current_survivor
	)

	if survivor == null:
		return

	survivor.data.display_name = str(
		survivor_data.get(
			"display_name",
			survivor.data.display_name
		)
	)

	survivor.equipped_tool_id = str(
		survivor_data.get(
			"equipped_tool_id",
			""
		)
	)

	_apply_inventory_data(
		survivor.inventory,
		survivor_data.get(
			"inventory",
			{}
		)
	)

	var saved_kept_item_ids: Array[String] = (
		_string_array_from_variant(
			survivor_data.get(
				"kept_item_ids",
				[]
			)
		)
	)

	survivor.inventory.kept_item_ids.clear()

	for item_id: String in saved_kept_item_ids:
		if survivor.inventory.has_item(
			item_id
		):
			survivor.inventory.kept_item_ids.append(
				item_id
			)

	_apply_skill_data(
		survivor,
		survivor_data.get(
			"skills",
			{}
		)
	)


func _apply_inventory_data(
	inventory: FrontierInventory,
	inventory_data: Dictionary
) -> void:
	inventory.items.clear()

	for item_id_variant in inventory_data:
		var item_id := str(item_id_variant)
		var amount := int(
			inventory_data[item_id_variant]
		)

		if amount <= 0:
			continue

		if ItemDatabase.get_item(item_id) == null:
			push_warning(
				"Skipped unknown saved item: "
				+ item_id
			)
			continue

		inventory.items[item_id] = amount


func _apply_skill_data(
	survivor: Survivor,
	skills_data: Dictionary
) -> void:
	for skill_id_variant in skills_data:
		var skill_id := str(
			skill_id_variant
		)

		var skill := survivor.get_skill(
			skill_id
		)

		if skill == null:
			push_warning(
				"Skipped unknown saved skill: "
				+ skill_id
			)
			continue

		var saved_skill_data = (
			skills_data[skill_id_variant]
		)

		if saved_skill_data is not Dictionary:
			continue

		skill.level = max(
			int(
				saved_skill_data.get(
					"level",
					1
				)
			),
			1
		)

		skill.xp = max(
			int(
				saved_skill_data.get(
					"xp",
					0
				)
			),
			0
		)


func _apply_civilization_data(
	civilization_data: Dictionary
) -> void:
	var civilization: CivilizationData = (
		GameManager.current_civilization
	)

	if civilization == null:
		return

	if civilization_data.has("inventory"):
		var saved_inventory: Variant = (
			civilization_data.get(
				"inventory",
				{}
			)
		)

		if saved_inventory is Dictionary:
			_apply_inventory_data(
				civilization.inventory,
				saved_inventory
			)
	else:
		var survivor: Survivor = (
			GameManager.current_survivor
		)

		if (
			survivor != null
			and survivor.inventory != null
		):
			civilization.inventory.items = (
				survivor.inventory.items.duplicate(
					true
				)
			)

			survivor.inventory.items.clear()

	civilization.display_name = str(
		civilization_data.get(
			"display_name",
			civilization.display_name
		)
	)
	
	civilization.visited_location_ids = (
	_string_array_from_variant(
		civilization_data.get(
			"visited_location_ids",
			[]
		)
	)
)
	civilization.discovered_landmark_ids = (
		_string_array_from_variant(
			civilization_data.get(
				"discovered_landmark_ids",
				[]
			)
		)
	)
	
	civilization.knowledge = max(
		int(
			civilization_data.get(
				"knowledge",
				0
			)
		),
		0
	)

	civilization.observed_item_ids = (
		_string_array_from_variant(
			civilization_data.get(
				"observed_item_ids",
				[]
			)
		)
	)

	civilization.discovered_ids = (
		_string_array_from_variant(
			civilization_data.get(
				"discovered_ids",
				[]
			)
		)
	)

	civilization.unlocked_recipe_ids = (
		_string_array_from_variant(
			civilization_data.get(
				"unlocked_recipe_ids",
				[]
			)
		)
	)

	civilization.wilderness_search_count = int(
	civilization_data.get(
		"wilderness_search_count",
		0
	)
)

	_apply_history_data(
		civilization,
		civilization_data.get(
			"history_entries",
			[]
		)
	)

	civilization.synchronize_unlocked_recipes()


func _apply_history_data(
	civilization: CivilizationData,
	history_data: Variant
) -> void:
	civilization.history_entries.clear()

	if history_data is not Array:
		push_warning(
			"Skipped malformed civilization history data."
		)
		return

	for entry_variant: Variant in history_data:
		if entry_variant is not Dictionary:
			push_warning(
				"Skipped malformed civilization history entry."
			)
			continue

		var entry_data: Dictionary = entry_variant
		var entry := CivilizationHistoryEntry.new()
		entry.event_id = str(
			entry_data.get("event_id", "")
		)
		entry.title = str(
			entry_data.get("title", "")
		)
		entry.description = str(
			entry_data.get("description", "")
		)
		entry.category = str(
			entry_data.get("category", "")
		)
		entry.contributor_id = str(
			entry_data.get("contributor_id", "")
		)
		entry.contributor_name = str(
			entry_data.get("contributor_name", "")
		)
		entry.day = max(
			_history_int_from_variant(
				entry_data.get("day", 1),
				1
			),
			1
		)
		entry.hour = clamp(
			_history_int_from_variant(
				entry_data.get("hour", 0),
				0
			),
			0,
			23
		)
		entry.minute = clamp(
			_history_int_from_variant(
				entry_data.get("minute", 0),
				0
			),
			0,
			59
		)

		if not civilization.record_history_entry(entry):
			push_warning(
				"Skipped invalid or duplicate history event: "
				+ entry.event_id
			)


func _history_int_from_variant(
	value: Variant,
	fallback: int
) -> int:
	if value is int or value is float:
		return int(value)

	if value is String:
		var string_value := str(value)

		if string_value.is_valid_int():
			return string_value.to_int()

	return fallback

func _apply_world_event_data(
	event_data: Dictionary
) -> void:
	WorldEventManager.pending_event = null

	WorldEventManager.completed_event_ids = (
		_string_array_from_variant(
			event_data.get(
				"completed_event_ids",
				[]
			)
		)
	)


func _string_array_from_variant(
	value
) -> Array[String]:
	var result: Array[String] = []

	if value is not Array:
		return result

	for entry in value:
		result.append(
			str(entry)
		)

	return result


func _validate_save_data(
	save_data: Dictionary
) -> bool:
	var version := int(
		save_data.get(
			"save_version",
			-1
		)
	)

	if (
		version < 1
		or version > SAVE_VERSION):
		push_error(
			"Unsupported save version: "
			+ str(version)
		)
		return false

	if not save_data.has("survivor"):
		push_error(
			"Save file is missing survivor data."
		)
		return false

	if not save_data.has("civilization"):
		push_error(
			"Save file is missing civilization data."
		)
		return false

	return true


func _can_save() -> bool:
	if GameManager.current_survivor == null:
		return false

	if GameManager.current_civilization == null:
		return false

	if GameManager.current_location == null:
		return false

	if ActionManager.is_busy:
		_add_event(
			"Finish the current action before saving."
		)
		return false

	if WorldEventManager.has_pending_event():
		_add_event(
			"Resolve the current event before saving."
		)
		return false

	return true


func _add_event(message: String) -> void:
	if GameManager.game_ui != null:
		GameManager.game_ui.add_event(message)
