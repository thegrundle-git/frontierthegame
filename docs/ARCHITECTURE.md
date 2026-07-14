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
* inventory;
* equipped tool;
* skill levels and XP;
* civilization knowledge;
* observed items;
* discoveries;
* unlocked recipes;
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
* `CivilizationData`
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
	│       ├── Locations
	│       └── Discoveries
	└── Crafting
```

Controls that can grow indefinitely must scroll internally instead of increasing their parent container’s minimum size.

This includes:

* Inventory;
* Chronicle;
* Locations journal;
* Discoveries journal;
* future recipe lists.

Important UI controls use Godot unique names and `%NodeName` lookups so layout changes do not require rewriting long node paths.

---

## Save Compatibility

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
