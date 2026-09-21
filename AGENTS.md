# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Godot 4.x project entry point is `project.godot` -> `scenes/main.tscn`.
- Scenario content is data-driven in `data/scenarios/hallway_helpers.json`; keep content separate from state/presentation scripts under `scripts/`.
- Run `python3 -m unittest discover -s tests` for contract tests. If Godot is installed, also smoke-check with `godot4 --headless --path . --quit-after 1`, `godot4 --headless --path . --script tests/godot_visual_world_smoke.gd`, and `godot4 --headless --path . --script tests/godot_interactive_smoke.gd` (or `godot` instead of `godot4`).
- Procedural 3D presentation lives in `scripts/playful_school_world.gd`; keep 3D, fallback, asset provenance, and performance notes aligned with `README.md`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
