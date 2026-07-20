# Frontier Architecture

This document describes Frontier’s current technical structure, major systems, data flow, and project conventions.

---

## Project Structure

```text
res://
├── scenes/
│   ├── main.tscn
│   ├── world.tscn
│   ├── characters/
│   │   └── Survivor.tscn
│   └── ui/
│       ├── GameUI.tscn
│       └── MainMenu.tscn
│
├── scripts/
│   ├── actions/
│   ├── autoload/
│   ├── characters/
│   ├── resources/
│   └── ui/
│
├── resources/
│   ├── actions/
│   ├── characters/
│   ├── civilizations/
│   ├── discoveries/
│   ├── events/
│   ├── items/
│   ├── locations/
│   └── recipes/
│
└── docs/
```

---

## Startup Flow

Frontier launches into `MainMenu.tscn`.

The menu provides:

* New Game
* Continue
* Quit

The Main Menu stores a direct `PackedScene` reference to the gameplay entry scene.

The gameplay entry scene loads:

```text
Main
└── World
	└── UIOverlay
		└── GameUI
```

`UIOverlay` is a `CanvasLayer`, keeping the interface independent from world-space transforms.

---

## Autoloads

Frontier uses autoload singletons for systems that must be globally accessible.

Current major autoloads include:

* `GameManager`
* `ActionManager`
* `TimeManager`
* `ItemDatabase`
* `ActionDatabase`
* `LocationDatabase`
* `RecipeDatabase`
* `DiscoveryDatabase`
* `DiscoveryManager`
* `WorldEventDatabase`
* `WorldEventManager`
* `SaveManager`

### Responsibilities

#### GameManager

Owns the current game session and shared runtime references:

* current survivor;
* survivor data;
* current civilization;
* current location;
* registered Game UI.

It coordinates:

* world actions;
* travel;
* crafting;
* session initialization;
* UI refreshes.

#### ActionManager

Runs timed actions and emits progress signals.

It controls:

* active action name;
* action duration;
* progress;
* busy state;
* completion callbacks;
* game-time advancement.

#### TimeManager

Owns the current day and time.

It provides formatted time text and advances time when actions complete.

#### SaveManager

Serializes and restores persistent game state using JSON.

Saved state currently includes:

* save version;
* day and time;
* current location;
* survivor name;
* stable character ID;
* character life record;
* inventory;
* equipped tool;
* skill levels and XP;
* civilization knowledge;
* observed items;
* discoveries;
* unlocked recipes;
* civilization history entries;
* completed one-time events.

---

## Database Pattern

Frontier uses database autoloads to map stable string IDs to resource objects.

Examples:

```text
"stick" → stick.tres
"forest" → forest.tres
"search_area" → search_area.tres
```

Because exported Windows builds cannot reliably depend on runtime `DirAccess` scans of imported resources, databases currently use explicit resource-path lists.

When adding new content, the matching database path list must also be updated.

Examples:

* new item → update `ItemDatabase.gd`;
* new location → update `LocationDatabase.gd`;
* new discovery → update `DiscoveryDatabase.gd`;
* new world event → update `WorldEventDatabase.gd`;
* new recipe → update `RecipeDatabase.gd`;
* new action → update `ActionDatabase.gd`.

Stable IDs must not be renamed casually because save files reference IDs rather than display names.

---

## Resource-Driven Content

Frontier uses custom Resource classes to separate game content from gameplay code.

Current major resource types include:

* `ItemData`
* `ActionData`
* `LocationData`
* `TravelConnectionData`
* `SearchLootEntryData`
* `RecipeData`
* `IngredientData`
* `DiscoveryData`
* `WorldEventData`
* `EventOptionData`
* `SurvivorData`
* `CharacterLifeRecord`
* `CivilizationData`
* `CivilizationHistoryEntry`
* `SkillProgress`

This allows new content to be authored mostly through `.tres` files.

---

## Locations

Each `LocationData` resource contains:

* stable ID;
* display name;
* description;
* available actions;
* travel connections;
* location-specific search loot;
* empty-search weight.

Typed arrays must be preserved:

```gdscript
@export var available_actions: Array[ActionData] = []
@export var travel_connections: Array[TravelConnectionData] = []
@export var search_loot: Array[SearchLootEntryData] = []
```

Travel connections store destination IDs instead of direct `LocationData` references. This avoids circular resource dependencies.

Current locations:

* Forest
* River
* Meadow

---

## Search System

