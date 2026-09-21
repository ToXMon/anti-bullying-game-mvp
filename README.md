# Anti-Bullying Game MVP

**Kindness Crew: Hallway Helpers** is a privacy-first, replayable Godot 4 vertical slice for ages 8-12. It helps players practice safe bystander action through a short fictional school scenario with private support, trusted-adult help, safe redirection, and the option to do nothing.

## Current slice

- One 8-12 minute scenario with 4 decision points.
- Distinct, non-shaming consequences and short reflections after each choice.
- Replay from the ending or the header.
- Clear trusted-adult path available from both choices and the help button.
- No combat, graphic imagery, public chat, ads, accounts, tracking, therapy claims, diagnostic claims, or child-submitted personal stories.
- No personal data is stored. Analytics are off by default; local persistence is limited to accessibility/privacy settings in `user://settings.cfg` (reduced motion and visual-quality toggles).

## Setup

1. Install Godot 4.x from <https://godotengine.org/download>.
2. Open this repository as a Godot project, or run:
   ```sh
   godot4 --path .
   ```
   Some systems install the binary as `godot` instead of `godot4`.
3. Press **Play**. The main scene is `res://scenes/main.tscn`.

The project is resilient to missing optional art or 3D rendering: if `res://assets/hallway_helpers.png` is absent, the game uses an original procedural Godot 3D hallway; if 3D is unavailable (for example in headless mode), it falls back to the original procedural storybook hallway drawn with Godot controls and draw calls.

## Controls

- Mouse or touch: choose large buttons.
- Keyboard: `Tab`/arrow navigation from Godot UI, `Enter`/`Space` to activate, number keys `1`-`4` for choices.
- `R`: replay from the beginning.
- `A`: open the trusted-adult help dialog.
- Reduced motion: toggle from the header. There is no time pressure.
- World detail: toggle from the header between full playful scene detail and low-detail calm mode.

## Architecture

Content, state, presentation, and persistence are intentionally separated:

- `data/scenarios/hallway_helpers.json` — data-driven scenario content, choice effects, consequence text, and ending bands.
- `scripts/content_repository.gd` — loads scenario content and handles missing or non-object JSON gracefully.
- `scripts/game_state.gd` — in-memory route and score state; no personal data or route history is saved.
- `scripts/settings_store.gd` — local accessibility/privacy settings only; analytics remains off by default.
- `scripts/game_controller.gd` — UI presentation, keyboard/touch controls, replay, optional asset handling, and trusted-adult help.
- `scripts/playful_school_world.gd` — original procedural 3D school-world presentation, chapter camera framing, soft daylight, quality toggle, trusted-adult route cues, and 2D/headless fallback coordination.
- `scenes/main.tscn` — Godot entry scene.
- `tests/test_scenario_contract.py` — focused automated checks for the scenario contract and reachable endings.
- `tests/test_visual_contract.py` — focused automated checks for procedural visual provenance, fallback, accessibility controls, and chapter presentation.
- `tests/godot_interactive_smoke.gd` — headless Godot smoke path that simulates keyboard choices through an adult-support route, ending, reduced-motion toggle, and replay.
- `tests/godot_visual_world_smoke.gd` — headless Godot smoke path that instantiates the procedural daytime 3D world, chapter contexts, and low-detail mode.

## Visual provenance and performance

This visual pass uses original project-authored procedural Godot meshes, materials, lights, and UI styles. The Kage and ThreeUI repositories were used only as reference studies for composition, readable depth, chapter framing, component hierarchy, spacing, and stateful controls; no code, artwork, branding, assets, or text from those projects is copied. No third-party art, textures, fonts, GLB files, analytics SDKs, or network services are included.

The 3D scene keeps runtime practical by using simple primitive meshes, one active chapter prop set at a time, three lights, no physics, no particles, and no binary assets. Full detail is roughly under 110 active mesh draws on the busiest chapter; **World detail: Low** hides extra playful props and skylight panels, lowers 3D render scale, and disables MSAA. New asset payload is script text only; added binary asset size is 0 bytes.

## Visual revision rationale

Before: the branch leaned on dramatic depth treatment and film-style wording that did not fit a warm practice space for ages 8-12. After: the world is a daytime school commons with classroom, lunch, recess, and trusted-adult landmarks, toy-like avatars, playful props, and safe route tiles that make adult help visible without pressure.

## Automated tests

Run the data/behavior contract tests with Python 3:

```sh
python3 -m unittest discover -s tests
```

If Godot is available in your environment, also launch the project once to catch engine-level script errors and run the scripted interactive smoke path:

```sh
godot4 --headless --path . --quit-after 1
godot4 --headless --path . --script tests/godot_visual_world_smoke.gd
godot4 --headless --path . --script tests/godot_interactive_smoke.gd
```

## Human-playable smoke-test checklist

Use this checklist before a school pilot or moderated parent test:

1. Launch the project in Godot 4.x and confirm the title screen text appears.
2. Confirm the bright procedural 3D school world appears when no optional illustration asset exists, or the procedural 2D fallback appears when 3D is unavailable.
3. Play one route using only touch/mouse; verify all buttons are large and readable.
4. Replay and play one route using number keys `1`-`4`.
5. Choose at least one **trusted adult** option and confirm the progress line changes to "adult path tried".
6. Open the **Trusted adult help** dialog with the button and with `A`.
7. Toggle **Reduced motion** and verify choices still work without time pressure.
8. Toggle **World detail** and verify the lower-detail mode keeps the same text, choices, and trusted-adult path.
9. Try a route with **do nothing** choices and confirm feedback is non-shaming and invites replay.
10. Reach the ending card; confirm it includes a route summary, reflection prompt, and replay button.
11. Close and relaunch; confirm no route history, names, chat, or child story text was stored.

## Short demo script

1. "This is *Kindness Crew: Hallway Helpers*, a short practice game about safe bystander choices. There is no timer and no scoring that labels you good or bad."
2. Start the day and choose **Use a safe redirection** at the hallway decision. Read the consequence and reflection aloud.
3. At lunch, choose **Ask Mina if she wants adult help** to show private support leading to a trusted-adult path.
4. At the showcase, choose **Get Ms. Rivera right away** to demonstrate escalation when belongings may be taken.
5. After school, choose **Help make a plan with Ms. Rivera**.
6. Read the ending card and reflection prompt. Replay briefly and choose **Do nothing** once to show respectful, non-shaming consequences.

## Licensing

- Code in this repository is offered under the MIT License; see `LICENSE` for the terms.
- Scenario text and the included SVG icon are original project content for this MVP. Treat them as CC BY 4.0 unless a future content license states otherwise.
- No third-party art, music, fonts, accounts, analytics SDKs, or network services are included.
