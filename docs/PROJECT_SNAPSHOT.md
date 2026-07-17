# Frontier Project Snapshot

## Current Version

v0.5.6-alpha1

## Project Health

🟢 Stable — Core Windows export regression and Character Life Record gameplay and save/load testing passed

## Current Milestone

Vertical Slice

## Current Sprint

Sprint 3 — The Age of Discovery

## Content

* Locations: 3
* Items: 10
* Recipes: 4
* Discoveries: 4
* World Events: 1
* Landmarks: 1
* Registered World Actions: 3
* External Testers: approximately 5

## Current Discoveries

* Primitive Toolmaking
* Wild Flora
* Fresh Water
* Animal Tracks

## Current Locations

* Forest
* River
* Meadow

## Current Landmark

* Abandoned Campsite

## Implemented Systems

* Main Menu
* New Game and Continue
* Save and Load
* Game Time
* Timed Actions
* Skills and XP
* Knowledge
* Inventory
* Travel
* Crafting
* Discoveries
* Discoveries Journal
* World Events
* Landmarks
* Location-specific search loot
* Visited-location tracking
* First-visit narration
* Narrative Generator v1
* Experience-based discoveries
* Knowledge-gated actions
* Track Animals v1
* Civilization-owned Camp Storage
* Location-gated discoveries
* Trainable Strength progression
* Data-driven civilization home location
* Modular component crafting
* Multi-recipe crafting interface
* Combined Pack and Camp crafting access
* Exclusive equipped-tool ownership
* Material-ranked interchangeable components
* Material-dependent finished tools
* Flint resource, component, and axe progression
* Basic manual equipment controls
* Tag-based tool requirements
* Rebalanced Skills, Inventory, and Journal interface proportions
* Priority expandable Journal reading area
* Accessible Actions and Travel accordion controls
* Bounded scrolling for variable interface content
* Improved event dialog and Chronicle presentation
* Civilization History Ledger
* Dedicated Journal History tab
* Unique persistent civilization milestones
* Save version 3 history serialization
* Character Life Record foundation
* Stable character identity
* Dedicated Journal Legacy Preview
* Save version 4 life-record serialization

## Civilization History

The Civilization History Ledger is implemented and displayed in its own Journal tab.

Current milestone types:

* First wilderness search
* First discovery
* First crafted tool

Entries save and load in insertion order. `CivilizationData` rejects duplicate milestone IDs, while routine Chronicle narration remains transient.

Civilization history serialization was introduced in save version 3. Version 1 and 2 saves remain compatible and begin with an empty ledger. Manual gameplay testing passed for milestone recording, duplicate prevention, Journal display, saving, and loading.

## Character Life Record

The Character Life Record foundation is implemented and displayed through the Journal's Legacy Preview.

Current tracked values:

* Searches completed
* Gathered item units
* Crafting actions completed
* Crafted item units
* Discoveries contributed
* Knowledge earned
* Skill levels gained
* First and latest recorded days
* Historical milestone credit derived from civilization history

Finnley's stable character ID is `survivor.finnley`. Identity-safe milestone attribution uses this ID rather than the mutable display name.

The current save version is 4. Versions 1 through 3 remain compatible and receive an empty life record without retroactive reconstruction. Manual gameplay and save/load testing passed.

## Current Focus

Continue the vertical slice from the tested v0.5.6-alpha1 character-life foundation, then build on material variants with unique equipment instances that preserve component history.

## Next Goals

* Unique equipment instances and component history
* Full component-derived equipment statistics
* Windows export regression pass for the interface foundation
* Data-driven narrative templates
* Meadow ambient event
* Additional landmarks
* Finnley’s first journal fragment
