# Devlog post brief — Iteration 7 (target + command grid intel polish)

Post this as a new devlog on the itch.io page for **Battlestations: Nebula** (`zabuuq/battlestations-nebula`). Corresponds to build **#1636456**, pushed 2026-04-25.

## Where to post

itch.io dashboard → Battlestations: Nebula → **Edit game** → **More** → **Devlog** → **Create new post**.

Set visibility to public. Attach to the html5 release channel if itch offers that option; otherwise leave unlinked.

## Title

```
The grids stop forgetting
```

## Body (paste as-is)

Six small fixes to what the two grids show in Battlestations: Nebula. All in the same direction: less hidden when you've earned the intel, more hidden when you haven't.

**Misses leave a mark.** Fire blind into empty space, a red X stays there. Next turn it fades to gray. Stays gray. The grid stops pretending you didn't already shoot at that cell. Probe over it and the X clears. Land a hit through it and the X clears.

**The Command Grid stops pretending nothing happened on the opponent's turn.** When the other player fires a hit on one of your ships, your Command Grid shows a red dot at the cell. A near miss adjacent to one of your ships shows an orange X. Full intensity for the turn after the shot. Faded next turn. Gone the turn after. A random miss in some empty corner of the grid still doesn't show. That's noise.

**Probes leave a footprint.** Cells you've previously scanned keep a thin pale-blue border on the Target Grid after the probe expires. You can see where you've already looked without re-probing. Active coverage takes precedence: scan the same cell again and the border vanishes under the live overlay.

Plus: probing a destroyed ship reveals its wreckage where the probe touches. Blind hits on a ghost cell preserve the rest of the ghost. Only the hit cell takes the hit. And the Command Grid now traces a red contour around any opponent probe area that overlaps one of your ships, so you know when you're being watched and exactly where.

Live now. Build #1636456.

## Voice / formatting notes (for Cowork verification)

- Voice: Gallows Deadpan. Dry, second person, understated.
- No em dashes anywhere. Use en dashes, commas, or periods instead.
- No LLM clichés ("dive into", "delve", "it's worth noting", "in conclusion", etc.).
- ~280 words. Don't pad.
- Markdown bolds on the three lede phrases are intentional — keep them.
- Don't add a "what's next" section. The post ends on "Build #1636456."

## Context you may need

- Build **#1636456** on the `html5` channel, pushed via `butler push ./export/web zabuuq/battlestations-nebula:html5`. Replaces the prior live build **#1635102** (Iteration 5 + 6 controls + battle log). Patch savings 99.74% (182.85 KiB patch over 234.80 KiB fresh data).
- **Blind hit on ghost cell (I7-1):** original spec was "blind hit clears the ghost"; reversed during checkpoint to "miss clears the ghost, hit preserves it." Renderer-side filter in `scripts/ui/grid_renderer.gd::_draw_target_cells` decides ghost visibility per cell by exact `record.ship == fog` match — a miss nulls the cell's ship reference, removing it from the ghost permanently.
- **Wreckage in newly probed areas (I7-2):** `scripts/gameplay/action_resolver.gd::resolve_probe` now scans destroyed opponent ships in addition to living, writing wreckage records on probe-overlap cells and ghost references on the rest of the ship's hull.
- **Miss indicators on Target Grid (I7-3):** new `has_miss` and `miss_turn` fields on `CellRecord`; `_draw_miss_x` glyph in the renderer; per-turn fade keyed on `miss_turn == current_turn_number`. Misses inside an active probe area clear at the probing player's next turn-start (handled in `turn_manager.gd::age_cell_records`).
- **Historical probe overlay (I7-4):** new `was_probed` flag on `CellRecord`, set in `CellRecord.make_probe`. Aging logic preserves the flag after `has_probe` clears so the cell record stays alive. Renderer draws a 2px `Color(0.5, 0.7, 0.9, 0.25)` interior border on `was_probed && !has_probe` cells, below the active probe fill.
- **Command Grid incoming fire (I7-5):** `grid_renderer.gd::_draw_incoming_fire()` reads `GameState.players[current_player].battle_log` for `owner == 1` laser/missile entries. Fade reference is `GameState.players[1 - current_player].turns_played` (advances every cycle, independent of whether the opponent fires).
- **Command Grid opponent probe boundary (I7-6):** `grid_renderer.gd::_draw_opponent_probe_boundary()` reads opponent `cell_records`, groups `has_probe` cells into 4-connected components, and emits a 2px `Color(1.0, 0.3, 0.3, 0.7)` contour only around components that overlap one of the viewer's living-ship cells. `gameplay.gd::_on_move_confirmed` calls `command_renderer.refresh()` so the gate re-evaluates after a move.
- **Followups landed in this build (not in original I7 plan):** ghost FogShipRecord freeze (gate updates on `record.has_probe` instead of `record.ship != null` in `_refresh_opponent_probes_after_regen` and `_refresh_probe_records_for_ship`) so opponent moves and shield regen can't leak their current position into ghost cells.

## After posting

- Verify the post renders correctly (bolds, paragraph breaks, no stray em dashes).
- Grab the devlog URL and drop it back to Jason so it can be linked from Devpost if useful.
