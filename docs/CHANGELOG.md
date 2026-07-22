# Frontier Changelog

This document records every released version of Frontier.

---

## v0.5.27-alpha1 — Data-Driven Narrative Templates

### Added

* Typed `NarrativeTemplateData` Resources with authored variant pools and contextual token substitution.
* Search-opening templates for Forest, River, Meadow, and unknown-location fallback narration.
* Location-specific empty-search templates and item-specific discovery text with safe fallbacks.
* Context tokens for actor, location, item, quantity, day, and time.

### Changed

* Moved existing atmospheric search phrases out of `NarrativeGenerator.gd` and into authored Resources.
* Kept `NarrativeGenerator` as the centralized authority for indexing, fallback selection, random variation, and rendering.
* Tightened Chronicle spacing so one action's start, narration, result, and completion remain readable as a compact block.

### Verified

* Manual gameplay testing passed for successful and empty searches, location-appropriate variation, item results, Chronicle blocks, and existing progression behavior.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because narrative templates and Chronicle spacing change presentation without adding persistent state.

### Not Included

* Dialogue, generated biographies, AI-authored prose, relationship narration, event-template migration, and additional gameplay content remain future work.

---

## v0.5.26-alpha1 — Skills Interface Foundation

### Added

* Reusable two-column skill cells for Strength, Gathering, Crafting, and Exploration.
* Original Frontier skill icons and data-driven presentation Resources.
* At-a-glance levels and XP progress bars for every current skill.
* Fully opaque hover cards with exact XP, descriptions, and grounded effect summaries.

### Changed

* Replaced the exploration survivor panel's plain-text skill list with a compact icon grid.
* Skill details now appear on demand instead of permanently consuming exploration-screen height.
* Reduced the tooltip delay to near-instant feedback while keeping the popup strictly bounded.

### Verified

* Manual gameplay testing passed for layout, icon presentation, XP display, hover timing, tooltip readability, and exploration-screen fit.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because the interface consumes existing `SkillProgress` data without changing progression or persistence.

### Not Included

* New skills, perks, gameplay bonuses, skill categories, final shared theme tokens, and a dedicated full-screen Skills workspace remain future work.

---

## v0.5.25-alpha1 — Equipment Presentation Refinement

### Added

* Reusable visual equipment slots grouped into Equipped Tool, Expedition Pack, and Camp Storage sections.
* Automatic `ItemData.icon` presentation with readable abbreviation fallback when artwork is unavailable.
* Per-slot condition bars, percentages, failed-state treatment, selected states, and detailed tooltips.
* At-a-glance condition and usability presentation in Equipment Details.
* Independent collapsible sections for Components, Maintenance, Component Replacement, and Disassembly.

### Changed

* Replaced the flat Accessible Equipment text list with a compact Minecraft-inspired slot layout.
* Camp Storage equipment appears only while the survivor is actually at Camp.
* Equipment opens with keyboard focus directed to the selected visual slot.
* Identity, condition, usability, derived statistics, and provenance remain visible while advanced operations stay available on demand.

### Verified

* Manual gameplay testing passed for slot selection, source grouping, tooltips, condition presentation, equip and unequip, collapsible details, and workspace navigation.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because slots and collapsible sections consume existing equipment data without changing its shape.

### Not Included

* New item artwork, armor or accessory categories, drag-and-drop, comparison views, final shared theme tokens, and the planned icon-based Skills grid remain future work.

---

## v0.5.24-alpha1 — Journal Workspace Foundation

### Added

* A dedicated scene-owned Journal workspace for History, Legacy Preview, Completed Lives, Locations, Discoveries, and Landmarks.
* Stable `exploration.journal` routing with explicit Back and keyboard-cancel behavior.
* A clear **Open Journal** entry point beside the exploration Chronicle.
* Two balanced columns for sorted Expedition Pack resources and equipment.

### Changed

* Chronicle narration remains permanently visible on the exploration screen instead of becoming a workspace tab.
* Journal rendering, selection, tab visibility, and navigation moved out of `GameUI` into `JournalUI`.
* `GameUI.add_event()` remains the stable narration API used by gameplay systems.
* Legacy Summary and completed-life requests now travel from `JournalUI` to the existing `GameUI` integration boundary through signals.
* Expedition Pack uses one prominent header without a redundant nested Inventory label.

### Fixed

* Restored compatibility refresh methods used by Search, Craft, Discovery, chopping, and skill progression after the Journal extraction.
* Prevented search and discovery crashes caused by calls to removed `GameUI` Journal methods.

