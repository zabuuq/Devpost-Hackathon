# Backlog — Battlestations: Nebula

Future features and ideas captured during development. Not committed to any timeline.

---

## Cut for Hackathon — Core Features

| Feature | Notes |
|---|---|
| Stealth Ship | Cloak toggle: invisible to probes while active, still hittable by direct fire. Cut when cloak mechanic complexity became clear mid-PRD session. |
| AI opponent | Satisfying AI requires real design investment. Not a quick add. |
| Networked multiplayer | Requires WebSocket relay server + state sync. Major infrastructure. |
| Persistent save / resume | Out of scope for a demo. |

---

## Cut for Hackathon — Fleet & Progression

| Feature | Notes |
|---|---|
| Points-based fleet builder | Jason returned to this 3–4 times during /scope — clearly wanted. Preset fleet for hackathon. |
| Ship upgrades / loadout customization | Tied to fleet builder. Post-hackathon. |
| Faction system | Inspired by Stars in Shadow — distinct visual identity per faction. Cool idea, not core. |
| Energy transfer between ships | Interesting tactical ability, adds system complexity. |

---

## Cut for Hackathon — Platform & UX

| Feature | Notes |
|---|---|
| Phone / small screen support | 80×20 grid doesn't translate well to small screens without significant UI rework. |
| Player messaging | Tied to networking — only makes sense with async/networked play. |

---

## Ideas Surfaced During Development

| Idea | Notes |
|---|---|
| Direct hits vs partial hits | Surfaced during /spec combat math discussion. Needs fleshing out — possible mechanic where hitting only part of a ship's cells produces partial damage vs hitting the full ship profile. |
| Click-to-pick-up during placement | Clicking an already-placed ship on the grid should pick it back up so the player can reposition it. Currently ships are locked once placed. |
| Ship naming | Allow players to name their individual ships before or during fleet placement. Would require distinguishing between the two Destroyers. |
| Stay on Target Grid after action | After firing laser/missile or launching probe, stay on Target Grid and auto-switch left panel to Battle Log so player can see results. Currently snaps back to Command Grid after every action, forcing tedious back-and-forth. |
| Ship list in left panel | Add a collapsible list of all your ships in the left panel. Click a ship name to expand and see its stats/actions (like the current ship panel). Allows selecting ships without switching to Command Grid. Only switch to Command Grid automatically if the player clicks "Move Ship." Works with the "stay on Target Grid" item above to reduce tab-switching. |
| Hide empty opponent probes in battle log | Only report an opponent's probe in the battle log if it discovers one of the player's ships. Probes that find nothing are noise and give away that the opponent is searching in your area without useful info for the player. Additionally, don't reveal which ship type launched the probe — just say "Opponent launched a probe" to avoid leaking fleet composition info. |
| Battle log: hide enemy ship type on actions | Battle log should not show which enemy ship performed an action — only what action was performed. Revealing ship types leaks fleet composition and positioning info. |
| Battle log: persist across turns | Battle log should carry over between turns so players can scroll back and review the full history. Currently resets each turn. |
| Extended victory statistics | Victory screen should display: probes launched (done), laser shots fired, missiles fired, total shots fired (lasers + missiles, done), total hits (done), total laser damage, total missile damage, total damage, total misses. Requires adding new counters to turn_stats in GameState. |
| Battle log: hide opponent misses unless near miss | Don't show opponent misses in the battle log unless the miss lands in a cell directly adjacent to one of the player's ships (a "near miss"). Random misses are noise; near misses are tactically interesting. |
| Rework map scrolling and zooming controls | New scheme: scroll wheel = scroll vertically; shift+scroll = scroll horizontally; ctrl+scroll = zoom in/out; left-click-drag on empty space = pan (must not trigger ship selection — only select on click-release without drag). Remove middle-click-drag panning. |
| Zoom centered on mouse position | Zooming in/out should center around the current mouse cursor location, not the viewport center. |
| Persist map view between turns | Map zoom level and viewing position should carry over to the player's next turn instead of resetting. Store per-player camera state in GameState. |
| Battle log: hide ship destruction on blind hits | Blind hits should only report "Hit" — do not reveal that a ship was destroyed. Destruction info is only available with active probe coverage. |
| Battle log: show shield breakdown on probed hits | When hitting an opponent ship under active probe, the battle log should report when shields are fully depleted (e.g., "Shields down!") in addition to damage numbers. |
| Audio: source and add SFX + music files | Code is fully wired up but audio files are missing. Need `.ogg` files in `assets/audio/sfx/` (click, probe, laser, missile, hit, explosion) and `assets/audio/music/` (ambient_space). Use jsfxr or freesound.org. |
| Cell info tooltip on Target Grid hover | Hovering over a Target Grid cell pops up a small tooltip showing the most recent probe, hit, and miss recorded for that cell with their turn numbers (e.g., "Probed turn 5 • Hit turn 7 • Missed turn 9"). Tooltip only appears if the cell has at least one event to report. Requires CellRecord to track `last_probe_turn`, `last_hit_turn`, `last_miss_turn` (the existing `miss_turn` from I7-3 covers misses). Pairs well with the historical probe overlay — overlay shows where, tooltip shows when. |
| Always-visible split left panel: ship panel + battle log | Replace the current tabbed left panel (Battle Log / Ship Panel switching) with a single always-visible split. Ship Panel takes the top two-thirds, Battle Log takes the bottom third. Removes the auto-focus tab swap (currently selecting a ship swaps to Ship Panel; deselecting swaps to Battle Log) — both are always on screen. Affects `scenes/gameplay.tscn` layout, `scripts/gameplay.gd` (remove `_show_left_tab` calls and the `auto_left_tab` plumbing), and any related UI logic. Pairs well with the accordion ship list item below. |
| Ship Panel as accordion ship list | Ship Panel becomes a list of the player's five ships, each row collapsible/expandable. Selecting a ship on the Command Grid expands its row in the panel and shows full detail; collapsing or selecting another ship swaps the focus. Ship names in the panel are clickable: clicking a name expands that ship's row AND selects the ship on the Command Grid. If the Command Grid isn't the active grid when a name is clicked, switch the active grid to Command Grid as part of the selection. Replaces the current single-ship-detail view in Ship Panel. |
| Nebula extends beyond grid bounds | Today the nebula texture is drawn only within `Rect2(0, 0, GRID_COLS * CELL_SIZE, GRID_ROWS * CELL_SIZE)`. When the camera is fully zoomed out, the nebula stops at the grid edge and the SubViewport background color shows beyond it. Extend the nebula draw rect so it fills the whole SubViewport at full zoom-out, and continues to scale/pan with the camera as the player zooms in (i.e., the nebula scrolls with the world rather than being a static screen-space backdrop). Consider whether the existing 5333×3555 source is sharp enough at the new larger draw rect or whether a higher-resolution replacement is needed. Touchpoints: `scripts/ui/grid_renderer.gd::_draw_background` and the source rect math. |
| Bug: destroyed ships render above other ships on Target Grid | On the Target Grid, destroyed-ship wreckage is drawing above adjacent living-ship visuals. The Command Grid already has the right two-pass z-order from I3-2 (wreckage first, then living ships); apply the equivalent fix to the Target Grid render path. Touchpoint: `scripts/ui/grid_renderer.gd::_draw_target_cells` (or wherever Target Grid wreckage + ghost ships render). |
| Hit/miss markers: unify Command Grid coloring with Target Grid | I7-3 set Target Grid miss color to desaturated red `Color(0.8, 0.4, 0.4, 0.9)` / faded gray `Color(0.6, 0.6, 0.6, 0.4)`. I7-5 used different colors on the Command Grid (incoming hit = red dot, near miss = orange X). Unify so the Command Grid hit/miss palette matches the Target Grid hit/miss palette. Pick whichever set looks cleaner against the nebula and apply to both grids. Touchpoint: `scripts/ui/grid_renderer.gd::_draw_incoming_fire` (Command Grid) vs the miss-rendering block in `_draw_target_cells`. |