`search_area.tres` is a reusable action available in multiple locations.

`SearchAction.gd` does not own a hardcoded global loot table.

Instead, it reads:

```text
GameManager.current_location.search_loot
```

Each location defines weighted possible results through `SearchLootEntryData`.

A search entry contains:

* item;
* weight;
* minimum quantity;
* maximum quantity.

Each location also has an `empty_search_weight`.

This allows new biomes to provide different search results without creating a new search script.

---

## Inventory

Each survivor owns a `FrontierInventory` child node.

Inventory quantities are stored by stable item ID.

The UI resolves each item ID through `ItemDatabase` to display the current player-facing name.

The inventory display uses a scrolling `RichTextLabel` so additional item types do not expand or break the interface.

---

## Skills and Progression

Survivors currently have reusable `SkillProgress` resources.

Current skills:

* Gathering
* Crafting
* Exploration

Actions, travel connections, and recipes define their XP rewards through data.

This keeps progression rewards outside action implementation scripts.

---

## Crafting

Recipes are represented by `RecipeData`.

A recipe contains:

* stable ID;
* display name;
* ingredients;
* results;
* skill ID;
* XP reward;
* description.

Crafting is displayed in its own detail tab so expanding recipe information does not reduce the Chronicle area or resize the whole interface.

---

## Discoveries

Discoveries are represented by `DiscoveryData`.

A discovery can depend on:

* civilization knowledge;
* observed item IDs;
* previous discoveries;
* other configured requirements.

Discoveries may unlock recipes or future progression.

Current discovery:

* Primitive Toolmaking

---

## World Events

World events are represented by `WorldEventData`.

Events may define:

* eligible action IDs;
* eligible location IDs;
* trigger chance;
* one-time status;
* available options.

Each `EventOptionData` may provide:

* result text;
* item rewards;
* skill XP;
* knowledge;
* game-time cost.

`WorldEventManager` tracks pending events and completed one-time events.

Normal actions are disabled while an event choice is unresolved.

---

## User Interface

`GameUI.tscn` uses container-based layout rather than manual absolute positioning.

The current UI navigation contract is documented in `docs/UI_ARCHITECTURE.md`.

### Exploration Interface

The main exploration view presents five stable information areas: current location, survivor state, Expedition Pack, available actions, and travel. Actions and Travel are sibling panels that remain visible together and own independent bounded scrolling. They no longer share accordion state, so revealing one choice category cannot hide the other.

Camp access is a scene-owned contextual panel outside the action list. `GameUI.update_home_access()` shows it only when the current location matches `CivilizationData.home_location_id`, and applies the same survivor, action-busy, and pending-event gates used by other interaction entry points. Its **Enter Camp** request continues through `GameManager.enter_home()` and the existing Camp router; it does not create a second home-state authority.

The survivor panel displays the equipped tool as a concise summary and routes **Open Equipment** into the existing Equipment workspace. Equipment selection, equipping, unequipping, inspection, and maintenance are not duplicated in the exploration controller. Outside Camp, the workspace retains its established field constraints without exposing Camp navigation.

This foundation changes only scene composition and presentation orchestration. World actions, travel, timing, equipment authority, Camp routing, persistence, and save version 12 remain unchanged.

### Journal Workspace

`JournalUI.tscn` is the scene-owned presentation authority for durable and reference-oriented Journal views: History, Legacy Preview, Completed Lives, Locations, Discoveries, and Landmarks. It owns their rendering, tab visibility, completed-life selection, bounded scrolling, and Back intent.

The Chronicle remains embedded in the exploration view so immediate narration stays visible during actions and travel. `GameUI.add_event()` remains the public narration gateway used by gameplay systems and appends directly to that persistent Chronicle. Opening or closing the Journal cannot discard Chronicle text.

`JournalUI` emits requests for Back, the current Legacy Summary, and an archived-life summary. `GameUI` remains the integration boundary that routes the workspace and opens the existing modal summary. Compatibility refresh methods on `GameUI` forward older action and manager callbacks to `JournalUI.refresh()`, preserving the established public interface while presentation ownership moves out of the controller.

The Journal uses the stable `exploration.journal` workspace ID through a local `UIRouter`. Back and keyboard cancel close it and return focus to the exploration entry point. Journal refreshes query existing Resources and databases without mutating gameplay state.

The Expedition Pack presentation now sorts entries and divides them into two balanced columns beneath one scene-owned header. It continues reading the existing `FrontierInventory`; no inventory authority or persistence moved into UI code.

