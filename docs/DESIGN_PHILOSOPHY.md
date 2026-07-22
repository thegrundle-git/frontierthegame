# Frontier Design Philosophy

Frontier is a civilization-building life simulation focused on discovery, memory, history, relationships, and legacy.

Survival is the opening chapter. It establishes the first needs, choices, and consequences, but it is not the complete identity of the game. Frontier is ultimately about the lives and knowledge that accumulate around a civilization over time.

The world existed before the player arrived. It should retain evidence of its own past, respond to what happens within it, and continue after each individual character is gone.

---

## Durable Principles

* Every major system should create stories, not only resources.
* Important actions should become part of the civilization's memory.
* Knowledge can be discovered, recorded, inherited, forgotten, and recovered.
* Character death should eventually complete a life story rather than function only as conventional failure.
* Every character life should accumulate a meaningful record of contributions.
* Legacy should emerge from recorded actions and durable consequences, not from an arbitrary score.
* Character statistics should reflect confirmed gameplay mutations rather than transient messages or reconstructed guesses.
* Stable identity must not depend solely on mutable display names.
* History should be represented by durable facts and meaningful milestones, not by persisting every routine event.
* Chronicle messages are immediate narration. Civilization history is durable memory.
* Common-sense interaction and reusable systems should be preferred over isolated scripted exceptions.
* Features should be evaluated by whether they create meaningful stories and whether their effects can matter years later.

These principles describe the direction of Frontier. They do not imply that every legacy, relationship, inheritance, or historical system is already implemented.

---

## Interface as a Stable Way Into the Simulation

Frontier's interface should make interconnected systems easier to understand rather than exposing the structure of the codebase. Players should be able to predict where an activity belongs, how to return from it, and whether they are changing their current workspace or opening a temporary modal decision.

The governing presentation principle is **Legible Complexity**. Frontier should preserve the depth and interconnection of its simulation while presenting the player's immediate situation at a glance. Primary state and available decisions belong in the main view; detailed explanations, histories, and maintenance operations should remain available on demand through clearly named workspaces. Complexity should be organized, not hidden, and the same concept should use consistent language and placement everywhere it appears.

Contextual destinations must remain distinct from ordinary actions. Entering Camp changes the player's workspace and exposes local facilities, so it receives a dedicated contextual area rather than appearing beside wilderness actions. Actions and travel are parallel choices and should remain simultaneously readable when space permits. Equipment receives one authoritative workspace instead of duplicating selection and mutation controls across the exploration interface.

Workspace navigation is therefore a shared rule rather than a behavior each feature invents independently. The implemented Camp navigation foundation gives Overview, Storage, and Crafting stable destinations with consistent Back, keyboard-cancel, and focus behavior. Equipment inspection and irreversible confirmations remain modal layers because they temporarily require attention without replacing the player's underlying workspace.

Future menus should extend the shared navigation, layout, focus, scrolling, and modal conventions instead of adding isolated full-screen visibility logic. This foundation does not yet imply a final visual style, responsive breakpoint system, reorganized HUD, or completed menu hierarchy.

The extracted Crafting workspace is the first completed replacement built on that foundation. It owns its presentation and emits player intent without taking authority over crafting rules, inventory consumption, time, skill rewards, or item creation. Future workspace migrations should preserve the same separation between interface responsibility and simulation authority.

Equipment inspection now follows the same workspace model. A meaningful object should remain the same selectable instance whether it is equipped, carried, or stored, and its identity should survive repair, replacement, navigation, and refresh. Destructive confirmation remains modal because it interrupts the workspace for an explicit irreversible choice; routine inspection and maintenance do not.

Equipment presentation should make identity and present condition visible before demanding detailed reading. Visual slots group objects by their real source, preserve stable selection, and expose condition and failure at a glance. Icons are progressive enhancement: when artwork is unavailable, a readable fallback must preserve the slot's meaning. Detailed construction, maintenance, replacement, and disassembly remain available on demand through collapsible sections rather than competing with the always-visible identity summary.

The interface must not imply systems the simulation does not yet support. Frontier can borrow the legibility of familiar equipment grids without displaying fictional armor, accessory, or weapon categories. New slot types should appear only when their underlying gameplay exists.

Storage should present movement between inventories as continuity rather than disappearance and recreation. A transferred resource or equipment instance remains selected on its destination side, helping the player understand where it went. Scene-owned controls and stable identifiers make that continuity explicit while leaving inventory authority with the existing simulation model.

The Exploration Interface Foundation applies these rules to the main play view. Location, survivor, expedition pack, available actions, and travel have explicit visual hierarchy; Actions and Travel remain independently scrollable without competing accordion state; Camp access appears only at the civilization's home location; and the survivor panel summarizes equipped gear while routing inspection and mutation into the Equipment workspace. This is structural refinement rather than a final visual theme or responsive-breakpoint system.

Immediate narration should remain visible while the player makes moment-to-moment decisions. The Chronicle therefore belongs on the exploration surface rather than behind navigation. Durable history, discovered knowledge, places, and completed lives belong in the dedicated Journal workspace, where deeper reading does not compete with active play. The Expedition Pack follows the same hierarchy: one clear heading and compact columns expose current contents without adding another nested inventory label.

Skills should be readable as capabilities rather than presented as a dense diagnostic list. Icons, levels, and progress belong at a glance; exact XP and explanations belong on demand. Presentation metadata may clarify what a skill means, but it must not invent effects that the simulation does not implement or become a second authority for progression.

Narrative should interpret confirmed simulation results rather than decide them. Authored templates may vary tone and respond to known context, but rewards, discoveries, history, and progression remain governed by their existing systems. New prose should be expandable as content without embedding location- and item-specific language throughout gameplay code.

---

