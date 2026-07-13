# Frontier Architecture

Frontier is a text-driven survival and civilization-building game built in Godot.

The project uses data-driven resources and separate gameplay systems so new content can be added without rewriting core logic.

## Core Runtime Flow

```text
Game starts
→ GameManager creates the current civilization
→ GameManager creates the current survivor
→ GameUI connects to global managers
→ Player begins an action
→ ActionManager tracks its duration
→ TimeManager advances game time
→ The action resolves
→ Inventory, skills, observations, and discoveries update
→ GameUI refreshes
```

## Global Managers

### GameManager

Owns the current game session.

Responsibilities:

* Creates the current survivor
* Loads the current civilization
* Starts player actions
* Coordinates gameplay systems
* Provides access to the current survivor and civilization

### ActionManager

Runs one timed action at a time.

Responsibilities:

* Tracks the current action
* Tracks real-time progress
* Prevents conflicting actions
* Calls the action completion callback
* Signals the UI when actions start, progress, and finish

### TimeManager

Tracks in-game time.

Responsibilities:

* Stores day, hour, and minute
* Advances time when actions finish
* Emits a signal when time changes

### ItemDatabase

Loads all ItemData resources from the items folder.

Responsibilities:

* Registers items by stable ID
* Provides item information to gameplay and UI systems
* Prevents duplicate item IDs

### RecipeDatabase

Loads all RecipeData resources from the recipes folder.

Responsibilities:

* Registers recipes by stable ID
* Provides recipe information to crafting systems
* Prevents duplicate recipe IDs

### DiscoveryDatabase

Loads all DiscoveryData resources from the discoveries folder.

Responsibilities:

* Stores all possible discoveries
* Provides discoveries to DiscoveryManager

### DiscoveryManager

Handles observations and civilization breakthroughs.

Responsibilities:

* Records newly observed items
* Checks discovery requirements
* Unlocks discoveries
* Unlocks recipes
* Reports discoveries to the event log

## Game State

### Survivor

Represents the active individual.

Owns:

* SurvivorData
* Personal inventory
* Gathering skill
* Equipped tool
* Personal statistics

### CivilizationData

Represents knowledge shared by a group.

Owns:

* Insight or knowledge
* Observed item IDs
* Discovered technology IDs
* Unlocked recipe IDs

Civilization knowledge persists independently of individual survivor skill.

### FrontierInventory

Stores item IDs and quantities.

Responsibilities:

* Adds and removes items
* Checks recipe affordability
* Removes recipe ingredients
* Adds recipe results

The inventory stores stable item IDs rather than display names.

## Data Resources

### ItemData

Defines an item.

Examples:

* Stick
* Stone
* Wild Berry
* Wood Log
* Stone Axe

### IngredientData

Defines an item and quantity used by a recipe.

### RecipeData

Defines crafting inputs, outputs, duration, and description.

### DiscoveryData

Defines the requirements and rewards of a civilization discovery.

### SurvivorData

Defines persistent survivor statistics and identity.

### CivilizationData

Defines persistent civilization progress.

## Actions

Actions contain the gameplay result of completed work.

Examples:

* SearchAction
* CraftAction
* ChopTreeAction

Actions should not manage their own timers. GameManager sends timed work to ActionManager, and the action resolves only after completion.

## UI Rules

GameUI displays game state but should not decide gameplay results.

The UI may:

* Request an action
* Display inventory
* Display skills
* Display time and action progress
* Display the event log

The UI should not:

* Award items
* Decide search results
* Unlock discoveries
* Remove crafting ingredients

## Development Workflow

```text
Design
→ Build
→ Test
→ Working
→ Commit
→ Push
```

Internal shorthand:

```text
WCP
```

WCP means:

* Working
* Committed
* Pushed

Each stable milestone should be committed before beginning the next major system.