### Verified

* Manual gameplay testing passed for searches, Chronicle narration, Journal navigation and tabs, and the two-column Expedition Pack.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because Journal and Pack changes consume existing runtime and persistent data without changing its shape.

### Not Included

* Journal search, filters, categories, bookmarks, custom notes, final visual styling, Equipment presentation refinement, and the planned icon-based Skills grid remain future work.

---

## v0.5.23-alpha1 — Exploration Interface Foundation

### Added

* Clear headings for current location, survivor state, Expedition Pack, available actions, and travel.
* A dedicated contextual **Enter Camp** area that appears only at the civilization's home location.
* A single **Open Equipment** entry point from the survivor summary.

### Changed

* Actions and Travel now remain visible together in independently scrolling panels.
* Camp entry is separated from ordinary wilderness actions and uses the existing Camp routing flow.
* The survivor panel now summarizes equipped gear instead of duplicating equipment selection, equip, unequip, and inspection controls.
* The Design Philosophy now defines Legible Complexity as the interface's governing presentation principle.

### Verified

* Manual gameplay testing passed for Camp visibility and entry, travel, world actions, action progress, field and Camp equipment access, and interface fit.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because this milestone changes only interface structure and routing presentation.

### Not Included

* Journal extraction, final visual styling, shared theme tokens, responsive breakpoint switching, and new gameplay systems remain future work.

---

## v0.5.22-alpha1 — Storage Workspace Refinement

### Added

* Permanent scene-owned Pack, transfer-control, and Camp Storage panels.
* Clear Resources, Equipment, and Equipped sections in inventory lists.
* Stable item and equipment selection based on item IDs and instance IDs.
* Disabled empty-state entries for inventories without contents.

### Changed

* Removed the runtime Storage interface builder and obsolete hidden `StorageLog` anchor.
* Transfer controls now consume one centralized selection model.
* Deposit and Take select the transferred entry on its destination side.
* Keep changes and ordinary refreshes preserve the current selection.
* Equipment inspection continues routing to the selected Equipment workspace instance.
* `StorageUI.gd` was reduced from 678 to 375 lines.

### Verified

* Manual gameplay testing passed for list presentation, empty states, partial transfers, equipment transfers, Keep, Deposit All, inspection, navigation, and bounded list behavior.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because Storage continues using the existing inventory data and transfer APIs.

### Not Included

* Capacity limits, sorting controls, filters, search, new transfer rules, shared theme tokens, and responsive breakpoint switching remain future work.

---

## v0.5.21-alpha1 — Equipment Workspace Foundation

### Added

* A routed Equipment workspace with a unified accessible-equipment list and container-native detail pane.
* Source labels for equipped, Expedition Pack, and Camp Storage equipment.
* Workspace equip and unequip controls.
* Stable instance selection across maintenance and component replacement.

### Changed

* Equipment inspection from Camp Storage and the HUD now opens the selected instance in the Equipment workspace.
* Field inspection remains available without falsely entering Camp; maintenance continues to require Camp access.
* The former full-screen Equipment Details overlay now operates as an embedded, internally scrolling detail panel.
* Disassembly confirmation remains modal and prevents underlying workspace navigation.
* Successful disassembly selects the nearest remaining equipment entry or displays an empty state.

### Fixed

* Replaced the incompatible embedded-modal hierarchy that could collapse the detail pane into a black region.
* Corrected the invalid root cast introduced during the panel conversion.

### Verified

* Manual gameplay testing passed for the rebuilt Equipment workspace and inspection panel.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because the workspace reuses existing equipment instances and operations.

### Not Included

* Repair and replacement gameplay-service extraction, new equipment mechanics, responsive breakpoint switching, final visual styling, and removal of the legacy HUD tool controls remain future work.

---

## v0.5.20-alpha1 — Crafting Workspace Extraction

### Added

* A dedicated `CraftingUI` scene and controller for the routed Camp Crafting workspace.
* Permanent recipe-selection controls and bounded scrolling for recipe details.
* Focused craft and back navigation signals between Crafting and `GameUI`.

### Changed

* Recipe selection, ingredient presentation, affordability state, and workspace focus behavior moved out of `GameUI`.
* `GameUI` now forwards craft intent to the existing `GameManager.craft_recipe()` gameplay gateway.
* The dynamically constructed recipe selector and embedded Crafting node hierarchy were removed.
* `GameUI.gd` was reduced by 246 lines without changing crafting rules.

