extends Node


const SAVE_PATH := "user://frontier_save.json"
const SAVE_VERSION := 9
const SUCCESSOR_ID_PREFIX := "survivor.successor."


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

		if (
			GameManager.current_survivor != null
			and not GameManager.current_survivor.can_act()
			and GameManager.game_ui.has_method(
				"show_final_legacy_summary"
			)
		):
			GameManager.game_ui.call_deferred(
				"show_final_legacy_summary"
			)

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
			"character_id": survivor.data.character_id,
			"display_name": survivor.data.display_name,
			"is_alive": survivor.data.is_alive,
			"life_record": _serialize_life_record(
				survivor.data.life_record
			),
			"equipped_tool_instance": _serialize_item_instance(
				survivor.equipped_tool_instance
			),
			"inventory": _serialize_inventory(
				survivor.inventory
			),
			"equipment_instances": _serialize_item_instances(
				survivor.inventory.equipment_instances
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
			"equipment_instances": _serialize_item_instances(
				civilization.inventory.equipment_instances
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
			"archived_lives": _serialize_archived_lives(
				civilization.archived_lives
			),
			"next_character_sequence": civilization.next_character_sequence,
			"next_item_instance_sequence": civilization.next_item_instance_sequence,
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


func _serialize_item_instance(instance: ItemInstance) -> Dictionary:
	if instance == null or not instance.is_valid():
		return {}

	return {
		"instance_id": instance.instance_id,
		"item_id": instance.item_id,
		"material_id": instance.material_id,
		"crafted_by_id": instance.crafted_by_id,
		"crafted_by_name": instance.crafted_by_name,
		"crafted_day": instance.crafted_day,
		"crafted_hour": instance.crafted_hour,
		"crafted_minute": instance.crafted_minute,
		"component_history_known": instance.component_history_known,
		"components": _serialize_equipment_components(instance.components),
		"component_conditions": _serialize_component_conditions(
			instance.component_conditions
		),
		"legacy_current_condition": instance.legacy_current_condition,
		"legacy_maximum_condition": instance.legacy_maximum_condition,
	}


func _serialize_component_conditions(
	conditions: Array[EquipmentComponentCondition]
) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for condition: EquipmentComponentCondition in conditions:
		if condition == null or not condition.is_valid():
			continue
		serialized.append({
			"component_record_id": condition.component_record_id,
			"current_condition": condition.current_condition,
			"maximum_condition": condition.maximum_condition,
		})
	return serialized


func _serialize_equipment_components(
	components: Array[EquipmentComponentRecord]
) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for component: EquipmentComponentRecord in components:
		if component == null or not component.is_valid():
			continue
		serialized.append({
			"record_id": component.record_id,
			"component_slot": component.component_slot,
			"item_id": component.item_id,
			"material_id": component.material_id,
			"material_quality": component.material_quality,
			"amount": component.amount,
		})
	return serialized


func _serialize_item_instances(
	instances: Array[ItemInstance]
) -> Array[Dictionary]:
	var serialized: Array[Dictionary] = []
	for instance: ItemInstance in instances:
		var instance_data := _serialize_item_instance(instance)
		if not instance_data.is_empty():
			serialized.append(instance_data)
	return serialized


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


func _serialize_life_record(
	life_record: CharacterLifeRecord
) -> Dictionary:
	if life_record == null:
		return {}

	return {
		"searches_completed": life_record.searches_completed,
		"item_units_gathered": life_record.item_units_gathered,
		"crafting_actions_completed": life_record.crafting_actions_completed,
		"item_units_crafted": life_record.item_units_crafted,
		"discoveries_contributed": life_record.discoveries_contributed,
		"knowledge_earned": life_record.knowledge_earned,
		"skill_levels_gained": life_record.skill_levels_gained,
		"first_recorded_day": life_record.first_recorded_day,
		"latest_recorded_day": life_record.latest_recorded_day,
		"is_finalized": life_record.is_finalized,
		"death_day": life_record.death_day,
		"death_hour": life_record.death_hour,
		"death_minute": life_record.death_minute,
		"cause_of_death": life_record.cause_of_death,
	}


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


func _serialize_archived_lives(
	archived_lives: Array[ArchivedCharacterLife]
) -> Array[Dictionary]:
	var archive_data: Array[Dictionary] = []

	for archived_life: ArchivedCharacterLife in archived_lives:
		if archived_life == null or not archived_life.is_valid():
			continue

		archive_data.append({
			"character_id": archived_life.character_id,
			"display_name": archived_life.display_name,
			"life_record": _serialize_life_record(archived_life.life_record)
		})

	return archive_data


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

	var saved_character_id_variant: Variant = (
		survivor_data.get(
			"character_id",
			null
		)
	)

	if saved_character_id_variant is String:
		var saved_character_id := str(
			saved_character_id_variant
		)

		if not saved_character_id.is_empty():
			survivor.data.character_id = saved_character_id

	survivor.data.display_name = str(
		survivor_data.get(
			"display_name",
			survivor.data.display_name
		)
	)

	survivor.data.is_alive = bool(
		survivor_data.get(
			"is_alive",
			true
		)
	)

	_apply_life_record_data(
		survivor,
		survivor_data.get(
			"life_record",
			{}
		)
	)

	_apply_inventory_data(
		survivor.inventory,
		survivor_data.get(
			"inventory",
			{}
		)
	)
	if survivor_data.has("equipment_instances"):
		_apply_item_instances_data(
			survivor.inventory,
			survivor_data.get("equipment_instances", [])
		)

	var equipped_instance_data: Variant = survivor_data.get(
		"equipped_tool_instance",
		{}
	)
	survivor.equipped_tool_instance = _item_instance_from_data(
		equipped_instance_data
	)
	if survivor.equipped_tool_instance == null:
		var legacy_tool_id := str(survivor_data.get("equipped_tool_id", ""))
		if not legacy_tool_id.is_empty():
			survivor.equipped_tool_instance = _create_migrated_item_instance(
				legacy_tool_id
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


func _apply_life_record_data(
	survivor: Survivor,
	life_record_data: Variant
) -> void:
	var life_record := CharacterLifeRecord.new()
	survivor.data.life_record = life_record

	if life_record_data is not Dictionary:
		push_warning(
			"Skipped malformed character life-record data."
		)
		survivor.data.is_alive = true
		return

	var record_data: Dictionary = life_record_data
	life_record.searches_completed = max(
		_history_int_from_variant(
			record_data.get("searches_completed", 0),
			0
		),
		0
	)
	life_record.item_units_gathered = max(
		_history_int_from_variant(
			record_data.get("item_units_gathered", 0),
			0
		),
		0
	)
	life_record.crafting_actions_completed = max(
		_history_int_from_variant(
			record_data.get("crafting_actions_completed", 0),
			0
		),
		0
	)
	life_record.item_units_crafted = max(
		_history_int_from_variant(
			record_data.get("item_units_crafted", 0),
			0
		),
		0
	)
	life_record.discoveries_contributed = max(
		_history_int_from_variant(
			record_data.get("discoveries_contributed", 0),
			0
		),
		0
	)
	life_record.knowledge_earned = max(
		_history_int_from_variant(
			record_data.get("knowledge_earned", 0),
			0
		),
		0
	)
	life_record.skill_levels_gained = max(
		_history_int_from_variant(
			record_data.get("skill_levels_gained", 0),
			0
		),
		0
	)
	life_record.first_recorded_day = max(
		_history_int_from_variant(
			record_data.get("first_recorded_day", 0),
			0
		),
		0
	)
	life_record.latest_recorded_day = max(
		_history_int_from_variant(
			record_data.get("latest_recorded_day", 0),
			0
		),
		0
	)

	if (
		life_record.first_recorded_day > 0
		and life_record.latest_recorded_day > 0
	):
		life_record.latest_recorded_day = max(
			life_record.latest_recorded_day,
			life_record.first_recorded_day
		)

	life_record.is_finalized = bool(
		record_data.get("is_finalized", false)
	)
	life_record.death_day = clampi(
		_history_int_from_variant(record_data.get("death_day", 0), 0),
		0,
		2147483647
	)
	life_record.death_hour = clampi(
		_history_int_from_variant(record_data.get("death_hour", 0), 0),
		0,
		23
	)
	life_record.death_minute = clampi(
		_history_int_from_variant(record_data.get("death_minute", 0), 0),
		0,
		59
	)
	life_record.cause_of_death = str(
		record_data.get("cause_of_death", "")
	).strip_edges()

	if not survivor.data.is_alive:
		if (
			not life_record.is_finalized
			or life_record.death_day <= 0
			or life_record.cause_of_death.is_empty()
		):
			push_warning("Normalized malformed deceased survivor data to alive.")
			survivor.data.is_alive = true
			life_record.is_finalized = false
			life_record.death_day = 0
			life_record.death_hour = 0
			life_record.death_minute = 0
			life_record.cause_of_death = ""
	elif life_record.is_finalized:
		push_warning("Ignored finalized life record for a living survivor.")
		life_record.is_finalized = false
		life_record.death_day = 0
		life_record.death_hour = 0
		life_record.death_minute = 0
		life_record.cause_of_death = ""


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

		var item: ItemData = ItemDatabase.get_item(item_id)
		if item != null and item.uses_unique_instances():
			for _unit: int in range(amount):
				var migrated: ItemInstance = _create_migrated_item_instance(item_id)
				if migrated != null:
					inventory.add_equipment_instance(migrated)
			continue

		inventory.items[item_id] = amount


func _apply_item_instances_data(
	inventory: FrontierInventory,
	instances_data: Variant
) -> void:
	inventory.equipment_instances.clear()
	if instances_data is not Array:
		return
	for instance_data: Variant in instances_data:
		var instance: ItemInstance = _item_instance_from_data(instance_data)
		if instance != null:
			inventory.add_equipment_instance(instance)


func _item_instance_from_data(instance_data: Variant) -> ItemInstance:
	if instance_data is not Dictionary:
		return null
	var data: Dictionary = instance_data
	var instance: ItemInstance = ItemInstance.new()
	instance.instance_id = str(data.get("instance_id", ""))
	instance.item_id = str(data.get("item_id", ""))
	var item: ItemData = ItemDatabase.get_item(instance.item_id)
	if item == null or not item.uses_unique_instances() or instance.instance_id.is_empty():
		return null
	instance.material_id = str(data.get("material_id", item.material_id))
	instance.crafted_by_id = str(data.get("crafted_by_id", ""))
	instance.crafted_by_name = str(data.get("crafted_by_name", ""))
	instance.crafted_day = maxi(int(data.get("crafted_day", 1)), 1)
	instance.crafted_hour = clampi(int(data.get("crafted_hour", 0)), 0, 23)
	instance.crafted_minute = clampi(int(data.get("crafted_minute", 0)), 0, 59)
	instance.component_history_known = bool(
		data.get("component_history_known", false)
	)
	instance.components = _equipment_components_from_data(
		data.get("components", [])
	)
	if data.has("component_conditions"):
		instance.component_conditions = _component_conditions_from_data(
			data.get("component_conditions", []),
			instance
		)
		instance.legacy_current_condition = maxi(
			int(data.get(
				"legacy_current_condition",
				instance.legacy_current_condition
			)),
			0
		)
		instance.legacy_maximum_condition = maxi(
			int(data.get(
				"legacy_maximum_condition",
				instance.legacy_maximum_condition
			)),
			0
		)
	else:
		EquipmentDurabilityCalculator.initialize_condition(instance)
	return instance


func _component_conditions_from_data(
	conditions_data: Variant,
	instance: ItemInstance
) -> Array[EquipmentComponentCondition]:
	var conditions: Array[EquipmentComponentCondition] = []
	if conditions_data is not Array:
		EquipmentDurabilityCalculator.initialize_condition(instance)
		return instance.component_conditions

	for condition_data_variant: Variant in conditions_data:
		if condition_data_variant is not Dictionary:
			continue
		var condition_data: Dictionary = condition_data_variant
		var condition := EquipmentComponentCondition.new()
		condition.component_record_id = str(
			condition_data.get("component_record_id", "")
		)
		condition.maximum_condition = maxi(
			int(condition_data.get("maximum_condition", 0)),
			0
		)
		condition.current_condition = clampi(
			int(condition_data.get("current_condition", 0)),
			0,
			condition.maximum_condition
		)
		var duplicate: bool = false
		for existing: EquipmentComponentCondition in conditions:
			if existing.component_record_id == condition.component_record_id:
				duplicate = true
				break
		if condition.is_valid() and not duplicate:
			conditions.append(condition)

	if instance.component_history_known and conditions.is_empty():
		EquipmentDurabilityCalculator.initialize_condition(instance)
		return instance.component_conditions
	return conditions


func _equipment_components_from_data(
	components_data: Variant
) -> Array[EquipmentComponentRecord]:
	var components: Array[EquipmentComponentRecord] = []
	if components_data is not Array:
		return components

	for component_data_variant: Variant in components_data:
		if component_data_variant is not Dictionary:
			continue
		var component_data: Dictionary = component_data_variant
		var component: EquipmentComponentRecord = EquipmentComponentRecord.new()
		component.record_id = str(
			component_data.get(
				"record_id",
				"component." + str(components.size() + 1)
			)
		)
		component.component_slot = str(component_data.get("component_slot", ""))
		component.item_id = str(component_data.get("item_id", ""))
		var item: ItemData = ItemDatabase.get_item(component.item_id)
		if item == null or not item.is_tool_component():
			continue
		component.material_id = str(
			component_data.get("material_id", item.material_id)
		)
		component.material_quality = maxi(
			int(component_data.get("material_quality", item.material_quality)),
			0
		)
		component.amount = maxi(int(component_data.get("amount", 1)), 1)
		if component.is_valid():
			components.append(component)

	return components


func _create_migrated_item_instance(item_id: String) -> ItemInstance:
	var civilization: CivilizationData = GameManager.current_civilization
	var item: ItemData = ItemDatabase.get_item(item_id)
	if civilization == null or item == null or not item.uses_unique_instances():
		return null
	return civilization.create_item_instance(item)


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
			if civilization_data.has("equipment_instances"):
				_apply_item_instances_data(
					civilization.inventory,
					civilization_data.get("equipment_instances", [])
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
			civilization.inventory.equipment_instances = (
				survivor.inventory.equipment_instances.duplicate()
			)

			survivor.inventory.items.clear()
			survivor.inventory.equipment_instances.clear()

	civilization.display_name = str(
		civilization_data.get(
			"display_name",
			civilization.display_name
		)
	)
	civilization.next_item_instance_sequence = maxi(
		maxi(
			int(civilization_data.get("next_item_instance_sequence", 1)),
			civilization.next_item_instance_sequence
		),
		1
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

	_apply_archived_lives_data(
		civilization,
		civilization_data.get("archived_lives", []),
		civilization_data.get("next_character_sequence", 1)
	)

	civilization.synchronize_unlocked_recipes()


func _apply_archived_lives_data(
	civilization: CivilizationData,
	archived_data: Variant,
	next_sequence_data: Variant
) -> void:
	civilization.archived_lives.clear()
	civilization.next_character_sequence = maxi(
		_history_int_from_variant(next_sequence_data, 1),
		1
	)

	if archived_data is not Array:
		push_warning("Skipped malformed archived character-life data.")
		return

	for entry_variant: Variant in archived_data:
		if entry_variant is not Dictionary:
			continue

		var entry: Dictionary = entry_variant
		var character_id: String = str(entry.get("character_id", ""))
		var display_name: String = str(entry.get("display_name", ""))
		var record_variant: Variant = entry.get("life_record", {})

		if record_variant is not Dictionary:
			continue

		var life_record: CharacterLifeRecord = _deserialize_archived_life_record(record_variant)
		if life_record == null:
			continue

		civilization.archive_completed_life(
			character_id,
			display_name,
			life_record
		)

		if character_id.begins_with(SUCCESSOR_ID_PREFIX):
			var sequence: int = character_id.trim_prefix(SUCCESSOR_ID_PREFIX).to_int()
			civilization.next_character_sequence = maxi(
				civilization.next_character_sequence,
				sequence + 1
			)


func _deserialize_archived_life_record(
	record_data: Dictionary
) -> CharacterLifeRecord:
	var life_record: CharacterLifeRecord = CharacterLifeRecord.new()
	life_record.searches_completed = maxi(
		_history_int_from_variant(record_data.get("searches_completed", 0), 0), 0
	)
	life_record.item_units_gathered = maxi(
		_history_int_from_variant(record_data.get("item_units_gathered", 0), 0), 0
	)
	life_record.crafting_actions_completed = maxi(
		_history_int_from_variant(record_data.get("crafting_actions_completed", 0), 0), 0
	)
	life_record.item_units_crafted = maxi(
		_history_int_from_variant(record_data.get("item_units_crafted", 0), 0), 0
	)
	life_record.discoveries_contributed = maxi(
		_history_int_from_variant(record_data.get("discoveries_contributed", 0), 0), 0
	)
	life_record.knowledge_earned = maxi(
		_history_int_from_variant(record_data.get("knowledge_earned", 0), 0), 0
	)
	life_record.skill_levels_gained = maxi(
		_history_int_from_variant(record_data.get("skill_levels_gained", 0), 0), 0
	)
	life_record.first_recorded_day = maxi(
		_history_int_from_variant(record_data.get("first_recorded_day", 0), 0), 0
	)
	life_record.latest_recorded_day = maxi(
		_history_int_from_variant(record_data.get("latest_recorded_day", 0), 0), 0
	)
	life_record.is_finalized = bool(record_data.get("is_finalized", false))
	life_record.death_day = maxi(
		_history_int_from_variant(record_data.get("death_day", 0), 0), 0
	)
	life_record.death_hour = clampi(
		_history_int_from_variant(record_data.get("death_hour", 0), 0), 0, 23
	)
	life_record.death_minute = clampi(
		_history_int_from_variant(record_data.get("death_minute", 0), 0), 0, 59
	)
	life_record.cause_of_death = str(
		record_data.get("cause_of_death", "")
	).strip_edges()

	if (
		not life_record.is_finalized
		or life_record.death_day <= 0
		or life_record.cause_of_death.is_empty()
	):
		return null

	life_record.latest_recorded_day = maxi(
		life_record.latest_recorded_day,
		life_record.death_day
	)

	return life_record


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
