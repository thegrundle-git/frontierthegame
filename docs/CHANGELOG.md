# Frontier Changelog

This document records every released version of Frontier.
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