This extraction changes no save data. Save version remains 12.

### Camp Workspace Routing

`GameUI` owns one lightweight `UIRouter`. It is not an autoload and does not contain gameplay or persistence logic. The router coordinates only the mutually exclusive Camp workspace screens registered under stable IDs:

* `camp.overview`;
* `camp.storage`;
* `camp.crafting`.

`CampNavigation` emits destination requests without directly changing another screen. `GameUI` remains the integration boundary: it performs the relevant refresh, asks the router to open the destination, and updates the navigation state.

The router owns workspace visibility, navigation history, and each destination's initial focus target. Back buttons and keyboard cancel use the same history behavior. Closing Camp clears the routed workspace and its history.

Equipment Details, world-event choices, Legacy Summary, and Succession remain modal overlays. They are deliberately excluded from workspace history, and an active modal prevents Camp keyboard cancellation from also navigating the underlying screen.

This foundation changes no save data. Save version remains 12.

### Equipment Workspace

`EquipmentUI.tscn` is the routed presentation owner for `camp.equipment`. It builds one selection list from the current survivor's equipped instance, Expedition Pack equipment, and Camp Storage equipment. Every entry carries the stable equipment instance ID rather than a list index or display name.

`EquipmentDetailsScreen` is no longer instantiated as a top-level `GameUI` overlay. Its scene is now a container-native, internally scrolling detail pane embedded by `EquipmentUI`. It retains the proven identity, provenance, component, durability, repair, replacement, and disassembly presentation while allowing the surrounding workspace to own selection and navigation.

Repair and replacement preserve the selected instance ID. Disassembly clears the removed identity and selects the nearest remaining entry. The native disassembly `ConfirmationDialog` remains modal and reports its active state so keyboard cancel cannot navigate the underlying workspace simultaneously.

Camp Storage and HUD inspection requests route to the selected instance. When inspection begins outside Camp, the Equipment workspace opens below the persistent Header without exposing Camp navigation or granting access to Camp materials. Existing gameplay gates continue disabling repair, replacement, and disassembly away from Camp.

This milestone preserves the existing equipment mutation paths. Moving repair and replacement behind dedicated gameplay-service APIs remains a future architectural task and should not be conflated with this presentation migration.

### Storage Workspace

`StorageUI.tscn` owns the complete Pack, transfer-control, and Camp Storage layout as permanent scene nodes. `StorageUI.gd` no longer constructs controls at runtime or relies on a hidden display node as an insertion anchor.

Selection is represented by a side plus a stable token. Stackable resources use their item ID, while unique equipment uses its instance ID. Equipped equipment has its own non-transferable token. Section headers and empty-state entries contain no token and cannot become actionable selections.

Deposit and Take continue calling `FrontierInventory.transfer_item_to()` or `transfer_equipment_instance_to()`. `StorageUI` does not recreate inventory mutation rules. After a successful transfer it rebuilds both lists and restores selection on the destination side. Keep changes rebuild the Pack while restoring the same item selection.

The transfer-control column derives Quantity, Keep, Deposit, Take, and Inspect availability from the centralized selection. Equipment inspection emits the selected `ItemInstance` to `GameUI`, which routes its stable identity into the Equipment workspace.

The workspace changes no persistent state shape. Save version remains 12.

### Crafting Workspace

`CraftingUI.tscn` is the presentation owner for `camp.crafting`. It contains the recipe selector, bounded recipe-detail display, Craft control, and Back control as stable scene nodes.

`CraftingUI.gd` owns session-local recipe selection and rebuilds the visible recipe requirements from civilization knowledge and accessible inventory amounts. It emits `craft_requested(recipe_id)` and `back_requested` rather than starting actions or changing sibling visibility directly.

`GameUI` connects those signals, forwards craft intent to `GameManager.craft_recipe()`, and delegates Back behavior to `UIRouter`. `GameManager`, `ActionManager`, and `CraftAction` retain authority over eligibility, material consumption, time, XP, output placement, equipment creation, and historical recording.

The selected recipe remains presentation state for the current UI session and is not saved. This extraction changes no gameplay data or save format.

Major areas include:

```text
Header
Location
LeftColumn
├── Survivor
└── Inventory

RightColumn
├── Actions
├── Travel
└── DetailTabs
	├── Journal
	│   └── JournalTabs
	│       ├── Chronicle
	│       ├── History
	│       ├── Legacy Preview
	│       ├── Locations
	│       └── Discoveries
	└── Crafting
```

