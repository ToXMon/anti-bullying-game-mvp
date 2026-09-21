# Anti-Bullying Game MVP

A privacy-first, replayable Phaser + TypeScript browser game for ages 8-12 that helps players practice safe bystander action.

This branch implements a focused vertical slice: one calm, non-graphic school scenario with data-driven choices, respectful consequences, short reflection prompts, trusted-adult escalation, and replay. It is a static app with no backend, accounts, ads, analytics, tracking, or personal-data collection.

## Setup

Requirements:

- Node.js 20+ recommended
- npm 10+ recommended

Install dependencies:

```sh
npm install
```

## Local play

Start the development server:

```sh
npm run dev
```

Open the local URL printed by Vite. The game is playable with keyboard, mouse, or touch-sized controls. There is no time pressure.

## Verification scripts

```sh
npm run typecheck
npm run test
npm run build
```

`npm run build` runs typecheck, automated scenario tests, and a production Vite build.

## Browser test instructions

Use the manual checklist in [`docs/browser-smoke-test.md`](docs/browser-smoke-test.md). It covers keyboard navigation, screen-reader-oriented DOM text, touch target size, reduced motion, fallback art, replay, and safety boundaries.

## Architecture

- `src/content/scenario.ts` — scenario content data: scenes, choices, reflection prompts, and trusted-adult notes.
- `src/domain/` — pure TypeScript state machine, validation, and scenario tests.
- `src/ui/accessibilityOverlay.ts` — semantic DOM accessibility overlay with buttons, screen-reader labels, focus management, and large touch targets.
- `src/game/GameScene.ts` — Phaser presentation layer for calm visual context and graceful missing-asset fallback art.
- `src/persistence/settingsStore.ts` — local settings persistence for reduced motion only; no progress, names, stories, or personal data are saved.
- `src/main.ts` — composition root connecting content, state, persistence, DOM UI, and Phaser.

The scenario content is intentionally separate from state, presentation, and persistence so a later deployment can update or review content without changing the engine.

## Safety boundaries

The MVP is designed for ages 8-12 and includes:

- one 8-12 minute bystander-practice scenario;
- 3-5 decision-point scenes;
- private support, trusted-adult help, safe redirection, and an understandable do-nothing path;
- respectful, non-shaming consequences;
- short reflection prompts;
- clear trusted-adult escalation and replay.

It intentionally excludes combat, graphic bullying imagery, public chat, ads, accounts, tracking, analytics, therapy claims, diagnostic claims, child-submitted personal stories, secrets, network services, and backend requirements.

## Static deployment

Build the static site:

```sh
npm run build
```

Deploy the generated `dist/` directory to any static host, such as GitHub Pages, Netlify, Cloudflare Pages, or an S3-compatible static bucket. Vite is configured with `base: './'` so the build can be served from a repository subpath such as GitHub Pages.

## Licensing

No third-party art assets are included. The generated fallback shapes are part of this project. Phaser is used under its upstream open-source license; review dependency licenses before publishing a final release.
