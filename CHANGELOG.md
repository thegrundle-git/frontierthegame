## v0.4.0 — World Events and Choices

### Added

* Data-driven world event resources
* Data-driven event choices
* Event item rewards
* Event skill XP rewards
* Event Insight rewards
* Event time costs
* One-time event tracking
* Event choice overlay
* Abandoned Campsite event

### Changed

* World actions can now trigger location-specific events
* Normal actions are locked while a decision is pending
* The Journal now records major world events and outcomes

### Notes

This version introduces meaningful decisions and begins shifting Frontier from a repeated-action prototype toward an emergent survival narrative.

## v0.3.1 — Universal Progression

### Added

* Reusable SkillProgress system
* Gathering skill progression
* Crafting skill progression
* Exploration skill progression
* Data-driven XP rewards for world actions
* Data-driven XP rewards for travel
* Data-driven XP rewards for recipes
* Multi-skill interface
* Visible XP reward messages
* Generic skill level-up messages

### Changed

* Search XP is now defined by ActionData
* Tree Chopping XP is now defined by ActionData
* Travel now grants Exploration XP
* Crafting now grants Crafting XP
* Gathering yield bonuses now use the reusable skill system
* Completed actions always provide meaningful progression

### Notes

This version strengthens the progression loop by ensuring every completed action advances at least one survivor skill.

## v0.1.9 — Data-Driven Actions and First Location

### Added

- ActionData resources
- ActionDatabase
- LocationData resources
- LocationDatabase
- Forest starting location
- Current location display
- Dynamically generated world-action buttons
- Tool requirements defined through action data

### Changed

- Search Area converted from a hardcoded button to ActionData
- Chop Tree converted from a hardcoded button to ActionData
- GameManager now runs generic world actions
- Locations now define which world actions are available
- GameUI now generates world-action buttons automatically

### Notes

This version establishes the foundation for multiple locations, biome-specific activities, and future travel.# Frontier Changelog

All notable changes to Frontier are documented in this file.

---

## v0.1.8 — Architecture Cleanup

### Added

* Project architecture documentation.
* Duplicate game-start protection.
* Additional validation for core systems.
* Shared helper functions for common GameManager operations.

### Changed

* Standardized code formatting and typing.
* Removed temporary debugging output.
* Improved overall project organization and maintainability.

---

## v0.1.7 — Tools & Tree Chopping

### Added

* Equipped tool system.
* Automatic equipping of the first crafted tool.
* Stone Axe tool display.
* Timed Tree Chopping action.
* Wood Log gathering.
* Gathering level bonus for wood yield.
* Tree chopping unlocked by equipped tools.

### Changed

* Actions now unlock based on equipment instead of being permanently available.

---

## v0.1.6 — Universal Timed Actions

### Added

* TimeManager.
* ActionManager.
* In-game clock.
* Day tracking.
* Action progress bar.
* Current action display.
* Busy state management.

### Changed

* Searching now requires time.
* Crafting now requires time.
* Actions advance in-game time instead of resolving instantly.
* UI updates while actions are in progress.

---

## v0.1.5 — First Crafting & Discovery Loop

### Added

* Recipe database.
* Generic crafting system.
* Civilization observations.
* Discovery requirements.
* Primitive Toolmaking discovery.
* Recipe unlocking.
* Stone Axe crafting.
* Crafting interface.

### Changed

* Crafting became fully data-driven.
* Discoveries now unlock recipes automatically.

---

## v0.1.4 — Civilization Discoveries

### Added

* DiscoveryManager.
* Civilization knowledge tracking.
* Observation system.
* Primitive Toolmaking discovery.
* Recipe unlock framework.

### Changed

* Knowledge moved from the survivor to the civilization.
* Technology became civilization-wide rather than character-specific.

---

## v0.1.3 — Recipe Framework

### Added

* RecipeData resources.
* IngredientData resources.
* Stone Axe item.
* Stone Axe recipe.

### Changed

* Recipes became data-driven resources instead of hardcoded crafting logic.

---

## v0.1.2 — Progression Interface

### Added

* Gathering Level display.
* Gathering XP display.
* Automatic UI refresh after gameplay actions.

### Changed

* Inventory and survivor information now refresh immediately after actions.
* Improved presentation of player progression.

---

## v0.1.1 — Search Tables

### Added

* Randomized search outcomes.
* Stone resource.
* Wild Berry resource.
* Expanded ItemDatabase.
* Data-driven search rewards.

### Changed

* Searching now produces varied results instead of always returning a Stick.

---

## v0.1.0 — Prototype

### Added

* Project structure.
* Survivor system.
* Inventory system.
* ItemData resources.
* Stick item.
* Search action.
* Event log.
* Gathering skill.
* Gathering XP.
* Gathering level progression.
* Hidden knowledge system.
* GitHub repository.
* Windows export support.

### Notes

This version established the core architecture of Frontier and produced the first playable prototype.
