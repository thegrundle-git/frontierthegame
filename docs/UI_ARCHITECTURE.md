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

Equipment Details, world-event decisions, Legacy Summary, and Succession are modal overlays. They may capture focus and keyboard cancel, but they do not enter workspace history.

While a modal is visible, the underlying workspace must not respond to the same cancel input. Closing a modal restores focus without silently changing the workspace beneath it.

## Data and Refresh Ownership

Navigation never mutates gameplay state. `GameUI` remains responsible for requesting the relevant presentation refresh when a routed destination opens:

* Storage refreshes when `camp.storage` opens.
* `CraftingUI` refreshes when `camp.crafting` opens.
* Overview consumes its existing presentation state.

Future UI extraction should keep gameplay rules in managers, actions, services, and Resources. Screens should receive or query presentation-ready state and emit player intent through signals.

## Layout Rules

Workspace content must remain below the persistent Header and Camp navigation regions. Variable content must scroll inside bounded containers rather than expanding the overall interface.

New workspaces should reuse shared navigation and content bounds. They should not introduce another independent full-screen background, Back convention, or keyboard-cancel implementation without an architectural reason.

## Current Boundary and Future Migration

This foundation currently routes Camp Overview, Storage, and Crafting. Crafting is now a dedicated workspace scene rather than an embedded `GameUI` panel. The foundation does not yet restructure the main HUD, Journal, or modal scenes.

Recommended migration order:

1. Convert equipment management from a large modal into a Camp workspace while retaining small confirmation dialogs as modals.
2. Introduce reusable workspace headers, empty states, list/detail layouts, and bounded content containers.
3. Centralize visual tokens such as spacing, minimum control sizes, typography, and responsive breakpoints.
4. Replace broad UI refreshes with focused state-change signals where profiling and complexity justify it.

Until those migrations occur, new features should extend the existing routing boundary instead of creating parallel navigation systems.