Controls that can grow indefinitely must scroll internally instead of increasing their parent container’s minimum size.

This includes:

* Inventory;
* Chronicle;
* History journal;
* Legacy Preview;
* Locations journal;
* Discoveries journal;
* future recipe lists.

Important UI controls use Godot unique names and `%NodeName` lookups so layout changes do not require rewriting long node paths.

### Chronicle and Civilization History

The Chronicle and History tabs serve different lifetimes.

The Chronicle displays immediate action narration through `GameUI.add_event()`. Chronicle messages are transient and are not included in save data.

The History tab displays durable entries stored by the current `CivilizationData`. `GameUI.update_history_journal()` rebuilds the display from those entries while preserving their insertion order.

`CivilizationHistoryEntry` is a typed Resource containing:

* stable event ID;
* title and description;
* category;
* contributor ID and display name;
* in-game day, hour, and minute.

`CivilizationData` owns the history-entry collection and is the uniqueness authority. It rejects null entries, empty event IDs, and duplicate event IDs. Actions and managers record only explicitly selected meaningful milestones after their underlying gameplay result succeeds.

The current milestones are:

* first wilderness search;
* first discovery;
* first crafted tool.

There is no separate history manager or history autoload. Routine gameplay messages do not enter durable history automatically.

### Character Life Record

`CharacterLifeRecord` is a typed Resource owned by `SurvivorData`. Each initialized survivor receives its own record rather than sharing mutable record state with another duplicated Resource.

`SurvivorData.character_id` provides stable identity independently from the mutable display name. Finnley's configured ID is `survivor.finnley`.

The life record owns focused mutation methods for:

* completed searches;
* gathered item units;
* completed crafting actions and crafted item units;
* contributed discoveries;
* earned knowledge;
* gained skill levels;
* first and latest recorded days.

Statistics update only at confirmed mutation points:

* `SearchAction` records normally completed searches and confirmed search-loot inventory additions;
* `ChopTreeAction` records confirmed wood yield added to inventory;
* `CraftAction` records one successful action and the sum of valid positive outputs after output delivery;
* `DiscoveryManager` records a contribution only after `CivilizationData.add_discovery()` accepts a new discovery;
* `Survivor.gain_knowledge()` records knowledge after civilization knowledge increases;
* `Survivor.gain_skill_xp()` records the exact level count returned by `SkillProgress.add_xp()`.

Inventory transfers, deposits, world-event item rewards, equipment ownership changes, and restored save inventory do not count as gathered units.

Historical milestone credit is not stored a second time in the life record. Legacy Preview derives it by counting `CivilizationHistoryEntry` records whose nonempty `contributor_id` matches the survivor's stable character ID. Display names remain historical presentation snapshots and are not used as an identity fallback.

`JournalUI` renders the current survivor's record in a dedicated Journal tab. UI refreshes are read-only and never mutate counters.

### Legacy Summary Screen

`LegacySummaryScreen` is a reusable full-viewport UI scene opened from the Journal's Legacy Preview. It receives the current `SurvivorData` and civilization history entries when opened; it does not own or persist gameplay state.

The screen displays:

* the character's historical display name;
* first and latest recorded days;
* a deterministic summary derived from confirmed contribution categories;
* every tracked life-record statistic;
* civilization milestones whose contributor ID matches the character's stable ID.

Milestone order follows the existing civilization-history insertion order. Name matching is not used as an identity fallback.

The summary screen is modal presentation layered over `GameUI`. It supports keyboard focus, the standard cancel action, internal scrolling, and explicit return to the game. Opening, closing, or refreshing it cannot mutate the life record or history ledger.

No separate legacy manager, autoload, or scene transition is involved. The Character Death Foundation reuses this screen in final mode rather than creating a parallel summary implementation.

### Character Death Foundation

`SurvivorData.is_alive` is the durable character lifecycle flag. `Survivor.die(cause)` is the sole gameplay gateway for death: it finalizes the owned `CharacterLifeRecord`, changes the survivor state, and emits the `died` signal.

`CharacterLifeRecord.finalize_life()` records death day, hour, minute, and cause exactly once. Finalized records reject all later contribution mutations, preserving the completed life as an immutable gameplay record.

`GameManager` receives the death signal, records immediate Chronicle narration, refreshes the UI, and opens `LegacySummaryScreen` in final mode. Its shared survivor-action gate rejects world actions, travel, and crafting for deceased characters. Equipment and home-entry paths also enforce the lifecycle state directly. The temporary debug death trigger is available only in debug builds and calls the same production death gateway.

