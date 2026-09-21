# Browser smoke-test checklist

Run after `npm run build` and `npm run preview`, or during development with `npm run dev`.

- [ ] Page opens without a backend, login, network service, analytics prompt, or console crash.
- [ ] Canvas art appears; if `public/assets/courtyard.png` is absent, the fallback courtyard art appears and the game remains playable.
- [ ] The DOM accessibility panel shows the same scene title, story text, prompt, and choices as the visual game state.
- [ ] Keyboard: Tab reaches every choice and utility button; Enter or Space activates focused buttons; focus moves to the new scene heading after each choice.
- [ ] Mouse/touch: all choice and utility buttons are large enough to activate comfortably on desktop and a narrow mobile viewport.
- [ ] Reduced motion: the “Reduce motion” control stops non-essential sprite tweening, and the OS `prefers-reduced-motion` setting is respected on first load.
- [ ] Safe paths: play one route each for private support, trusted-adult help, safe redirection, and doing nothing.
- [ ] Reflection: each ending includes a short reflection prompt and a replay button.
- [ ] Reset/replay: “Reset safely” returns to the first scene without asking for personal data.
- [ ] Content boundaries: no combat, graphic imagery, public chat, ads, accounts, tracking, analytics, therapy claims, diagnostic claims, or child-submitted personal stories appear.
