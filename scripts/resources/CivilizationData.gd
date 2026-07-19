extends Resource
class_name CivilizationData


const HISTORY_FIRST_SEARCH := "milestone.first_search"
const HISTORY_FIRST_DISCOVERY := "milestone.first_discovery"
const HISTORY_FIRST_CRAFTED_TOOL := "milestone.first_crafted_tool"


@export var display_name: String = "Unnamed Civilization"
@export var home_location_id: String = "forest"

@export var visited_location_ids: Array[String] = []
@export var discovered_landmark_ids: Array[String] = []
@export var wilderness_search_count: int = 0


var knowledge: int = 0

var inventory: FrontierInventory = FrontierInventory.new()

var observed_item_ids: Array[String] = []
var discovered_ids: Array[String] = []
var unlocked_recipe_ids: Array[String] = []
var history_entries: Array[CivilizationHistoryEntry] = []
var archived_lives: Array[ArchivedCharacterLife] = []
var equipment_disassembly_records: Array[EquipmentDisassemblyRecord] = []
var next_character_sequence: int = 1
var next_item_instance_sequence: int = 1


func record_equipment_disassembly(record: EquipmentDisassemblyRecord) -> bool:
	if record == null or not record.is_valid():
		return false
	for existing: EquipmentDisassemblyRecord in equipment_disassembly_records:
		if existing != null and existing.instance_id == record.instance_id:
			return false
	equipment_disassembly_records.append(record)
	return true


func create_item_instance(
	item: ItemData,
	crafted_by_id: String = "",
	crafted_by_name: String = "",
	components: Array[EquipmentComponentRecord] = [],
	component_history_known: bool = false
) -> ItemInstance:
	if item == null or not item.uses_unique_instances():
		return null

	var instance: ItemInstance = ItemInstance.new()
	instance.instance_id = "item.instance." + str(maxi(next_item_instance_sequence, 1))
	next_item_instance_sequence = maxi(next_item_instance_sequence, 1) + 1
	instance.item_id = item.id
	instance.material_id = item.material_id
	instance.crafted_by_id = crafted_by_id
	instance.crafted_by_name = crafted_by_name
	instance.crafted_day = maxi(TimeManager.day, 1)
	instance.crafted_hour = clampi(TimeManager.hour, 0, 23)
	instance.crafted_minute = clampi(TimeManager.minute, 0, 59)
	instance.component_history_known = component_history_known
	for component: EquipmentComponentRecord in components:
		if component != null and component.is_valid():
			var stored_component := component.duplicate(true) as EquipmentComponentRecord
			stored_component.record_id = "component." + str(instance.components.size() + 1)
			instance.components.append(stored_component)
	instance.next_component_record_sequence = instance.components.size() + 1
	EquipmentDurabilityCalculator.initialize_condition(instance)
	return instance


func has_archived_character(character_id: String) -> bool:
	if character_id.is_empty():
		return false

	for archived_life: ArchivedCharacterLife in archived_lives:
		if archived_life != null and archived_life.character_id == character_id:
			return true

	return false


func archive_completed_life(
	character_id: String,
	display_name: String,
	life_record: CharacterLifeRecord
) -> bool:
	if (
		character_id.is_empty()
		or display_name.is_empty()
		or life_record == null
		or not life_record.is_finalized
		or has_archived_character(character_id)
	):
		return false

	var archived_life: ArchivedCharacterLife = ArchivedCharacterLife.new()
	archived_life.character_id = character_id
	archived_life.display_name = display_name
	archived_life.life_record = life_record.duplicate(true) as CharacterLifeRecord
	archived_lives.append(archived_life)

	return true


func get_next_successor_id() -> String:
	return "survivor.successor." + str(maxi(next_character_sequence, 1))


func advance_character_sequence() -> void:
	next_character_sequence = maxi(next_character_sequence, 1) + 1


func has_history_event(
	event_id: String
) -> bool:
	if event_id.is_empty():
		return false

	for entry: CivilizationHistoryEntry in history_entries:
		if entry != null and entry.event_id == event_id:
			return true

	return false


func record_history_entry(
	entry: CivilizationHistoryEntry
) -> bool:
	if entry == null:
		return false

	if entry.event_id.is_empty():
		return false

	if has_history_event(entry.event_id):
		return false

	history_entries.append(entry)

	return true


func record_history_event(
	event_id: String,
	title: String,
	description: String,
	category: String,
	contributor_id: String,
	contributor_name: String,
	day: int,
	hour: int,
	minute: int
) -> bool:
	var entry := CivilizationHistoryEntry.new()
	entry.event_id = event_id
	entry.title = title
	entry.description = description
	entry.category = category
	entry.contributor_id = contributor_id
	entry.contributor_name = contributor_name
	entry.day = day
	entry.hour = hour
	entry.minute = minute

	return record_history_entry(entry)


func observe_item(
	item_id: String
) -> bool:
	if item_id.is_empty():
		return false

	if item_id in observed_item_ids:
		return false

	observed_item_ids.append(item_id)

	print(
		"New observation: ",
		item_id
	)

	return true


func has_observed_item(
	item_id: String
) -> bool:
	return item_id in observed_item_ids


func has_observed_all(
	item_ids: Array[String]
) -> bool:
	for item_id: String in item_ids:
		if not has_observed_item(item_id):
			return false

	return true


func has_discovery(
	discovery_id: String
) -> bool:
	return discovery_id in discovered_ids


func add_discovery(
	discovery: DiscoveryData
) -> bool:
	if discovery == null:
		return false

	if has_discovery(discovery.id):
		return false

	discovered_ids.append(discovery.id)

	for recipe: RecipeData in discovery.unlocked_recipes:
		if recipe == null:
			continue

		if recipe.id not in unlocked_recipe_ids:
			unlocked_recipe_ids.append(recipe.id)

	return true


func has_recipe(
	recipe_id: String
) -> bool:
	return recipe_id in unlocked_recipe_ids


func record_wilderness_search() -> int:
	wilderness_search_count += 1

	return wilderness_search_count


func has_visited_location(
	location_id: String
) -> bool:
	return location_id in visited_location_ids


func record_location_visit(
	location_id: String
) -> bool:
	if location_id.is_empty():
		return false

	if has_visited_location(location_id):
		return false

	visited_location_ids.append(location_id)

	return true


func has_discovered_landmark(
	landmark_id: String
) -> bool:
	return landmark_id in discovered_landmark_ids


func record_landmark_discovery(
	landmark_id: String
) -> bool:
	if landmark_id.is_empty():
		return false

	if has_discovered_landmark(landmark_id):
		return false

	discovered_landmark_ids.append(
		landmark_id
	)

	return true

func synchronize_unlocked_recipes() -> void:
	for discovery_id: String in discovered_ids:
		var discovery: DiscoveryData = (
			DiscoveryDatabase.get_discovery(
				discovery_id
			)
		)

		if discovery == null:
			continue

		for recipe: RecipeData in discovery.unlocked_recipes:
			if recipe == null:
				continue

			if recipe.id not in unlocked_recipe_ids:
				unlocked_recipe_ids.append(
					recipe.id
				)
