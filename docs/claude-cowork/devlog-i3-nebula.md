# Devlog post brief — Iteration 3 (nebula build)

Post this as a new devlog on the itch.io page for **Battlestations: Nebula** (`zabuuq/battlestations-nebula`). Corresponds to build **#1632951**, pushed 2026-04-24.

## Where to post

itch.io dashboard → Battlestations: Nebula → **Edit game** → **More** → **Devlog** → **Create new post**.

Set visibility to public. Attach to the html5 release channel if itch offers that option; otherwise leave unlinked.

## Title

```
The nebula stops being a rumor
```

## Body (paste as-is)

Until tonight, every "hide your ships in the nebula" line in the description was a vibe, not a fact. The grids were flat dark blue. The menus were flat dark blue. The screen read "deep space" the way a parking lot reads "deep space."

That's fixed.

Real nebula now renders on every screen. Splash, menu, fleet placement, both gameplay grids, victory. Cloud mass in the center, coral rim, stars scattered across the navy edges. Your fleet sits inside it. The enemy is somewhere in there too.

**Probe behavior flipped.** Before: probing a region painted a glowing cyan over it, which looked like fog rolling in. Now probing punches a darker hole in the nebula, like you're scrubbing a window clean. Same intel, opposite vibe. The cognitive model was wrong before, and now it isn't.

**Palette sampled from the actual texture.** Titles, accents, hit warnings, and ship colors all pulled from the nebula's family. Teal where the cloud is teal, coral where the rim is coral, warm orange where the bright star is. The ships still pop because they're saturated above the cloud. Selection yellow stays yellow because that's a UI signal, not an aesthetic.

Also: a destroyed ship next to a living ship no longer renders on top of it (z-order bug, present since combat shipped). And the title now reads "Battlestations:" on one line and "NEBULA" on a bigger line below, which is how the words have always wanted to sit.

Build is ~14% bigger. Worth it.

## Voice / formatting notes (for Cowork verification)

- Voice: Gallows Deadpan. Dry, second person, understated.
- No em dashes anywhere. Use en dashes, commas, or periods instead.
- No LLM clichés ("dive into", "delve", "it's worth noting", "in conclusion", etc.).
- ~265 words. Don't pad.
- Markdown bolds on the three lede phrases are intentional — keep them.
- Don't add a "what's next" section. The post ends on "Worth it."

## Context you may need

- Build **#1632951** on the `html5` channel, pushed via `butler push ./export/web zabuuq/battlestations-nebula:html5`.
- The palette referenced ("Teal where the cloud is teal…") is documented in `docs/color-scheme.md`.
- The "z-order bug, present since combat shipped" was fixed in `scripts/ui/grid_renderer.gd` — `_draw_command_ships()` now renders wreckage in a first pass and living ships in a second pass.
- The two-line title change applies to `splash.tscn`, `main_menu.tscn`, and `victory.tscn`.

## After posting

- Verify the post renders correctly (bolds, paragraph breaks, no stray em dashes).
- Grab the devlog URL and drop it back to Jason so it can be linked from Devpost if useful.
