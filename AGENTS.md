# Frontier Development Instructions

## Project

Frontier is a Godot 4.7 game written in GDScript.

It is a civilization-building life simulation focused on discovery, memory,
relationships, history, and legacy. Survival is the opening stage rather than
the entire game.

## Design principles

- Every major system should create stories, not only resources.
- The world should follow understandable, common-sense rules.
- Prefer reusable systems over isolated mechanics.
- Knowledge should be discovered, recorded, inherited, and sometimes lost.
- History and relationships should emerge from remembered events.
- Character death should continue the civilization's story rather than act as
  a conventional failure state.
- Do not invent major gameplay or lore decisions while implementing code.
- Preserve the existing design unless the task explicitly changes it.

## Coding rules

- Use Godot 4.7-compatible GDScript.
- Match the existing repository structure and naming conventions.
- Prefer typed variables, parameters, and return values.
- Keep gameplay logic outside UI scripts whenever practical.
- Avoid tightly coupling managers, scenes, and UI nodes.
- Reuse existing signals and data Resources before adding parallel systems.
- Do not rename files, nodes, signals, or public methods unless requested.
- Do not perform unrelated refactors.
- Do not silently change save-data formats.
- Explain any save compatibility concerns before implementing them.

## Workflow

Before editing:

1. Inspect the relevant scenes, scripts, Resources, and documentation.
2. Summarize the current implementation.
3. State which files need to change.
4. Identify likely regressions or save compatibility concerns.

After editing:

1. Run available validation or tests.
2. Report every changed file.
3. Summarize the behavior added or changed.
4. Report anything that could not be tested.
5. Do not commit, push, merge, or open a pull request unless explicitly asked.

## Documentation

When a change affects architecture or design:

- Identify the documentation files that should be updated.
- Remind the project owner to update `docs/DESIGN_PHILOSOPHY.md` when
  appropriate.
- Do not replace deliberate design language with generic technical wording.

## Scope control

For initial tasks:

- Make the smallest change that proves the feature works.
- Avoid building speculative future systems.
- Do not add dependencies or plugins without explicit approval.