### Verified

* Manual gameplay testing passed for recipe selection, material counts, disabled states, component and axe crafting, material variants, output placement, auto-equipping, timing, navigation, empty state, and responsive scrolling.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because this extraction changes presentation ownership only.

### Not Included

* New recipes, crafting rules, component-slot redesign, final visual styling, shared theme tokens, and equipment workspace conversion remain future work.

---

## v0.5.19-alpha1 — UI Navigation and Layout Foundation

### Added

* A reusable `UIRouter` for stable workspace screen IDs, navigation history, and focus entry points.
* Persistent Camp navigation for Overview, Storage, Crafting, and leaving Camp.
* Standard keyboard-cancel behavior for routed Camp sub-screens.
* A dedicated UI architecture document defining workspace and modal boundaries.

### Changed

* Camp screen visibility is now coordinated through one routing authority instead of scattered `visible` assignments.
* Camp Overview, Storage, and Crafting share consistent navigation and content bounds.
* Storage and Crafting refresh only when their routed workspace is opened.
* Final legacy presentation closes the Camp workspace through the same routing boundary.

### Verified

* Manual gameplay testing passed for Camp entry, direct workspace switching, Back/Escape behavior, equipment inspection, leaving and re-entering Camp, and responsive layout.
* Godot 4.7 headless validation completed successfully.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because UI routing does not add or change persistent gameplay data.

### Not Included

* HUD restructuring, Journal migration, Crafting scene extraction, equipment workspace conversion, shared theme tokens, responsive breakpoints, and focused data-refresh signals remain future work.

---

## v0.5.18-alpha1 — Complete Component-Derived Equipment Stats

### Added

* Handle-derived handling and real-time action duration.
* Binding-derived stability and weakest-component overall quality.
* Component-source explanations for every derived equipment statistic.
* Complete resulting-stat previews during component replacement.

### Changed

* Axe-required world actions receive their real duration from the equipped instance's handle.
* The current Stick Handle reduces Chop Tree from 5.0 to 4.5 real seconds.
* Chop Tree continues advancing exactly 120 in-game minutes.
* Repair and replacement immediately recalculate all statistics from active components.
* Unknown-history tools retain base duration and efficiency without invented component ratings.

### Verified

* Manual gameplay testing passed for displayed ratings, actual progress duration, unchanged simulated time, replacement previews, recalculation, and save/load behavior.
* Godot 4.7 registered the updated stat calculator and Equipment Details class without new implementation errors.
* `git diff --check` passed.

### Save Compatibility

* Save version remains 12 because every new statistic is derived from existing component records.

### Not Included

* Simulated-time reduction, random craftsmanship, wear probability, persistent use counters, maker bonuses, combat statistics, and new component materials remain future work.

---

## v0.5.17-alpha1 — Equipment Disassembly Foundation

### Added

* Typed civilization-owned disassembly records preserving a removed tool's final state and history.
* Camp-only disassembly previews and explicit confirmation.
* Durable civilization History entries for successfully disassembled equipment.
* Truthful recovery of full-condition components into Camp Storage.

### Changed

* Unequipped carried or stored tools can be permanently disassembled after confirmation.
* Equipped tools are protected until unequipped.
* Damaged and failed components are recorded but are not converted into pristine stackable items.
* Legacy tools with unknown construction history can be removed without fabricated recovery.
* Save version 12 persists disassembly records while versions 1 through 11 load with an empty archive.

### Verified

* Manual gameplay testing passed for confirmation cancellation, equipped-tool protection, removal, recovery, History updates, UI refresh, and save/load persistence.
* Godot 4.7 registered the disassembly service, record, and changed Equipment Details class without new implementation errors.
* `git diff --check` passed.

### Not Included

* Partial recovery, salvage percentages, damaged-component instances, disassembly time, skill checks, NPC automation, building disassembly, and a dedicated Tool Bench remain future work.

---

## v0.5.16-alpha1 — Equipment Component Replacement Foundation

### Added

* Typed, persistent component-replacement history with removed and installed component snapshots.
* Camp replacement controls for axe heads, handles, and bindings.
* Data-driven result previews and Stone Axe/Flint Axe transformation.
* Monotonic component record IDs that are never reused within an equipment instance.

### Changed

