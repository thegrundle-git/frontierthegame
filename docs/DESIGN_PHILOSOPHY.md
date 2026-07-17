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

Death, succession, descendants, biographies, relationship memories, and generated life stories are future systems. The current foundation records durable facts while the survivor is alive; it does not yet resolve or narrate a completed life.
