# Browser smoke-test checklist

Run after `npm run build` and `npm run preview`, or during development with `npm run dev`.

- [ ] Page opens without a backend, login, network service, analytics prompt, or console crash.
- [ ] The canvas shows the procedural layered courtyard: sky gradient, perspective ground, atmospheric plates, friendly avatars, and a readable chapter panel; no remote asset request is required.
- [ ] The DOM accessibility panel shows the same scene title, story text, prompt, and choices as the visual game state.
- [ ] Keyboard: Tab reaches every choice and utility button; Enter or Space activates focused buttons; focus moves to the new scene heading after each choice.
- [ ] Mouse/touch: all choice and utility buttons are large enough to activate comfortably on desktop and a narrow mobile viewport.
- [ ] Reduced motion: the “Reduce motion” control stops non-essential sprite tweening and scene fades, and the OS `prefers-reduced-motion` setting is respected on first load.
- [ ] Safe paths: play one route each for private support, trusted-adult help, safe redirection, and doing nothing.
- [ ] Reflection: each ending includes a short reflection prompt and a replay button.
- [ ] Reset/replay: “Reset safely” returns to the first scene without asking for personal data.
- [ ] Responsive framing: at desktop width the canvas and DOM panel sit side by side; at a narrow mobile width they stack without horizontal scrolling, clipped choices, or unreachable controls.
- [ ] Content boundaries: no combat, graphic imagery, public chat, ads, accounts, tracking, analytics, therapy claims, diagnostic claims, or child-submitted personal stories appear.
