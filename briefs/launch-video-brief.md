# Small Brave Things — launch-film production brief (local draft)

**Status:** locally rendered 21-second concept MP4 at `site/assets/small-brave-things-concept.mp4`, embedded in `site/index.html` with `site/assets/launch-poster.jpg`. The editable composition remains at `video/sbt-launch/`. Nothing has been published. Built from `site/index.html` and the `/brag` planning rubric; do not use the live site as a source of current copy until the local page is approved and published.

## Decision

Make a **21-second, caption-first concept film for adult caregivers**, not a product-launch claim or a simulation of a tested teen game. Use `/brag`'s **polished** tone with restrained editorial motion. Real UI source: the local landing page's illustrative lunch-table scenario and age-direction cards. Any moving scene outside that UI is a *concept illustration*, labeled as such. Existing prototypes are for ages 8–12. The 13–15 direction is a research question. Do not film, generate likenesses of, or depict distressed real children; no child names, incident reenactments, school logos, testimonials, efficacy claims, crisis claims, or fabricated gameplay. The video invites **adults only** to give feedback.

## Source-of-truth assets

- Copy, scenario, tabs, and age cards: `site/index.html` (local version, not the live URL).
- Visual system: paper `#f7f4ed`, ink `#172328`, blue `#2d5bff`, lime `#d8f36a`, coral `#ff735f`, lavender `#dedcff`; Fraunces display and DM Sans body.
- Name: **Small Brave Things**. The current landing-page mock scenario is an illustrative 8–12 example, not a playable teen build.
- Final adult CTA: **Share your perspective**. Tally form `2E2GPV` was subsequently updated with a required referral question and age band 13–15; the film itself still shows no form submission.

## Storyboard — 21 seconds, 1920×1080 landscape, 30fps

| Time | Image / motion | Settled on-screen text | Audio |
|---|---|---|---|
| 0–3s | Ink text enters on warm paper; three soft abstract shapes pause before converging. No faces, no bullying imagery. | **When a moment gets hard, what comes next?** | A warm restrained musical bed starts; no alarming hit. |
| 3–7s | Recreate the *actual local page's* illustrative lunch-table card with its exact wording; a cursor selects “Check in quietly,” then “Ask an adult for backup.” Do **not** animate a consequence, points or a real child. Tiny persistent corner label: “Illustrative 8–12 example”. | **A chance to consider a safer next step.** | Two subtle, soft selection sounds. |
| 7–12s | Recreate the three **age-direction cards** from the local HTML; reveal 8–9, 10–12, 13–15 one at a time, then hold all three. Older direction uses quiet typography, not a small-child mascot. | **Different ages need different conversations.** | Music lifts gently; each card has a low, unobtrusive cue. |
| 12–16s | Hold the 13–15 card and its research marker; reveal a simple underline rather than new gameplay. | **For teens, we’re listening first.** | Music thins; no dramatic promise. |
| 16–21s | Logo/brand in original palette; final line stays legible for at least 2.5s. Small persistent disclaimer. | **Small Brave Things** · **Parents & caregivers: share your perspective.** | Warm resolved chord and clean fade. |

Total: **3 + 4 + 5 + 4 + 5 = 21 seconds**. Keep all readable text visible at least ~0.3 seconds/word after entrance; do not cram the full age-card paragraphs into the film. Make a 9:16 reframed variant only after the 16:9 cut passes safe-area review.

## Copy-paste composition prompt for `/brag` + Hyperframes, or a motion designer

> Create a polished, 21-second, 1920×1080, 30fps, caption-first motion-graphics film for **Small Brave Things**, aimed at **parents and caregivers**, not children. Follow the five-scene storyboard above exactly and reuse the typography, colors, wording, and illustrative scenario/age cards from the current local `site/index.html`. Recreate the actual page UI as an editable composition; do not use generic game footage, stock children, a fake app-store screen, live school incident footage, or generated distress. Make the first two seconds legible and emotionally calm. Show one real illustrative UI action (selection in the existing lunch-table card) without inventing feedback or results. Distinguish ages 8–9, 10–12, and 13–15 visually without making the teens look like enlarged younger children. Persistent small label on the UI demonstration: “Illustrative 8–12 example”. Persistent small label on the teen direction: “Research question — no teen-ready prototype”. End with an adult-only invitation, “Parents & caregivers: share your perspective.” Do not show a Tally submission or claim the age-bands form is ready for teens. No clinical, therapeutic, safeguarding, anti-bullying prevention, or efficacy promise. Use an original or properly licensed warm instrumental bed and restrained soft UI SFX. Mix speech-free by default; produce a caption/transcript file for accessibility. Check font loading, contrast, text safe areas at 16:9 and 9:16, at-rest readability, title accuracy, age disclaimers, and all sources before rendering. Export an MP4 with a designed poster frame baked as frame 0 and a matching still poster.

## Optional narration (only if the owner requests voice)

> “A hard moment can leave anyone unsure. What if there were room to consider a next step? We’re exploring ideas with families across ages eight to fifteen. For teens, we’re listening first. Small Brave Things. Parents and caregivers: tell us what would feel right.”

Narration is **not** a script for a child performer. If voice is added, use an appropriately licensed adult voice, verify the 21-second timing and that the spoken words complement rather than read the screen text.

## Review gates before any public use

1. Completed: owner approved the local concept; Tally now has the 13–15 option and required referral question, verified on the published form without submitting personal data.
2. Before publishing, confirm font usage rights; the score was generated locally. Secure separate approval for hosting or any paid/third-party generation. Never send visitor data to an external renderer.
3. Completed locally: rendered and embedded the MP4, visually checked key frames and first-frame poster, verified codec/duration and browser playback metadata. Full human watch-through and any publication still require review/approval.

**Tool feasibility:** Hyperframes CLI 0.8.139 and a temporary local FFmpeg/FFprobe pair are available for this session; the composition passes `hyperframes check` with six non-blocking structural warnings. A five-scene contact sheet is in `video/sbt-launch/snapshots/contact-sheet.jpg`. The owner approved a local render after reviewing the Lavish animatic. The preview is local only; this MP4 is not public. Regenerate the original instrumental bed with `python3 video/sbt-launch/generate_score.py`. The rendered MP4 was probed at 1920×1080, 30 fps, H.264/AAC, 21.000 seconds; a settled outro frame is both the poster image and baked into frame zero.