* Replacing a component preserves the equipment instance, original maker, and crafting time while updating its current construction.
* Installed components begin at full condition and immediately drive derived efficiency and durability.
* Full-condition removed components return to Camp Storage; damaged or failed components are not converted into pristine stackable items.
* Equipment Details displays replacement requirements, outcomes, recovery, and chronological replacement history.
* Save version 11 persists active replacement state and history while versions 1 through 10 migrate without fabricated replacements.

### Verified

* Manual gameplay testing passed for replacement, Stone/Flint result changes, recovery rules, condition initialization, repeated replacement, and save/load persistence.
* Godot 4.7 registered the replacement service, record, and changed Equipment Details class without new implementation errors.
* `git diff --check` passed.

### Not Included

* General disassembly, damaged-component recovery, partial recovery, removal failure, replacement time, skill outcomes, NPC replacement, and a dedicated Tool Bench remain future work.

---

## v0.5.15-alpha1 — Equipment Maintenance Foundation

### Added

* Individual repair controls for damaged and failed equipment components.
* Matching component-item costs for head, handle, and binding maintenance.
* Persistent maintenance count, last-maintained day, and maintainer identity snapshots.
* Equipment inspection for carried, stored, and currently equipped tools from Camp Storage.

### Changed

* Repairs restore selected condition without rewriting immutable construction history.
* Maintenance consumes accessible Camp Storage or carried materials atomically and is available only at Camp.
* Equipment Details displays repair choices, costs, availability, and maintenance history.
* Equipment Details uses a bounded scrolling layout with its Return button always accessible.
* Save version 10 persists maintenance history while versions 1 through 9 load with empty maintenance records.

### Verified

* Manual gameplay testing passed for Camp inspection, component costs, failed-component recovery, UI refresh, and the scrollable details layout.
* Godot 4.7 registered the changed maintenance and storage UI classes without new implementation errors.
* `git diff --check` passed.

### Not Included

* Component replacement, disassembly, recovery, Tool Bench construction, repair time, repair skill outcomes, and automated maintenance remain future work.

---

## v0.5.14-alpha1 — Equipment Durability Foundation

### Added

* Typed mutable condition records separate from immutable component history.
* Centralized component maximum-condition, wear, failure, usability, and overall-condition calculations.
* Independent head, handle, and binding condition for component-aware tools.
* Tool-level fallback condition for equipment without known component history.

### Changed

* Successful tree chopping wears the axe head and binding after awarding the action's results.
* Failed critical components prevent later tool-required actions.
* Equipment Details displays overall condition, usability, per-component condition, and failures.
* Save version 9 persists component condition and fallback condition.
* Version 8 tools initialize their known components at full condition; versions 1 through 7 retain unknown history and receive only fallback condition.

### Verified

* Manual gameplay testing passed for component wear, final valid use, failure gating, inspection, storage, save/load, and succession continuity.
* Stone and Flint head maximum condition remains derived from quality while primitive binding is the first expected failure point.
* Isolated Godot 4.7 validation registered both durability classes without new implementation errors.
* `git diff --check` passed.

### Not Included

* Repairs, component replacement, disassembly, material recovery, permanent item destruction, random breakage, handle wear, and maintenance controls remain future work.

---

## v0.5.13-alpha1 — Component-Derived Tool Efficiency

### Added

* Centralized, stateless equipment-stat calculation.
* Head-component quality as the authoritative source of axe efficiency.
* Equipment Details explanations identifying the component behind a derived value.

### Changed

* Tree-chopping yield now uses the equipped instance's derived efficiency.
* Stone and Flint Axe balance remains unchanged at efficiency 1 and 2 respectively.
* Equipment without usable component history falls back to its base `ItemData` efficiency.

### Verified

* Manual gameplay testing passed for Stone and Flint Axe inspection, chopping yield, save/load, and succession continuity.
* Existing Gathering and Strength bonuses continue to apply after derived base efficiency.
* Isolated Godot 4.7 validation registered `EquipmentStatCalculator` without new implementation errors.
* `git diff --check` passed.

### Not Included

* Durability, handle or binding effects, overall quality, random craftsmanship, repairs, replacement, and disassembly remain future work.

---

## v0.5.12-alpha1 — Equipment Component History

### Added

* Typed equipment component records for meaningful construction slots.
* Exact head, handle, and binding snapshots on newly crafted tools.
* Persistent component item, material, quality, and quantity data.
* Read-only Equipment Details screen for equipped, carried, and stored tools.

### Changed

* Crafting now records both fixed and interchangeable components at the authoritative ingredient-removal point.
* New equipment instances receive deep-copied component histories.
* Save version 8 persists component records and explicit component-history availability.
* Versions 1 through 7 remain compatible and report unavailable history instead of inventing components.