## Memory and Moment-to-Moment Narration

Not every action belongs in permanent history.

The Chronicle explains what is happening now: a search begins, an item is found, a tool is equipped, or an action finishes. These messages help the player understand the immediate game state, but routine narration remains transient.

Civilization history records selected facts whose meaning should survive saving, loading, and future generations. The Civilization History Ledger provides the first architectural example. It records unique milestones such as the civilization's first wilderness search, first discovery, and first crafted tool. Ordinary search, discovery, and crafting messages continue to appear only in the Chronicle.

This distinction keeps durable memory meaningful. The ledger is not a transcript of every action; it is a record of events that changed the civilization's story.

---

## Character Lives and Legacy

Civilization history and character life records are related but distinct. Civilization history records enduring milestones in the shared story. A Character Life Record summarizes one person's confirmed contributions across that life.

The implemented Character Life Record foundation tracks successful searches, gathered and crafted item units, completed crafting actions, discovery contributions, knowledge earned, skill levels gained, recorded days, and identity-safe credit for civilization milestones. It does not interpret those facts as a score or a judgment of the character.

Death should eventually complete and summarize a life rather than function only as conventional failure. That future summary should consume the existing civilization-history and character-life foundations instead of creating parallel tracking systems.

The implemented Legacy Summary preview turns those recorded facts into a readable reflection while the survivor is still alive. It presents contributions and credited milestones without assigning an arbitrary score or inventing unrecorded history. Its short summary is deterministic and grounded in confirmed actions.

The implemented Character Death Foundation now lets death complete a recorded life. Finalization is a durable, one-time transition grounded in the existing life record, and the final Legacy Summary reflects confirmed contributions rather than inventing a score or biography. A deceased character cannot continue accumulating accomplishments.

The implemented Succession Foundation allows the civilization to continue after a completed life. The deceased character becomes durable civilization memory, while the successor begins a distinct identity, fresh skills, and an empty Life Record. The world and its accumulated history remain the continuous protagonist.

Current succession deliberately preserves existing belongings without asking the player to divide them. This continuity is not yet an inheritance system and should not imply family, heirship, or ownership law.

Children, heirs, families, relationships, inheritance choices, descendants, corpses, burial, aging, health-driven death, relationship memories, and generated life stories remain future work. Those systems should build on finalized and archived lives instead of replacing or duplicating them.

The Completed Lives Journal makes the civilization's memory visible after succession. A completed character remains readable as a distinct life with confirmed contributions and credited milestones rather than disappearing when control changes.

Remembering completed lives is not yet genealogy or memorial culture. The archive records who lived and what they contributed without inventing family connections, social meaning, reverence, or historical judgment that the simulation has not earned.

---

## Objects, Identity, and Continuity

Meaningful equipment should be capable of becoming part of the civilization's history. A finished tool is therefore not merely another interchangeable unit in a stack: it has a stable identity that can survive storage, use, saving, loading, death, and succession.

The implemented Unique Equipment Instance foundation gives crafted tools individual IDs and records their base item, material, maker, and creation time. Stackable materials and components remain fungible resources, while completed tools become distinct objects. Equipping, storing, and continuing across generations all preserve the exact instance rather than silently substituting an equivalent tool.

The implemented Equipment Component History foundation records the exact meaningful parts consumed when a tool is assembled. Head, handle, and binding records retain their item, material, quality, and quantity as durable facts. Migrated tools acknowledge when that history is unavailable rather than receiving a plausible but fictional past.

Component history is now both evidence and a source of behavior. Axe efficiency is derived from the recorded head's material quality, and the interface explains that cause rather than presenting an unexplained number. Migrated tools retain their base performance when truthful construction evidence is unavailable.

Components can now change through use without rewriting what the tool was originally made from. Construction records remain durable facts, while separate condition records describe the present state. Wear occurs only after a confirmed successful action, and failure creates a comprehensible mechanical cause rather than an arbitrary disappearance.

Maintenance now demonstrates the separation between an object's past and present. Repair restores a component's condition and records who performed the work, but it does not pretend that a different component was used or rewrite the tool's construction record.

Maintenance should be deliberate, legible, and materially grounded. The player sees which component is damaged, what matching part is required, and why the tool becomes usable again. Failure therefore creates a recoverable logistical problem rather than silently deleting a meaningful possession.

Component replacement makes the distinction between identity and composition explicit. A tool can receive a new head, handle, or binding without becoming an unrelated object: its instance identity and original origin remain continuous while its current construction truthfully changes.

Replacement must preserve both sides of that change. The active component record explains what the tool contains now, while the replacement record remembers what was removed, what was installed, who performed the work, and whether anything was recovered. A damaged part is not silently converted into a pristine fungible item merely because the inventory system cannot represent its damage.

Disassembly completes an object's active lifecycle without erasing its existence. The usable instance can disappear while the civilization retains a structured record of what it was, how it had changed, who dismantled it, and what could truthfully be recovered.

Recovery must respect the representations the game actually supports. A full-condition component can return to a fungible inventory stack; a damaged component cannot become pristine merely because the current inventory lacks unique component condition. Unknown history likewise produces no fictional parts.

Every installed component should matter in a way the player can understand. The head determines productive efficiency, the handle changes how quickly the tool can be used, the binding expresses stability, and the weakest component limits overall quality. Presentation and gameplay consume the same calculation authority so an explanation never disagrees with the result.

Real-time responsiveness and simulated labor time are deliberately separate. Better handling can make an action finish sooner for the player without silently accelerating days, hunger, seasons, events, or settlement economics. Simulated-time changes require their own later design decision.

Broader material recovery, damaged-component instances, handle wear, naming, and engraving remain future systems. Those features should transform or interpret the existing instance and its recorded components rather than replacing them with parallel item representations.