Final Legacy Summary mode cannot be dismissed or closed with keyboard cancel. It displays the death timestamp and cause and exposes a save action so the finalized state can be persisted. Loading a deceased save reopens the final summary after the UI refreshes.

### Succession Foundation

`ArchivedCharacterLife` is a typed Resource containing a stable character ID, historical display name, and deep-duplicated finalized `CharacterLifeRecord`. `CivilizationData` owns the ordered `archived_lives` collection and rejects empty, unfinalized, or duplicate character entries.

`CivilizationData.next_character_sequence` produces stable IDs such as `survivor.successor.1`. `GameManager.get_successor_candidate()` uses that sequence to choose one deterministic authored name. Reopening the screen before succession therefore cannot reroll the candidate.

`GameManager.continue_as_successor()` is the authoritative transition gateway. It requires a deceased current survivor with a finalized Life Record, archives that life exactly once, creates a living successor with a new identity and empty Life Record, resets runtime skills, and advances the successor sequence.

The active survivor's personal inventory object, kept-item settings, and equipped-tool ID are preserved during replacement. Civilization state, current location, time, history, discoveries, knowledge, and completed world events remain untouched. This is continuity of existing belongings, not an inheritance-choice system.

`SuccessionScreen` is a modal presentation layer containing one candidate and one confirmation action. It does not own or persist the candidate. The final Legacy Summary remains open beneath it until `GameManager` confirms a successful transition; both overlays then close and the refreshed UI resumes normal play.

### Completed Lives Journal

`JournalUI` reads `CivilizationData.archived_lives` in insertion order and rebuilds a chronological, read-only Journal view. The tab remains visible when the archive is empty so the player can understand that completed lives will eventually appear there.

The selector stores stable character IDs as item metadata. Opening an entry resolves that ID against the civilization-owned archive and passes the matching `ArchivedCharacterLife` to `LegacySummaryScreen.show_archived_summary()`.

Archived-summary mode adapts the existing Legacy Summary presentation without creating a second statistics or milestone renderer. It is dismissible, does not expose succession controls, and derives credited milestones from the selected archived character's stable ID. Viewing or refreshing completed lives cannot mutate the archive, Life Records, or civilization history.

The Completed Lives Journal adds no save fields. It is a presentation consumer of the save-version-6 succession archive.

---

## Save Compatibility

The current save version is 12.

Save files store stable IDs rather than serialized resource objects.

Examples:

```json
{
  "current_location_id": "meadow",
  "equipped_tool_id": "stone_axe",
  "inventory": {
	"berry": 4,
	"herb": 2
  }
}
```

Display names may change without invalidating saves.

Stable IDs should only change alongside an intentional save migration.

Save version 3 introduced civilization history entries as ordered JSON dictionaries. Loading reconstructs typed entries through `CivilizationData.record_history_entry()` so malformed, empty, or duplicate event IDs do not enter the ledger. Saved day, hour, and minute values are converted and clamped defensively.

Save version 4 adds `character_id` and every `CharacterLifeRecord` field to survivor data. Life-record counters and days are restored directly, clamped to valid nonnegative values, and never restored through gameplay mutation methods.

Save version 5 adds survivor alive/deceased state and Character Life Record finalization fields. Death timestamps are clamped defensively. A deceased save must contain a finalized record, a positive death day, and a nonempty cause; malformed contradictory state is normalized to a living, unfinalized survivor rather than blocking the rest of the save.

Versions 1 through 4 load survivors alive and unfinalized. No prior save is interpreted as containing an unrecorded historical death.

Save version 6 adds civilization-owned archived lives and `next_character_sequence`. Archived entries are reconstructed only when they contain a stable ID, display name, and valid finalized Life Record. Malformed and duplicate entries are skipped without blocking the rest of the save. Sequence restoration is clamped above zero and advanced beyond accepted sequence-based archived IDs.

Versions 1 through 5 load with an empty completed-life archive and sequence 1. No completed life is fabricated from the currently active or deceased survivor during migration.

Versions 1 through 3 remain supported and load with a new empty life record. Earlier saves retain the configured starting survivor ID after normal new-game initialization. No character statistics are reconstructed from inventory, skills, knowledge, discoveries, search counts, or civilization history. Version 1 and 2 saves also continue to load with an empty civilization ledger.

---

## Export Requirements

Before publishing a build:

