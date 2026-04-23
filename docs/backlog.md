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
| Click-to-ghost movement during gameplay | During a move phase, allow player to click a ship and move it ghost-style (like placement) instead of WASD. Some players may prefer this. Evaluate in /iterate. |
| Click-to-pick-up during placement | Clicking an already-placed ship on the grid should pick it back up so the player can reposition it. Currently ships are locked once placed. |
| Ship naming | Allow players to name their individual ships before or during fleet placement. Would require distinguishing between the two Destroyers. |
| Stay on Target Grid after action | After firing laser/missile or launching probe, stay on Target Grid and auto-switch left panel to Battle Log so player can see results. Currently snaps back to Command Grid after every action, forcing tedious back-and-forth. |
| Ship list in left panel | Add a collapsible list of all your ships in the left panel. Click a ship name to expand and see its stats/actions (like the current ship panel). Allows selecting ships without switching to Command Grid. Only switch to Command Grid automatically if the player clicks "Move Ship." Works with the "stay on Target Grid" item above to reduce tab-switching. |
| Auto-set shield regen slider | When a ship's shields are damaged, automatically set the shield regen slider to the optimal value: min(damage taken, slider max 250, current energy). E.g. 50 damage → regen 50; 500 damage → regen 250; 150 damage but 50 energy → regen 50. Saves the player from manually adjusting every ship every turn. |
| Clean up enemy ship panel display | When viewing an enemy ship via probe, the panel still shows the "Actions:" label, separator lines from sliders, etc. Strip all of that out so the enemy view only shows the ship name, type, and shield/armor stats. |
| Hide empty opponent probes in battle log | Only report an opponent's probe in the battle log if it discovers one of the player's ships. Probes that find nothing are noise and give away that the opponent is searching in your area without useful info for the player. Additionally, don't reveal which ship type launched the probe — just say "Opponent launched a probe" to avoid leaking fleet composition info. |
| Blind hit clears ghost ship on that cell | When a blind hit lands on a cell that has a ghost ship marker, the ghost marker on that specific cell should disappear — only the blind hit marker remains. Other cells of the ghost ship stay unchanged. Rationale: the player knows a ship *was* there, but after firing blind they don't know if the same ship is still present. Ghost intel on that cell is now stale. |
| Wreckage visible in newly probed areas | If a ship was destroyed before an area was probed, probing that area should reveal wreckage markers for the destroyed ship. Wreckage should still disappear when the probe expires (same as living ship wreckage behavior). Currently wreckage only shows if the ship was destroyed while already under active probe. |
| Battle log: hide enemy ship type on actions | Battle log should not show which enemy ship performed an action — only what action was performed. Revealing ship types leaks fleet composition and positioning info. |
| Battle log: persist across turns | Battle log should carry over between turns so players can scroll back and review the full history. Currently resets each turn. |
| Extended victory statistics | Victory screen should display: probes launched (done), laser shots fired, missiles fired, total shots fired (lasers + missiles, done), total hits (done), total laser damage, total missile damage, total damage, total misses. Requires adding new counters to turn_stats in GameState. |
| Battle log: hide opponent misses unless near miss | Don't show opponent misses in the battle log unless the miss lands in a cell directly adjacent to one of the player's ships (a "near miss"). Random misses are noise; near misses are tactically interesting. |
| Probe activation outside grid | Player should be able to click outside the grid to activate a probe. Clamping still keeps the probe area fully within the grid. Currently clicking outside the grid does nothing. |
| Ghost ship facing indicator | Ghost ships (faded probe intel) should show the last known facing direction with an arrow indicator, same as active probe ships but at ghost alpha. |
| Rework map scrolling and zooming controls | New scheme: scroll wheel = scroll vertically; shift+scroll = scroll horizontally; ctrl+scroll = zoom in/out; left-click-drag on empty space = pan (must not trigger ship selection — only select on click-release without drag). Remove middle-click-drag panning. |
| Zoom centered on mouse position | Zooming in/out should center around the current mouse cursor location, not the viewport center. |
| Persist map view between turns | Map zoom level and viewing position should carry over to the player's next turn instead of resetting. Store per-player camera state in GameState. |
| Battle log: hide ship destruction on blind hits | Blind hits should only report "Hit" — do not reveal that a ship was destroyed. Destruction info is only available with active probe coverage. |
| Battle log: show shield breakdown on probed hits | When hitting an opponent ship under active probe, the battle log should report when shields are fully depleted (e.g., "Shields down!") in addition to damage numbers. |
| Miss indicators on Target Grid | Misses show as an X on the target grid for the current turn. X persists on subsequent turns but faded. Probes and blind hits remove miss indicators on their cell unless a later miss re-creates one. Misses inside an active probe area show for that turn only and are removed next turn if probe is still active. |
| Command Grid: show incoming hits and near misses | After opponent's turn, Command Grid shows hit and near-miss indicators from their actions. Full intensity for one turn, faded for the next, gone on the third. |
| Command Grid: show opponent active probes | If one of the player's ships is inside an opponent's active probe area, show the probe boundary on Command Grid. Should only appear after a ship move places a ship into the probe area (not revealed preemptively). |
| Audio: source and add SFX + music files | Code is fully wired up but audio files are missing. Need `.ogg` files in `assets/audio/sfx/` (click, probe, laser, missile, hit, explosion) and `assets/audio/music/` (ambient_space). Use jsfxr or freesound.org. |
| Ship colors during placement | Ships on the placement grid should use their ship-type colors (matching the gameplay grid renderer) so players can visually distinguish ships while placing them. Currently placement uses a single color. |
| Randomize fleet placement button | Add a "Randomize" button to the fleet placement screen that auto-places all ships at valid random positions and facings. Quality-of-life for players who want to jump into gameplay quickly. |
| Instant win on last kill | Check win condition immediately after each action resolves, not just at turn end. If the last enemy ship is destroyed mid-turn, skip straight to the victory screen instead of waiting for the player to hit End Turn. |
| No blind hit on partially probed ships | When a ship is partially inside an active probe area, hitting a cell outside the probe should not show a blind hit marker — the player already knows the ship is there from the probed cells. Only show blind hit when the ship is entirely unknown. |
| Historical probe overlay | Cells that were previously probed but no longer have active coverage should retain a subtle visual marker (e.g. faint border or background tint) on the Target Grid. No live data — just shows where you've already looked. Helps players avoid re-probing the same area. |
| Cruiser forward move cost wrong after rotation | After the cruiser pivots, forward movement cost is still calculated based on the previous heading instead of the new facing direction. The move point calculation needs to use the post-rotation facing. |
| Uniform probe cost (50 energy for all ships) | Change probe cost from 100 (standard) / 50 (Probe Ship) to 50 for all ships. Simplifies the energy economy and makes probing more accessible. |
| Increase Probe Ship probe area to 7×7 | Bump Probe Ship probe area from 6×6 to 7×7 to further differentiate it from standard 4×4 probes. |
| Partially probed ships clickable on all cells | When an opponent ship is partially inside an active probe area, only the probed cells are clickable on the Target Grid. The entire ship should be clickable since the player already knows it's there. |
| Bug: first-turn energy regen ignores cap | On the first round, the +50 energy regen applies on top of the ship's starting max energy, so each ship ends up 50 over its stated max. Regen should clamp to the ship's `max_energy`. Likely in `TurnManager.turn_start()` energy regen step. |
| Bug: destroyed ships render above live ships | Wreckage markers for destroyed ships currently draw on top of adjacent living ships on the Command Grid. Destroyed ships should render on a lower z-layer so living ships always draw above wreckage. Fix in `scripts/ui/grid_renderer.gd` draw order. |
| Bug: empty-state label persists when ship selected | `scripts/ui/ship_panel.gd` toggles `_container.visible` in `show_ship` / `clear_ship` but never hides the sibling `ShipPanelEmpty` label ("Click a ship on the Command Grid to select it.") defined in `scenes/gameplay.tscn`. When a ship is selected, the empty-state prompt and the populated panel render at the same time. Invisible on the full-screen gameplay view because the label blends into the sidebar, but obvious on a tight crop of the panel. Fix: cache the sibling reference in `_build_ui()` and toggle its visibility alongside `_container` in `show_ship` / `show_enemy_ship` / `clear_ship`. Temporary workaround lives in `_shot_08a_ship_panel_tight()` in `scripts/debug/screenshot_runner.gd`; remove it once the real fix lands. |
| Two-line title treatment on splash and main menu | Restyle the game title from a single line to a two-line block: `Battlestations:` on the first line, `NEBULA` fully capitalized on the second line at a larger font size, horizontally stretched so `NEBULA` matches the pixel width of `Battlestations:` above it exactly. Applies to `scenes/splash.tscn` primarily; check `scenes/main_menu.tscn` and `scenes/victory.tscn` for any other title renderings that should stay consistent. Width matching on a stretched label can be done with `Label.set("theme_override_constants/outline_size", ...)` plus character spacing, or by placing `NEBULA` inside a `Control` with `size_flags_horizontal = SIZE_EXPAND_FILL` and scaling the label's `custom_minimum_size` to hit the target width. Re-run `scripts/debug/screenshot_runner.gd` after to regenerate `01_welcome.png` and `02_main_menu.png` with the new title. |

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
| Partial probe reveal on ships | When a probe only catches some cells of an enemy ship, reveal only the probed cells instead of the whole ship. The player sees a partial silhouette and has to infer ship type, size, and facing. Changes the probe/reveal contract: today a single probed cell reveals the full `FogShipRecord`; this would reveal only overlapped cells. Affects `FogShipRecord` shape, CellRecord population, and Target Grid rendering. |
