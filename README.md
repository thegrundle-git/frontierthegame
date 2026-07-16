# Frontier

> *One survivor. One camp. One civilization.*

Frontier is a data-driven survival and civilization-building game being developed in Godot. The game begins with a single survivor in an untamed wilderness and follows the growth of that survivor into a thriving civilization through discovery, craftsmanship, exploration, and careful management of time.

Rather than purchasing technology or leveling through traditional RPG mechanics, civilizations in Frontier learn by interacting with the world. New discoveries emerge from observation, experimentation, and experience.

## Vision

Frontier is built around a simple idea:

> **The world should be understood before it is conquered.**

Players do not unlock progress by completing arbitrary objectives. They gather resources, make observations, discover new technologies, and gradually reshape the frontier.

Every new tool expands what is possible.

Every discovery changes how the player interacts with the world.

## Current Features

* Data-driven item system
* Data-driven crafting recipes
* Civilization-wide discovery system
* Timed action framework
* In-game clock and calendar
* Tool and equipment system
* Dynamic world actions
* Data-driven location system
* Gathering, crafting, and progression
* Git-based milestone workflow

## Technology

* Engine: Godot 4
* Language: GDScript
* Architecture: Data-driven resources with modular gameplay systems

## Current Gameplay

The current prototype allows the player to:

* Search the surrounding wilderness
* Gather basic resources
* Gain gathering experience
* Build civilization knowledge
* Discover Primitive Toolmaking
* Craft and equip a Stone Axe
* Chop trees for Wood Logs
* Advance time through timed actions

## Project Structure

```text
resources/
	actions/
	characters/
	civilizations/
	discoveries/
	items/
	locations/
	recipes/

scripts/
	actions/
	autoload/
	inventory/
	resources/
	ui/

docs/
```

## Roadmap

Current development focuses on expanding the world through:

* Additional locations
* Travel
* Weather
* Camp construction
* Hunger and survival systems
* Multiple survivors
* Settlement management
* Dynamic world simulation

See `docs/ROADMAP.md` for planned milestones.

## Project Philosophy

Frontier follows a few core principles:

* Systems before content.
* Data before hardcoded logic.
* Discoveries should feel earned.
* Time should make every decision meaningful.
* Small systems should combine to create interesting stories.

## Development Status

The project is under active development and is not yet feature complete.

Current version:

**v0.5.2-alpha1 — Physical Progression Foundation**

## License

Frontier is available under the MIT License. See `LICENSE` for details.