1. Run an F5 editor test.
2. Export to a new folder.
3. Launch the exported console build.
4. Confirm all database counts are nonzero.
5. Test New Game.
6. Test Continue.
7. Test search, travel, crafting, discoveries, and events.
8. Save, close, reopen, and load.
9. Zip the tested EXE and PCK together.

Expected startup database output currently includes:

```text
Loaded 7 items.
Loaded 2 actions.
Loaded 3 locations.
Loaded 1 world events.
Loaded 1 discoveries.
Loaded 1 recipes.
```

Counts must be updated as content is added.

---

## Architectural Rules

* Prefer resources over hardcoded content.
* Use stable IDs for persistent references.
* Use typed exported arrays for custom resources.
* Avoid direct circular resource references.
* Update explicit database path lists when adding resources.
* Use scrolling controls for content that can grow.
* Keep gameplay data separate from presentation text.
* Test both F5 and exported builds before WCP.
* Avoid replacing several core systems in one untested change.
* Make small changes and verify each one before continuing.

---

## Near-Term Architecture Work

Planned additions include:

* persistent visited-location tracking;
* permanent journal records;
* dynamic journal-tab visibility;
* landmark resources;
* generated narrative templates;
* character creation;
* cleaner main-menu session flow;
* developer testing tools.

## Narrative Generator

`NarrativeGenerator` is an autoload responsible for producing atmospheric search narration.

Narration currently varies by:

* survivor name;
* location ID;
* item ID;
* successful or empty result;
* quantity.

The clear mechanical reward remains separate from narrative text.

Current implementation stores phrase pools in code. Future versions should move these phrases into authored resource files.

## Discovery Sources

Discoveries may currently originate from several sources:

* observed items;
* accumulated civilization Knowledge;
* first visits to locations;
* repeated location actions;
* direct scripted unlocks.

`DiscoveryManager` remains the primary discovery-unlock coordinator for observation- and experience-driven discoveries.

Location-based discovery hooks currently exist in `GameManager`.

## Experience-Based Discoveries

`CivilizationData` stores:

```gdscript
@export var wilderness_search_count: int = 0
```

Forest and Meadow searches increment this value.

At five qualifying searches, Animal Tracks is unlocked.

The count is serialized by SaveManager and defaults to zero for older saves.

## Knowledge-Gated Actions

`GameManager.get_available_actions()` filters the current location’s ActionData collection.

Track Animals is only returned when the civilization has discovered Animal Tracks.

The current implementation uses an action-ID match.

A future ActionData field should replace this hardcoded gate.

## Dynamic Action Script Execution

Each ActionData resource contains an `action_script`.

When a timed action completes:

1. GameManager retrieves its ActionData.
2. The assigned Script resource is instantiated with `new()`.
3. The instance is checked for a `perform()` method.
4. `perform(current_survivor)` is called.
5. Standard ActionData XP rewards and UI refreshes are handled by GameManager.

Action implementations should return a Boolean success value.

Action scripts should not independently award the ActionData skill XP unless explicitly designed to provide an additional reward.

---

## Unique Equipment Instances

`ItemInstance` is the durable identity layer for completed equipment. It stores a stable instance ID, its base `ItemData` ID, material ID, maker identity snapshot, and crafting timestamp. The base `ItemData` remains the authority for tags and tool performance.

`FrontierInventory` uses a hybrid model:

* `items` continues to store fungible resources and components as ID-to-count stacks;
* `equipment_instances` stores completed tools as individual `ItemInstance` resources.

An equipped tool is held by `Survivor.equipped_tool_instance` rather than duplicated inside an inventory. Equipping removes the selected instance from an accessible inventory, while unequipping returns that same object to the survivor's personal inventory. Tool requirements and actions resolve the instance's base `ItemData`, preserving existing tag-based behavior.

`CivilizationData` owns the monotonic item-instance sequence and creates new crafted instances. `CraftAction` creates one instance per non-stackable tool output and records material, crafter, and time provenance. Stackable results continue through the existing count-based inventory path.

Succession transfers the existing personal inventory and equipped instance to the successor. This is continuity of belongings, not a player-directed inheritance system.

Save version 7 serializes personal and civilization equipment-instance collections, the equipped instance, and the next instance sequence. Versions 1 through 6 remain accepted. Generic legacy tool counts are converted into distinct instances, and a legacy equipped-tool ID becomes one separate equipped instance without duplicating an inventory item.