### Verified

* Manual gameplay testing passed for Stone and Flint Axe component records, equipment inspection, storage, save/load, and succession continuity.
* Isolated Godot 4.7 validation registered `EquipmentComponentRecord` and `EquipmentDetailsScreen` without new implementation errors.
* `git diff --check` passed.

### Not Included

* Component-derived stat recalculation, replacement parts, repairs, durability, disassembly, recovered components, custom names, and engraving remain future work.

---

## v0.5.11-alpha1 — Unique Equipment Instance Foundation

### Added

* Typed, individually persistent equipment instances with stable IDs.
* Crafting provenance containing the base item, material, crafter identity, and crafting timestamp.
* Separate inventory storage for stackable resources and unique equipment.
* Per-instance equipment selection and camp-storage transfers.

### Changed

* Crafted tools now create one unique instance per output unit instead of entering a generic item stack.
* Equipping and unequipping move the exact selected tool instance.
* Tool performance continues to resolve through the instance's base `ItemData`.
* Succession preserves the exact equipped instance across generations.
* Save version 7 persists personal, stored, and equipped instances with defensive migration from versions 1 through 6.

### Verified

* Manual gameplay testing passed for crafting, distinct instance IDs, equipment selection, storage transfers, save/load persistence, and succession continuity.
* Isolated Godot 4.7 validation registered `ItemInstance` and found no new errors from the equipment-instance implementation.
* `git diff --check` passed.

### Not Included

* Durability, quality, custom names, engraving, repairs, replacement components, disassembly, and complete component provenance remain future work.

---

## v0.5.10-alpha1 — Completed Lives Journal

### Added

* Always-visible Completed Lives Journal tab.
* Chronological presentation of archived characters with death day and cause.
* Archived-character selection and expanded completed-life summaries.
* Clear empty-state presentation before the first succession.

### Changed

* `LegacySummaryScreen` now supports a dismissible archived-life presentation mode.
* Completed-life milestone attribution continues to use stable character IDs.
* Archived-life browsing reuses civilization-owned archive data without adding duplicate save state.

### Verified

* Manual gameplay testing passed for empty state, single- and multi-generation lists, archived summaries, and save/load persistence.
* Archived-summary viewing remained read-only and did not alter counters or history.
* Isolated Godot 4.7 validation found no new errors from the Completed Lives Journal.
* `git diff --check` passed.

### Not Included

* Family trees, relationships, heirs, portraits, graves, memorial buildings, generated biographies, and legacy scores remain future work.

---

## v0.5.9-alpha1 — Succession Foundation

### Added

* Typed civilization-owned archives for finalized character lives.
* Deterministic successor candidates with stable sequence-based character IDs.
* A focused Succession screen for continuing the civilization.
* A Choose Successor action on the final Legacy Summary.
* Save version 6 serialization for archived lives and successor sequencing.

### Changed

* Succession replaces the deceased active survivor while preserving civilization state and existing belongings.
* Successors begin with fresh skills and a new empty Character Life Record.
* Completed lives are archived exactly once and remain owned by the civilization.
* Save versions 1 through 5 remain compatible and load with an empty completed-life archive.

### Verified

* Manual gameplay testing passed for death, successor selection, continued play, and save/load persistence.
* Repeated succession produced deterministic successor names and unique stable IDs.
* Isolated Godot 4.7 validation registered `ArchivedCharacterLife` and `SuccessionScreen`.
* `git diff --check` passed.

### Not Included

* Children, heirs, families, relationships, inheritance choices, corpses, aging, multiple living settlers, and procedural biographies remain future work.

---

## v0.5.8-alpha1 — Character Death Foundation

### Added

* Durable alive and deceased character state.
* One-time Character Life Record finalization with death day, time, and cause.
* Automatic final Legacy Summary presentation when a character dies.
* Final-record saving and automatic summary restoration after loading a deceased save.
* Debug-build-only character death trigger for testing the production death pipeline.
* Save version 5 death-state serialization and defensive migration.

### Changed

* Deceased characters can no longer begin actions, travel, craft, equip tools, or enter home interactions.
* Finalized life records reject later contribution mutations.
* The Legacy Summary now supports living preview and non-dismissible final modes.
* Save versions 1 through 4 remain compatible and load characters as alive with unfinalized life records.

### Verified

