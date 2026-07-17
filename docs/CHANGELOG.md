# Frontier Changelog

This document records every released version of Frontier.
---
## v0.5.3-alpha1 — Modular Crafting Foundation

### Added

* Modular tool-component metadata for item resources.
* Stone Axe Head component.
* Stick Handle component.
* Fiber Binding component.
* Separate recipes for crafting all three components.
* Multi-recipe crafting selector.
* Combined home crafting access across Finnley’s Pack and Camp Storage.
* Backward-compatible recipe synchronization for existing discoveries.
* Equipped-tool ownership normalization for older saves.

### Changed

* Stone Axe crafting now requires a crafted head, handle, and binding.
* Crafting at home consumes Camp Storage materials first, then carried materials.
* Crafting outputs go to Camp Storage at home and Finnley’s Pack away from home.
* Equipped tools are removed from inventories while equipped.
* Primitive Toolmaking now unlocks four component and assembly recipes.
* Home, Storage, and Crafting now preserve the shared HUD.
* Crafting progress, game time, Save, and Load remain visible inside Camp interfaces.
* Camp access is tracked separately from merely being in the Forest.

### Fixed

* Players being forced to deposit carried materials before crafting at home.
* Equipped tools simultaneously appearing in Camp Storage.
* Older saves failing to receive recipes added to existing discoveries.
* Camp interface being shifted left and exposing the world interface on the right.
* Camp overlays shifting the entire game downward and cutting off lower tabs.
* Crafting hiding action progress, game time, Save, and Load controls.
* Forest field crafting incorrectly having access to Camp Storage.

---

## v0.5.2-alpha2 — Expedition Inventory Transfers

### Added

* Two-sided inventory interface for Finnley’s Pack and Camp Storage.
* Manual item transfers in either direction.
* Transfer quantity selection.
* Deposit All action.
* Keep protection for carried item stacks.
* Save/load persistence for Keep selections.

### Changed

* Wilderness search rewards now enter the survivor’s expedition inventory.
* Tree-chopping rewards now enter the survivor’s expedition inventory.
* Resources must be returned home and deposited before they can be used for crafting.

### Fixed

* Gathered resources instantly appearing in civilization storage without being carried home.

---

## v0.5.2-alpha1 — Physical Progression Foundation

### Added

* Trainable Strength skill.
* Strength XP rewards from chopping trees.
* Strength-based carry-weight capacity calculation.
* Data-driven civilization home-location field.

### Changed

* Strength Level 10 adds an additional Wood Log to tree-chopping yield.
* Return Home is only available at the civilization’s home location.
* Existing save logic automatically preserves Strength progression.

### Fixed

* Return Home allowing instant access to camp from the River or Meadow.

---

## v0.5.1-alpha3 — Location-Gated Discoveries

### Added

* Data-driven location requirements for discoveries.
* River visit requirement for the Fresh Water discovery.

### Changed

* Location-based discoveries are now evaluated by the generic discovery system.
* Travel records the destination visit before checking discovery requirements.

### Fixed

* Fresh Water incorrectly unlocking while searching in the Forest or Meadow.
* Competing hardcoded and generic Fresh Water unlock paths.

---

## v0.5.1-alpha2 — Civilization Storage Foundation

### Added

* Civilization-owned inventory for shared camp resources.
* Dedicated Camp Storage display.
* Save version 2 support for civilization inventory data.
* Automatic migration of version 1 survivor inventory into Camp Storage.

### Changed

* Wilderness search rewards now enter Camp Storage.
* Wood gathered from tree chopping now enters Camp Storage.
* Crafting materials are consumed from Camp Storage.
* Crafted items are deposited into Camp Storage.
* Survivors can equip tools owned by their civilization.
* Inventory is now a lightweight data object usable by survivors and civilizations.

### Fixed

* Camp Storage displaying the survivor’s personal inventory.
* Civilization resources being lost after saving and loading.

---

## v0.5.1-alpha1 — Age of Discovery

### Added

* Narrative Generator v1 for location- and item-specific search narration.
* Wild Flora discovery.
* Fresh Water discovery.
* Animal Tracks discovery.
* Persistent wilderness search-count tracking.
* Experience-based discovery conditions.
* First knowledge-gated action: Track Animals.
* Track Animals narrative outcomes.
* Knowledge rewards from successful tracking.
* Discovery database lookup support.
* Permanent Discoveries Journal population.

### Changed

* Search results now include atmospheric narrative while retaining clear item reward messages.
* Discovery progression now supports item observation, location visits, and repeated actions.
* Available world actions are filtered by civilization knowledge.
* Action completion scripts are instantiated dynamically from each ActionData resource.
* Newly unlocked discoveries can immediately rebuild available action controls.
* The interface now expands as new knowledge unlocks new possibilities.

### Fixed

* Primitive Toolmaking failing to appear in the Discoveries Journal.
* Discovery resources being unavailable through direct ID lookup.
* Track Animals appearing before Animal Tracks was discovered.
* Action scripts being called directly as static scripts.
* Nil results being assigned to typed Boolean variables during action completion.
* Incorrectly indented discovery-journal function being parsed as a standalone lambda.

---
##v0.5.0-alpha3 — Living World Foundation

###Added

Persistent visited-location tracking.
One-time first-visit narration for locations.
Permanent location records in the Journal.
LandmarkData resource type.
Export-safe LandmarkDatabase.
Persistent landmark discovery tracking.
Hidden Landmarks Journal tab.
First landmark: Abandoned Campsite.
World-event-to-landmark linking.
Save and load support for visited locations and discovered landmarks.
Changed
The Journal now records locations the player has visited.
First-visit narration is stored in each LocationData resource.
Journal tabs can appear dynamically as new categories of knowledge are unlocked.
The Abandoned Campsite world event now records a permanent landmark.
Startup messages may be queued until the gameplay UI becomes available.
Fixed
Landmarks failing to populate after their associated event triggered.
Landmarks tab remaining hidden after discovering a landmark.
Duplicate helper functions introduced during landmark debugging.
Landmark resources failing to retain their linked event ID.
Null access during early Journal refreshes.
Journal tab lookup and refresh-order issues.

## v0.5.0-alpha2 — Exploration Foundation

### Added
- Meadow biome
- Wild Herb resource
- Wild Flower resource
- SearchLootEntryData resource
- Journal tabs (Chronicle, Locations, Discoveries)
- Dedicated Crafting tab

### Changed
- Search loot is now location-specific.
- Inventory now scrolls instead of resizing the interface.
- Crafting now lives in the Detail Tabs.
- Journal is now organized into tabs.

### Fixed
- Inventory UI expansion.
- Journal UI expansion.
- Crafting UI expansion.
- Various layout scaling issues.