The current instance foundation deliberately excludes durability, quality, custom naming, engraving, repairs, component replacement, disassembly, and complete component history.

---

## Equipment Component History

`EquipmentComponentRecord` is an immutable construction snapshot stored by `ItemInstance`. Each record contains the component slot, source item ID, material ID, material quality, and consumed quantity. `ItemInstance.component_history_known` distinguishes a known empty history from unavailable legacy data.

`GameManager.consume_recipe_ingredients_from_accessible_inventories()` remains the authoritative ingredient-removal path. Alongside the existing material-variant selection dictionary, it records every meaningful component actually removed. This includes fixed recipe ingredients such as handles and bindings as well as interchangeable slot ingredients such as axe heads.

`CraftAction` passes the completed record collection into `CivilizationData.create_item_instance()`. Each output instance receives deep-copied records, preventing one tool's future mutations from changing another tool assembled in the same crafting action.

`EquipmentDetailsScreen` is a read-only presentation layer. `GameUI` resolves the selected accessible instance through `Survivor`, allowing equipped, personally carried, and locally stored equipment to be inspected without transferring or mutating it.

Save version 8 serializes component-history availability and each validated component record. Versions 1 through 7 remain accepted with `component_history_known` set to false. Migration does not infer components from a finished tool's material or recipe because doing so would create fictional history.

---

## Component-Derived Tool Efficiency

`EquipmentStatCalculator` is a stateless authority for equipment values derived from an `ItemInstance`. It does not cache or persist results.

For current axes, the calculator locates the valid `head` component and returns at least 1 efficiency from its recorded `material_quality`. Stone quality 1 therefore remains efficiency 1, while Flint quality 2 remains efficiency 2.

If component history is unavailable or no valid head record exists, the calculator falls back to the base `ItemData.tool_efficiency`. This preserves migrated equipment behavior without inventing components.

`ChopTreeAction` supplies the equipped instance to the calculator, then applies the existing Gathering and Strength bonuses after the derived base yield. `EquipmentDetailsScreen` uses the same calculator and identifies the source component, ensuring gameplay and presentation cannot disagree.

Because the value is derived exclusively from already-persisted version 8 data, this milestone does not change the save format. Durability, handle and binding effects, repairs, replacement, and disassembly remain outside its scope.

---

## Equipment Durability

`EquipmentComponentCondition` is mutable state linked to an immutable `EquipmentComponentRecord` through a stable local record ID. It stores current and maximum condition without changing the component's historical item, material, quality, or quantity.

`EquipmentDurabilityCalculator` centralizes initialization, maximum-condition formulas, wear, critical-slot failure, usability, and overall-condition percentage. Current maximum condition uses slot bases of 20 for heads, 30 for handles, and 10 for bindings, plus 10 per material-quality point.

`CivilizationData.create_item_instance()` assigns deterministic local component IDs, deep-copies the construction records, and initializes full condition. `ChopTreeAction` checks usability defensively, awards a valid action's results, then applies one wear to the head and binding. A component reaching zero on that use blocks subsequent actions rather than canceling the completed action.

`ActionData.is_tool_requirement_met()` rejects unusable equipped instances before tool-required actions begin. `EquipmentDetailsScreen` derives overall condition and presents exact current/maximum values and failure state without mutating equipment.

Save version 9 serializes component record IDs, component conditions, and legacy fallback condition. Version 8 component-aware tools receive deterministic record IDs and full starting condition. Versions 1 through 7 retain unavailable component history and use a tool-level fallback derived from base efficiency; migration never creates fictional parts.

Replacement, disassembly, recovered materials, permanent destruction, random breakage, and handle wear remain outside this milestone.

---

## Equipment Maintenance

`EquipmentDurabilityCalculator` remains the authority for repair eligibility, matching repair-item resolution, and condition restoration. `EquipmentComponentCondition.repair_to_maximum()` performs the bounded mutation without changing its associated immutable component record.

`GameManager.consume_accessible_item()` verifies the complete cost before removing it across the established Camp Storage and carried-inventory order. Maintenance is gated to the active Camp interface, preventing field repairs while reusing existing accessible-inventory rules.

`EquipmentDetailsScreen` orchestrates the selected repair and records mutable maintenance facts on the same `ItemInstance`: repair count, last-maintained day, and maintainer identity snapshot. `StorageUI` exposes inspection for carried, stored, and equipped instances; `GameUI` owns the shared details overlay and refreshes storage after successful repair.

The Equipment Details panel uses a viewport-bounded outer layout. Equipment information and maintenance controls scroll together, while the Return control remains outside the scroll region.