---

## Long-term / Exploratory

Bigger structural ideas. Post-hackathon, post-polish, probably post-several-iterations. These reshape the ship model and combat model, so they need their own design pass before any of them gets scoped into work.

| Idea | Notes |
|---|---|
| Non-linear ship shapes | Ships today are straight lines of N cells. Allow L-shapes, T-shapes, rectangles, irregular footprints. Affects placement collision, rotation pivots, hit detection, probe reveal math, and ship rendering. The Battleship becoming a 3×2 block instead of a 5×1 line changes the tactical profile significantly. |
| Half-block ship cells | Ship cells that occupy only half of a grid square. Harder to hit (miss chance on targeted fire, or a reduced hit footprint relative to the probe/fire area). Introduces a sub-grid resolution layer, which affects probe reveal, laser/missile targeting math, and the renderer. Pairs with non-linear shapes. |
| Critical hit zones on ships | Designate core cells (engine, reactor, bridge) on each ship that unlock critical-hit behavior when struck. Requires per-ship shape metadata identifying which cells are core vs hull. |
| Critical hit mechanic | If a shot lands on a core cell while shields are down, trigger a critical hit: extra damage, system disable (no laser this turn, no probe this turn, halved move), or chained secondary damage. Couples with the critical hit zones item above. Needs damage math, UI feedback, and battle log entries for crits. |
| Custom ship builder / fleet builder from stock ships | Two-level customization. Fleet builder: pick your 5 (or N) ships from a stock roster with a point budget, replacing the fixed-fleet preset. Ship builder: compose individual ships from hull / weapon / subsystem modules before the fleet is built. Overlaps with the existing "Points-based fleet builder" and "Ship upgrades / loadout customization" items but goes further into per-ship composition. |
