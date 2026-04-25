# Devlog post brief — Iterations 5 + 6 (controls rework + battle log overhaul)

Post this as a new devlog on the itch.io page for **Battlestations: Nebula** (`zabuuq/battlestations-nebula`). Corresponds to build **#1635102**, pushed 2026-04-24. This build bundles two iterations' worth of work — Iteration 5 (camera and controls rework) was never deployed standalone, and Iteration 6 (battle log overhaul plus extended victory stats) rode along.

## Where to post

itch.io dashboard → Battlestations: Nebula → **Edit game** → **More** → **Devlog** → **Create new post**.

Set visibility to public. Attach to the html5 release channel if itch offers that option; otherwise leave unlinked.

## Title

```
Scroll works. The log remembers. Blind kills stay blind.
```

## Body (paste as-is)

Two iterations worth of polish landed in one build. Controls got rebuilt from the ground up, the battle log learned to remember, and the game got more disciplined about what it tells each player.

**Scroll does what you expect now.** Plain scroll wheel pans vertically. Shift+scroll pans horizontally. Ctrl+scroll zooms at the cursor, not at some abstract camera center. Left-click-drag pans the grid. Middle-click does nothing. Camera position and zoom also persist per player across turns, so switching back to your grid doesn't erase where you were looking.

**The battle log remembers.** Per player, capped at 200 entries, newest first. Turn dividers cap each turn from above so scrolling down reads like walking back through the match. Used to be the log reset every turn, replayed the opponent's last turn, and pretended the rest of the game hadn't happened. Fixed.

**The game stays quiet about what you haven't earned.** Opponent actions replay as Enemy, ship type hidden. Empty probes don't show. Misses only show when adjacent to one of your ships, and the log names which one (plural if more than one of the same type was in range). When the enemy connects, the log tells you which of your ships took it. Fire without probe coverage, destroy something, the log says Hit. No ship name. No destroy color. No explosion sound. Defenders know their own fleet. Shooters without probes don't. The game keeps that line clean.

**Shields down!** is a new line. Probed hit that drops shields to exactly zero, the log says so. Overflow into armor, it says how much.

Also new: pick up a placed ship during fleet placement by clicking it. After probe, laser, or missile, the game stays on the Target Grid and auto-switches the left panel to the Battle Log. The victory screen gained four rows: laser shots, missile shots, total damage, total misses.

Live now. Build #1635102.

## Voice / formatting notes (for Cowork verification)

- Voice: Gallows Deadpan. Dry, second person, understated.
- No em dashes anywhere. Use en dashes, commas, or periods instead.
- No LLM clichés ("dive into", "delve", "it's worth noting", "in conclusion", etc.).
- ~335 words. Don't pad.
- Markdown bolds on the four lede phrases are intentional — keep them.
- Don't add a "what's next" section. The post ends on "Build #1635102."

## Context you may need

- Build **#1635102** on the `html5` channel, pushed via `butler push ./export/web zabuuq/battlestations-nebula:html5`. Replaces the prior live build **#1634061** (Iteration 4 viewport + bug sweep). Iteration 5 was never deployed standalone; this build picks up both I5 and I6 work.
- **Controls rework (I5-1):** lives in `scripts/gameplay.gd::_handle_grid_input`. Plain/Shift/Ctrl + scroll wheel for pan-vert / pan-horiz / zoom-at-cursor; left-click-drag with a 4px threshold switches between pan and select; middle-click handling removed entirely.
- **Per-player camera persistence (I5-2):** `GameState.players[n].command_camera` / `target_camera` dicts hold `{position, zoom}`. Saved on every pan/zoom and on `_exit_tree`, restored on `_ready`, reset on new game.
- **Probe clicks off-grid (I5-3), partial-probe ship selection (I5-4), pickup placed ship (I5-5), stay-on-target after action (I5-6):** targeted tweaks in `scripts/gameplay.gd` and `scripts/fleet_placement.gd`.
- **Persistent battle log (I6-1):** `GameState.players[n].battle_log` (Array, capped at 200 including dividers), with helpers `append_battle_log` and `append_battle_log_divider`. Render via `battle_log.gd::render_from_state()` in reverse-chronological order. Top entry uses `RichTextLabel` + BBCode for bold emphasis; scrollbar hidden via `SCROLL_MODE_SHOW_NEVER`.
- **Opponent-side filters (I6-2):** `scripts/gameplay.gd::_filter_opponent_entry`. Per-instance ship collection drives plural naming ("Destroyers"). `Nothing to report.` fallback fires when opponent's `turns_played > 0` but no entries survive filtering.
- **Shooter-side polish (I6-3) + defender hit/destroy naming:** `scripts/ui/battle_log.gd::_format_fire` and `_build_entry_label`. Explosion SFX gated on `has_probe` in `audio_manager.gd::play_action_sfx`.
- **Turn counter fix:** per-player `turns_played` field on `GameState`, incremented in `turn_manager.gd::turn_end()` before the swap. Divider push moved from turn START to turn END so dividers cap each turn from above in the reverse-chronological render.
- **Extended victory stats (I6-4):** 2-column `GridContainer` per player in `scenes/victory.tscn` with six key/value rows. New counters live in `GameState.players[n].turn_stats` and increment inside `ActionResolver.resolve_laser` / `resolve_missile`.
- No changes to the itch.io Viewport dimensions field this round. That remains 1600 × 900 from Iteration 4.

## After posting

- Verify the post renders correctly (bolds, paragraph breaks, no stray em dashes).
- Grab the devlog URL and drop it back to Jason so it can be linked from Devpost if useful.
