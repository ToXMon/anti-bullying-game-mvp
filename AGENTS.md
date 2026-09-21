# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- The browser MVP is a static Phaser + TypeScript app; see `README.md` for setup, architecture, safety boundaries, deployment, and `docs/browser-smoke-test.md` for manual browser checks.
- Use `npm run build` as the main local verification; it runs typecheck, automated scenario tests, and the production build.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
