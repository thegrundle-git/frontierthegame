# Frontier UI Architecture

This document defines the durable structural rules for Frontier's interface. It describes how screens cooperate, not the final visual style.

## Interface Layers

Frontier UI belongs to one of four categories:

1. **HUD** — persistent world and survivor context.
2. **Workspace** — a primary place where the player performs a category of work.
3. **Modal** — a temporary decision or inspection layered over the current workspace.
4. **Notification** — transient narration or feedback that does not own navigation.

A feature should identify its category before adding nodes or visibility logic.

## Workspace Navigation

Workspaces use stable string IDs and are coordinated by a router owned by their integration scene. They do not directly hide or reveal sibling screens.

The first implemented workspace group is Camp:

```text
camp.overview
camp.storage
camp.crafting
camp.equipment
```

`UIRouter` owns:

* mutually exclusive workspace visibility;
* navigation history;
* the current workspace ID;
* initial focus entry points;
* clearing workspace state when the player leaves its context.

The router is intentionally not an autoload. Navigation remains local to the interface that owns the screens, avoiding a global dependency between gameplay scenes and presentation.

## Navigation Controls

The persistent Camp navigation bar exposes peer destinations. A selected destination is visibly disabled so the current location remains legible.

Back buttons and keyboard cancel share the router's history. Keyboard cancel does nothing on the Camp Overview because leaving Camp is an explicit gameplay transition, not merely UI navigation.

## Modal Boundaries

World-event decisions, Legacy Summary, Succession, and irreversible confirmation dialogs are modal overlays. They may capture focus and keyboard cancel, but they do not enter workspace history.

Equipment Details is now an embedded workspace panel rather than a modal. Only its disassembly confirmation interrupts the workspace.

While a modal is visible, the underlying workspace must not respond to the same cancel input. Closing a modal restores focus without silently changing the workspace beneath it.

## Data and Refresh Ownership

Navigation never mutates gameplay state. `GameUI` remains responsible for requesting the relevant presentation refresh when a routed destination opens:

* Storage refreshes when `camp.storage` opens.
* `CraftingUI` refreshes when `camp.crafting` opens.
* `EquipmentUI` rebuilds stable instance selection when `camp.equipment` opens.
* Overview consumes its existing presentation state.
* `JournalUI` refreshes durable and reference-oriented Journal views when `exploration.journal` opens.

Future UI extraction should keep gameplay rules in managers, actions, services, and Resources. Screens should receive or query presentation-ready state and emit player intent through signals.

Storage is now fully scene-owned. Its Pack and Camp lists use stable metadata tokens, while transfer buttons derive their state from one selected side and token. Runtime control construction is not part of the workspace pattern.

Equipment uses scene-owned source sections populated with reusable `EquipmentSlot` controls. Variable slot collections may be created at refresh time, but selection remains keyed by stable equipment instance ID. Icon absence must degrade to a readable textual fallback, and hover-only information must also remain available through focusable controls and the persistent detail pane.

## Layout Rules

Workspace content must remain below the persistent Header and Camp navigation regions. Variable content must scroll inside bounded containers rather than expanding the overall interface.

New workspaces should reuse shared navigation and content bounds. They should not introduce another independent full-screen background, Back convention, or keyboard-cancel implementation without an architectural reason.

## Environmental Presentation

`GameUI` owns one environment-background selection boundary. Forest, River, and Meadow resolve from `GameManager.current_location`; any active Camp route resolves to Home. Routed workspaces reuse that selected texture in their scene-owned `Background` node rather than inventing independent location logic or allowing the exploration interface to show through.

Standard content panels may use restrained translucency over the artwork. Modal decisions remain more opaque, and `CampNavigation` is fully opaque because navigation labels must not compete with the underlying location header. Backgrounds and translucent surfaces never carry gameplay state, alter navigation, or reduce text opacity.

XP notifications are transient notification-layer controls. They ignore mouse input, remain viewport-clamped, stack when multiple skills gain XP together, and free themselves after their rise-and-fade animation. Exact Chronicle messages and skill state remain authoritative.

## Current Boundary and Future Migration

This foundation currently routes Camp Overview, Storage, Crafting, Equipment, and the exploration Journal. Storage, Crafting, Equipment, and Journal are scene-owned workspaces rather than runtime-built or embedded `GameUI` panels. Chronicle narration deliberately remains on the exploration surface while durable and reference-oriented records live in `JournalUI`.

Recommended migration order:

1. Introduce reusable workspace headers, empty states, list/detail layouts, and bounded content containers.
2. Centralize visual tokens such as spacing, minimum control sizes, typography, and responsive breakpoints.
3. Replace broad UI refreshes with focused state-change signals where profiling and complexity justify it.
4. Move repair and replacement mutations behind gameplay-service APIs before expanding equipment mechanics.

Until those migrations occur, new features should extend the existing routing boundary instead of creating parallel navigation systems.
