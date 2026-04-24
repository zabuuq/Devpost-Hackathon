# Devlog post brief — Iteration 4 (viewport + bug sweep)

Post this as a new devlog on the itch.io page for **Battlestations: Nebula** (`zabuuq/battlestations-nebula`). Corresponds to build **#1634061**, pushed 2026-04-24.

## Where to post

itch.io dashboard → Battlestations: Nebula → **Edit game** → **More** → **Devlog** → **Create new post**.

Set visibility to public. Attach to the html5 release channel if itch offers that option; otherwise leave unlinked.

## Title

```
Your monitor is not a postage stamp
```

## Body (paste as-is)

Until today, the game shipped with Godot's default 1152×648 viewport and no stretch mode. On a 4K monitor that meant the UI rendered at 1152×648 and then sat there in a tiny window of pixel-perfect indifference. Buttons read as small. Text read as smaller.

That's fixed.

The project now locks to 1600×900 with canvas_items stretch and expand aspect. Resize the browser and the UI scales with it. The itch.io page declares the same dimensions to the embed frame, so the default view is already the right shape.

Also fixed:

**The Cruiser stops lying about forward cost.** Rotate with Q or E, then move. The 0.5 pts / 25 energy forward discount now tracks the new facing. Before this, "forward" was anchored to whichever way the Cruiser was pointing when you clicked Move. That was wrong for a while. Cruisers are like that.

**Ships stop cheating on their first turn.** Energy regen now clamps at max_energy. Before, every ship showed up to turn 1 at max+50. The math lied. Now it doesn't.

**The Ship Panel stops contradicting itself.** Select a ship, and the "Click a ship on the Command Grid to select it" prompt no longer renders behind the populated panel. You get one thing or the other, not both.

Live now. Build #1634061.

## Voice / formatting notes (for Cowork verification)

- Voice: Gallows Deadpan. Dry, second person, understated.
- No em dashes anywhere. Use en dashes, commas, or periods instead.
- No LLM clichés ("dive into", "delve", "it's worth noting", "in conclusion", etc.).
- ~255 words. Don't pad.
- Markdown bolds on the three lede phrases are intentional — keep them.
- Don't add a "what's next" section. The post ends on "Build #1634061."

## Context you may need

- Build **#1634061** on the `html5` channel, pushed via `butler push ./export/web zabuuq/battlestations-nebula:html5`. Replaces the prior live build **#1632951** (Iteration 3 nebula build).
- Viewport fix lives in `project.godot` (`[display]` section, four keys).
- Cruiser forward-cost fix is in `scripts/gameplay/action_resolver.gd` (`resolve_move`) and `scripts/gameplay.gd` (`_update_move_preview`). Both now pass post-rotation facing to `calc_move_cost`.
- Energy cap fix is in `scripts/gameplay/turn_manager.gd` (`turn_start`) — `mini(current + 50, max_energy)`.
- Ship Panel label fix is in `scripts/ui/ship_panel.gd` — cached `_empty_label`, toggled in `show_ship` / `show_enemy_ship` / `clear_ship`.
- itch.io Viewport dimensions field was updated to 1600 × 900 on the live page during this deploy.

## After posting

- Verify the post renders correctly (bolds, paragraph breaks, no stray em dashes).
- Grab the devlog URL and drop it back to Jason so it can be linked from Devpost if useful.
