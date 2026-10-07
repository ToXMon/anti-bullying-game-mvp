# Small Brave Things landing page

`index.html` is the local source snapshot for https://waxen-ether-6e5b.here.now/ (copied from `/home/opadmin/dev-harness/firstmate/.lavish/anti-bullying-game-site/index.html` on 2026-10-07). The live host injects Open Graph/Twitter metadata into the served HTML, so the HTTP response is not byte-identical to this file. This folder is the working source going forward; the old `.lavish` copy is not tracked and should not be used for future edits.

The adult-feedback CTA opens Tally form `2E2GPV` at https://tally.so/r/2E2GPV in a popup, with a direct-link fallback. The form's fields and required validation are controlled in Tally, not in this HTML. As independently checked after the owner-approved Tally API edit, the published form offers 8–9, 10–12, 13–15, and Prefer not to say, plus a required referral-source question and an optional team-member first name. The page explains these fields before opening the popup. Future form edits still require owner approval; never commit or paste API keys into files.

The Godot game in this repository and the separate Phaser worktree are existing 8–12 prototypes. Expanding the landing-page audience to ages 8–15 does not imply either game is ready for older teens.

The site embeds a locally rendered 21-second concept film at `assets/small-brave-things-concept.mp4`, with `assets/launch-poster.jpg` as its poster. The editable Hyperframes composition, original instrumental generator, and review snapshots are under `../video/sbt-launch/`; `../briefs/launch-video-brief.md` states the claim and review boundaries. The film is explanatory, not footage of teen gameplay.

To update the existing site, check its live version against the here.now API before publishing. From this folder, the here.now helper can be run with `--slug waxen-ether-6e5b` using authenticated credentials. Do not publish without explicit approval; do not commit `.herenow/state.json` or credentials. After publishing, verify the live popup and direct-link fallback on desktop and mobile.

Working brief and kickoff instructions: `../briefs/site-outreach-domain-kickoff.md`.