Save version 10 serializes maintenance fields alongside existing condition data. Versions 1 through 9 remain accepted with zero repairs and no fabricated maintainer. Component replacement, disassembly, recovery, repair time, skill outcomes, and a dedicated Tool Bench remain outside this foundation.

---

## Equipment Component Replacement

`EquipmentComponentReplacementService` is the gameplay authority for replacement eligibility, recovery truth, result previews, active-component mutation, fresh condition creation, and replacement-history recording. It accepts only registered `ItemData` components whose slot matches the selected active component.

Each `ItemInstance` owns a monotonic `next_component_record_sequence` and an ordered collection of typed `EquipmentComponentReplacementRecord` resources. Installed components receive a new record ID that is never reused. Replacement records deep-copy the removed and installed component snapshots and retain removal condition, time, actor identity, and recovery outcome.

The active `components` and `component_conditions` arrays describe the tool now. Replacement history describes how it reached that state. Original instance identity, maker, and crafting time remain unchanged.

`RecipeDatabase.get_assembly_recipe_for_item()` finds the assembly recipe that owns either the default or variant result. The replacement service feeds the current component selection back through `RecipeData.get_results_for_components()`, so Stone and Flint result changes remain data-driven rather than hardcoded in the UI.

Replacement consumes one compatible component through the existing atomic accessible-inventory helper. A removed component returns to Camp Storage only when its condition was full; damaged and failed components cannot truthfully enter a pristine stack. The newly installed component begins at its derived maximum condition.

Save version 11 serializes replacement records and the next component sequence. Versions 1 through 10 load with an empty replacement history and derive the next safe sequence from active component IDs. No earlier replacements are fabricated.

General disassembly, damaged-component recovery, partial recovery, removal failure, replacement time, skill outcomes, NPC replacement, and a dedicated Tool Bench remain outside this foundation.

---

## Equipment Disassembly

`EquipmentDisassemblyService` builds a complete immutable snapshot before any inventory mutation. The typed `EquipmentDisassemblyRecord` preserves the instance identity, final result, origin, active components and conditions, replacement history, maintenance count, recovered item IDs, time, and responsible character.

`CivilizationData` owns the ordered disassembly archive and rejects invalid or duplicate instance IDs. `GameManager.disassemble_equipment()` is the atomic orchestration boundary: it verifies Camp access, rejects the equipped instance, locates the exact owning inventory, builds the record, removes the instance, records the archive, grants truthful recovery to Camp Storage, and writes a unique civilization History entry.

If archive insertion fails, the removed instance returns to its original inventory before any recovery is granted. All remaining additions are non-failing in-memory operations after complete validation.

`EquipmentDetailsScreen` presents recovery and loss before opening a confirmation dialog. Successful disassembly closes the now-invalid details view, returns focus to Camp Storage, and signals `GameUI` to refresh storage and the Journal.

Save version 12 serializes civilization-owned disassembly records in insertion order, including their nested component, condition, and replacement snapshots. Versions 1 through 11 remain accepted with an empty archive. Malformed and duplicate records are skipped without fabricating history or recovery.

Partial recovery, salvage percentages, damaged-component instances, disassembly time, skill checks, NPC automation, building disassembly, and a dedicated Tool Bench remain outside this foundation.

---

## Complete Component-Derived Equipment Stats

`EquipmentStatCalculator` remains stateless and is the single authority for head efficiency, handle handling, binding stability, weakest-component overall quality, and real action duration. Active component records are the only inputs; none of these values are cached or serialized.

Component quality ratings normalize the stored material quality by adding one, allowing current primitive handle and binding components to provide baseline rating 1. Overall quality is the lowest valid active-component rating.

Handling reduces real duration by 10 percent per rating, capped at 25 percent. `GameManager.start_world_action()` applies that duration only to actions requiring an axe, then passes the original `game_minutes` unchanged to `ActionManager`. The current Chop Tree action therefore completes in 4.5 real seconds while still advancing 120 simulated minutes.

`EquipmentDetailsScreen` uses the same calculator to identify each contributing component, display actual duration, and preview replacement outcomes. Unknown component history falls back to base item efficiency and unmodified duration without invented handling, stability, or overall quality.

Save version remains 12 because every added value derives from existing persisted component records. Simulated-time reduction, random craftsmanship, wear probability, persistent use counters, maker bonuses, combat statistics, and new component materials remain outside this milestone.
