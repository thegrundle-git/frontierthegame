# Frontier Project Snapshot

## Current Version

v0.5.12-alpha1

## Project Health

🟢 Stable — Equipment component history passed gameplay and persistence testing

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
* Reusable full-screen Legacy Summary preview
* Deterministic contribution summary
* Identity-safe credited-milestone presentation
* Durable alive and deceased survivor state
* One-time Character Life Record finalization
* Unique persistent equipment instances
* Stable per-instance equipment identity
* Tool material and crafting provenance
* Per-instance equipment selection and storage transfers
* Exact equipped-tool continuity through succession
* Save version 7 equipment-instance serialization and migration
* Typed equipment component records
* Exact head, handle, and binding history on newly crafted tools
* Read-only Equipment Details screen
* Explicit unavailable-history state for migrated equipment
* Save version 8 component-history serialization and migration
* Recorded death day, time, and cause
* Automatic final Legacy Summary presentation
* Deceased-character action blocking
* Debug-only death testing trigger
* Save version 5 death-state serialization
* Civilization-owned completed-life archive
* Deterministic successor generation
* Stable sequence-based successor IDs
* Dedicated Succession screen
* Continued play after character death
* Save version 6 succession serialization
* Completed Lives Journal
* Chronological archived-life presentation
* Dismissible archived Legacy Summaries

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

The current save version is 6. Versions 1 through 3 remain compatible and receive an empty life record without retroactive reconstruction. Versions 4 and 5 remain compatible and load with an empty completed-life archive. Manual gameplay and save/load testing passed.

## Legacy Summary

The reusable Legacy Summary Screen is implemented and opens from the Journal's Legacy Preview.

It displays the current survivor's recorded-day range, lifetime contribution counters, and civilization milestones credited through the stable character ID. A short deterministic reflection is derived from confirmed contribution categories without inventing history or assigning a legacy score.

While a survivor is alive, the summary remains a read-only preview with keyboard cancel support, focus restoration, and an explicit return button. After death it becomes a non-dismissible final record, displays the death timestamp and cause, and provides a save action. Loading a deceased save restores the final summary automatically.

## Character Death Foundation

`SurvivorData` now stores durable alive/deceased state. `CharacterLifeRecord` finalizes once with the death day, hour, minute, and cause, then rejects later contribution mutations.

`Survivor.die()` is the authoritative death gateway. `GameManager` blocks deceased characters from starting world actions, travel, crafting, and home interaction, while direct equipment operations also reject deceased characters. A debug-build-only trigger exercises this same production path and is unavailable while an action or world event is active.

Save version 5 persists the complete death state. Versions 1 through 4 load alive and unfinalized; malformed contradictory version 5 data is normalized safely. Manual testing passed for death, final summary presentation, action blocking, saving, and loading.

## Succession Foundation

Finalized character lives are archived as typed `ArchivedCharacterLife` resources owned by `CivilizationData`. Stable character IDs prevent duplicate archival, and each archived Life Record is deep-duplicated so active-character changes cannot alter completed history.

The final Legacy Summary can open a dedicated Succession screen. The current implementation offers one deterministic newcomer at a time: Rowan, Mara, Elias, and Tamsin cycle through stable sequence-based IDs such as `survivor.successor.1`.

Successful succession replaces only the active survivor. Skills and the new Life Record begin fresh, while civilization knowledge, discoveries, history, location, time, personal inventory, kept-item settings, and the equipped tool remain. Save version 6 persists archived lives and the next successor sequence. Manual multi-generation and save/load testing passed.

## Completed Lives Journal

The Journal now exposes the civilization's completed-life archive in chronological order. Each entry shows the character's historical name, death day, and cause of death.

Players can select an archived character and open a dismissible `COMPLETED LIFE` summary containing the existing Life Record statistics and identity-safe credited milestones. The tab remains visible before the first succession and presents a clear empty state.

The feature is read-only and adds no duplicate persistence. Manual testing passed for empty, single-generation, multi-generation, and save/load scenarios.

## Unique Equipment Instances

Completed tools now exist as individual `ItemInstance` records rather than generic stack units. Each instance retains a stable ID, base item, material, maker, and crafting timestamp through equipment changes, camp storage, saving, loading, death, and succession.

Ordinary materials and components remain stack-based. Save version 7 migrates older generic and equipped tools into distinct instances without retroactively inventing detailed component histories.

## Equipment Component History

Newly crafted equipment records the exact meaningful components consumed during construction. Each component snapshot retains its slot, item, material, quality, and quantity independently of later inventory movement or character succession.

The read-only Equipment Details screen exposes identity, provenance, current base-item efficiency, and component construction. Version 8 saves preserve these records. Equipment migrated from versions 1 through 7 explicitly reports unavailable history rather than receiving fabricated components.

## Current Focus

Continue the vertical slice from the tested v0.5.12-alpha1 component-history foundation, then calculate equipment statistics from those recorded components.

## Next Goals

* Full component-derived equipment statistics
* Windows export regression pass for the interface foundation
* Data-driven narrative templates
* Meadow ambient event
* Additional landmarks
* Finnley’s first journal fragment