* Manual gameplay testing passed for death triggering, action blocking, final summary presentation, saving, and loading.
* Isolated Godot 4.7 validation found no new errors from the death foundation.
* `git diff --check` passed.

### Not Included

* Succession, inheritance, corpses, burial, aging, health depletion, and combat death remain future work.

---

## v0.5.7-alpha1 — Legacy Summary Screen

### Added

* Reusable full-screen Legacy Summary preview.
* Legacy Preview action for opening the expanded summary.
* Character contribution, recorded-day, and credited-milestone presentation.
* Deterministic life-summary text grounded in confirmed recorded actions.
* Keyboard cancel, focus restoration, and internally scrolling summary content.

### Changed

* Character legacy information can now be reviewed without waiting for a future death system.
* Historical milestone presentation remains identity-safe through stable contributor IDs.
* Legacy presentation reuses the existing Character Life Record and Civilization History Ledger without new saved state.

### Verified

* Manual gameplay testing passed for opening, displaying, and closing the Legacy Summary Screen.
* The responsive interface remained stable during summary presentation.
* Isolated Godot 4.7 validation registered the new `LegacySummaryScreen` class.
* `git diff --check` passed.

### Not Included

* Death, succession, descendants, finalized biographies, generated prose, personality judgments, and legacy scores remain future work.

---

## v0.5.6-alpha1 — Character Life Record Foundation

### Added

* Typed character-owned `CharacterLifeRecord` resources.
* Stable character IDs, beginning with `survivor.finnley`.
* Lifetime contribution counters for searches, gathering, crafting, discoveries, knowledge, skill levels, and recorded days.
* Dedicated Legacy Preview tab in the Journal.
* Identity-safe civilization-history milestone attribution.
* Save version 4 life-record serialization and migration.

### Changed

* Historical milestone credit is derived from stable contributor IDs instead of stored twice or matched by display name.
* Versions 1 through 3 remain compatible and load with an empty life record.
* Older saves do not reconstruct retroactive character statistics.

### Verified

* Manual gameplay and save/load testing passed for lifetime counters, recorded days, stable attribution, Legacy Preview, and migration behavior.

---

## v0.5.5-alpha1 — Civilization History Ledger

### Added

* Typed `CivilizationHistoryEntry` resources.
* Unique persistent civilization milestones.
* Dedicated History tab in the Journal.
* First Wilderness Search milestone.
* First Discovery milestone.
* First Crafted Tool milestone.
* Save version 3 history serialization.
* Initial Design Philosophy document.

### Changed

* Civilization history now saves and loads in milestone insertion order.
* Duplicate milestone IDs are rejected by `CivilizationData`.
* Chronicle narration remains transient and separate from durable civilization memory.
* Version 1 and 2 saves remain compatible and load with an empty history ledger.
* Older saves do not fabricate retroactive milestones.

### Verified

* Manual gameplay testing passed for milestone recording, duplicate prevention, Journal display, saving, and loading.

---

## v0.5.4-alpha1 — Interface Foundation

### Added

* Expandable Actions and Travel accordion sections.
* Bounded scrolling for variable action, travel, inventory, Journal, and event content.
* Keyboard focus and explanatory tooltips for primary interactive controls.

### Changed

* Rebalanced Skills, Inventory, and Journal proportions for the 1280×720 interface.
* Journal now receives priority reading space and expands into available room.
* Actions and Travel now collapse or scroll instead of shifting the overall interface as controls populate.
* Interactive controls use more consistent, usable minimum sizing.
* Event dialog supports longer scrolling content.
* Chronicle entries use clearer spacing and divider formatting.

### Fixed

* Variable button lists and text content resizing or pushing the root interface.
* Journal reading space becoming too small as Actions and Travel populated.

---

## v0.5.3-alpha2 — Tool Material Variants

### Added

* Flint as a rare River search resource.
* Flint Axe Head component and knapping recipe.
* Flint Axe material variant with improved chopping efficiency.
* Material-quality ranking for interchangeable crafting components.
* Material-dependent recipe results.
* Manual tool selector with Equip and Unequip controls.
* Tag-based action tool requirements.

### Changed

* Assemble Axe now accepts the best available head material.
* Flint Axe gathers one additional base Wood Log compared with Stone Axe.
* Chop Tree now accepts any equipped axe rather than one exact item ID.
* Equipped tools can be deliberately exchanged instead of relying only on crafting auto-equip.
* River search data is stored as one clean resource definition.

### Fixed

* Chronicle entries now use compact dividers between completed actions instead of unstructured blank space.

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
