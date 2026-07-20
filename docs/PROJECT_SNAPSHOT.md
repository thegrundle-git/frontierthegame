# Frontier Project Snapshot

## Current Version

v0.5.25-alpha1

## Project Health

🟢 Stable — Equipment presentation refinement passed gameplay testing

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
* Simultaneously visible Actions and Travel panels
* Bounded scrolling for variable interface content
* Improved event dialog and Chronicle presentation
* Centralized Camp workspace routing
* Persistent Camp navigation
* Standard Camp Back/Escape behavior
* Workspace focus entry points and navigation history
* Dedicated routed Crafting workspace
* Scene-owned recipe selection and bounded recipe details
* Signal-based Crafting intent forwarding
* Routed Equipment workspace
* Unified equipped, carried, and stored equipment selection
* Container-native equipment detail and maintenance panel
* Field and Camp equipment inspection continuity
* Scene-native Storage workspace
* Stable cross-inventory transfer selection
* Distinct resource, equipment, and equipped inventory sections
* Context-sensitive Storage transfer controls
* Dedicated contextual Enter Camp area at the home location
* Clear exploration hierarchy for location, survivor, pack, actions, and travel
* Single Equipment workspace entry point from the survivor summary
* Reusable visual equipment slots with icon fallback
* Equipped, Expedition Pack, and Camp Storage equipment groups
* At-a-glance equipment condition, usability, and failure states
* Collapsible Components, Maintenance, Replacement, and Disassembly sections
* Permanently visible exploration Chronicle
* Dedicated routed Journal workspace
* Scene-owned History, Legacy, Completed Lives, Locations, Discoveries, and Landmarks tabs
* Back and keyboard-cancel Journal navigation
* Two-column sorted Expedition Pack contents
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
* Centralized component-derived equipment-stat calculation
* Axe efficiency derived from recorded head quality
* Explainable stat-source presentation in Equipment Details
* Base-item efficiency fallback for equipment without usable history
* Independent component condition and failure state
* Centralized equipment durability calculations
* Head and binding wear from successful tree chopping
* Critical-component action gating
* Equipment condition and usability inspection
* Save version 9 durability serialization and migration
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

The current save version is 12. Versions 1 through 11 remain compatible through explicit migrations, without retroactively inventing history, components, maintenance, replacements, disassembly, or recovery. Manual gameplay and save/load testing passed.

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

The read-only Equipment Details screen exposes identity, provenance, current derived efficiency, its calculation source, and component construction. Version 8 saves preserve these records. Equipment migrated from versions 1 through 7 explicitly reports unavailable history rather than receiving fabricated components.

## Component-Derived Tool Efficiency

`EquipmentStatCalculator` derives axe efficiency from the recorded head component's material quality. Stone remains efficiency 1 and Flint remains efficiency 2, preserving established balance while shifting authority from the finished item template to the specific instance's construction.

Tree chopping consumes this derived value before applying the existing Gathering and Strength bonuses. Equipment Details identifies the contributing head. Tools without usable component history retain their base-item efficiency as a compatibility fallback.

## Equipment Durability

Component-aware tools now keep mutable condition separately from their immutable construction records. Maximum condition is centralized by slot and material quality: current Stone and Flint heads begin at 30 and 40, the Stick Handle at 30, and Fiber Binding at 10.

Successful tree chopping wears the head and binding after granting the action's results. The final valid use succeeds, then a failed critical component blocks later actions. Equipment Details exposes per-component and overall condition without adding repair controls.

Save version 9 preserves exact wear. Version 8 tools initialize known components at full condition, while older unknown-history tools receive only an overall fallback condition and no invented parts.

## Equipment Maintenance

At Camp, damaged equipment can be inspected from the survivor's pack, Camp Storage, or the currently equipped tool. A selected component consumes one matching component item and returns to full condition, including after failure.

Maintenance changes present condition without rewriting construction history. Each successful repair records a maintenance count, day, and maintainer identity snapshot. Equipment Details exposes costs and availability in a bounded scrolling layout.

Save version 10 preserves maintenance history. Versions 1 through 9 remain supported and begin with empty maintenance records.

## Equipment Component Replacement

At Camp, the player can replace a known axe head, handle, or binding with a compatible available component. The tool keeps its stable instance identity, original maker, and crafting time while its active construction, condition, result name, material, and derived statistics update.

Every replacement records removed and installed component snapshots, condition at removal, date, character identity, and recovery outcome. Full-condition removed components return to Camp Storage; damaged components are not converted into pristine stackable items.

Stone and Flint head replacement reuses the assembly recipe's material-variant rules, allowing the same persistent tool to become a Stone Axe or Flint Axe without hardcoded UI mapping. Save version 11 preserves the active state, monotonic component sequence, and replacement history.

## Equipment Disassembly

At Camp, an unequipped carried or stored tool can be deliberately dismantled after a recovery preview and confirmation. Full-condition components return to Camp Storage; damaged or failed components remain historical facts but do not become pristine stackable items.

Before the runtime instance disappears, the civilization records its identity, origin, active components, final condition, replacement history, maintenance count, recovery, time, and responsible character. A readable durable History event keeps the loss visible after the tool is gone.

Save version 12 preserves the ordered disassembly archive. Versions 1 through 11 remain compatible and do not fabricate missing disassembly events or recovered parts.

## Complete Component-Derived Stats

Every meaningful axe component now contributes a readable derived statistic. The head controls efficiency, the handle controls handling and real action duration, the binding supplies stability, and the weakest installed component limits overall quality.

The current Stick Handle reduces Chop Tree from 5.0 to 4.5 real seconds while the action still advances exactly 120 simulated minutes. This makes handling immediately tangible without accelerating hunger, seasons, events, or the broader economy.

Equipment Details and replacement previews use the same stateless calculator as gameplay. Repair and replacement recalculate immediately, unknown-history tools retain safe base behavior, and save version remains 12 because no derived value is persisted.

## Current Focus

Prepare the icon-and-level Skills layout while preserving the compact exploration hierarchy and accessible detail-on-demand behavior.

## Next Goals

* Windows export regression pass for the interface foundation
* RuneScape-inspired icon-and-level Skills layout
* Data-driven narrative templates
* Meadow ambient event
* Additional landmarks
* Finnley’s first journal fragment
