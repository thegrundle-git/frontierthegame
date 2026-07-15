# Development Notes

## Architecture

Use resources whenever possible.

Avoid hardcoded content.

---

## UI

Growing panels should scroll rather than resize.

Journal and Crafting share Detail Tabs.

Inventory should always remain scrollable.

---

## Content

Each biome owns:

- Loot
- Events
- Discoveries
- Landmarks

---

## Future

Narrative Generator should build stories from reusable templates.

Legacy system should preserve civilization history.

---

## Living World Conventions
Visited locations belong to civilization-level persistent state.
First-visit writing belongs in LocationData, not hardcoded travel logic.
Landmarks and events are separate resources.
A world event may reveal a landmark through matching stable IDs.
Journal tabs should appear when their underlying collection gains content.
Persistent collections must use empty fallbacks for compatibility with older saves.
Early startup messages must be queued until GameUI exists.
Landmark resources must be inspected after saving when a linked field appears blank at runtime.
Data bugs can resemble code bugs; verify .tres values before restructuring systems.
Remove diagnostic prints before WCP.
Never add duplicate helper functions while debugging; modify the existing function.
###Debugging Lesson

The Abandoned Campsite landmark initially failed because its event_id was blank in the saved landmark resource.

The code path was functioning correctly.

When a data-driven feature fails:

Confirm the database count.
Confirm the correct resource path.
Confirm the loaded resource type.
Print the actual runtime field values.
Inspect the .tres file if the Inspector value does not persist.

## Discovery and Action Lessons

* A discovery should lead toward new possibilities whenever practical.
* Discovery journal entries must resolve their resources through DiscoveryDatabase.
* DiscoveryDatabase requires a direct get_discovery() lookup method.
* Experience-based progress must be stored in persistent civilization data.
* Older saves require safe fallback values for all new fields.
* Knowledge-gated buttons should refresh immediately after discovery unlocks.
* A Script resource cannot call non-static instance methods directly.
* Action completion scripts must be instantiated before perform() is called.
* Dynamically called action methods should return a value safely through Variant before Boolean conversion.
* Action scripts should remain stateless unless persistent state is intentionally stored elsewhere.
* Narrative text and mechanical reward text should remain separate.
* Temporary debug prints must be removed before WCP.
