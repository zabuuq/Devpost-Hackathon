# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Battlestations: Nebula** — A turn-based, hidden-fleet space combat game built in Godot 4.6.2, targeting HTML5/web export and deployment to itch.io. Two-player hot-seat (local multiplayer). A tribute to a Pascal game from ~35 years ago.

Full design docs are in `docs/`: `prd.md` (product requirements), `spec.md` (technical architecture), `scope.md` (feature rationale), `backlog.md` (post-hackathon ideas).

## Build & Deploy

```bash
# Export: Godot Editor → File → Export Project → HTML5
# Output goes to: export/web/

# Deploy to itch.io
butler push ./export/web <username>/<game-slug>:html5
```

**Web export requirements:**
- Disable threading (no SharedArrayBuffer headers needed)
- Export templates must match Godot 4.6.2 exactly
- Call `AudioServer.unlock()` on first user input to bypass web autoplay restriction

## Screenshot capture

When the user asks for screenshots of the game (for itch.io, the in-game tutorial, Devpost, marketing, etc.), **do not drive the game manually via a browser or chrome-devtools MCP**. There's a scripted runner that produces the full 13-shot set in one command:

```bash
godot --path . -- --screenshot
```

This drops PNGs into `assets/screenshots/` with canonical filenames (`01_welcome.png` through `13_command_overview.png`). The filenames and intended contents match the brief in `docs/claude-cowork/screenshot-brief.md`.

The runner lives at `scripts/debug/screenshot_runner.gd`. It drives `GameState` directly, goes through the real `ActionResolver`/`GridRenderer`/`ShipPanel` code paths, and walks 13 capture points. No new scenes, no UI automation, no browser. The `--screenshot` flag is checked in `scripts/main.gd`; without it, the game boots normally.

**Edit the runner when:** UI/graphics change and the shots drift, new shots are needed, method names or scene tree paths referenced by the runner (e.g., `_select_ship`, `_enter_targeting`, `MainLayout/GridArea/...`) get refactored. Shots are designed to match the game's own rendering so routine visual changes need zero runner edits — just rerun the command.

## Architecture

GDScript with static typing throughout. Scene-based state machine coordinated by `Main.tscn`.

**Scene flow:** `splash.tscn` → `main_menu.tscn` → `fleet_placement.tscn` (P1) → `handoff.tscn` → `fleet_placement.tscn` (P2) → `handoff.tscn` → `gameplay.tscn` → `victory.tscn`

**Autoload singletons:**
- `GameState` — single source of truth for all runtime data (fleet positions, energy, probes, fog-of-war)
- `AudioManager` — SFX + music toggle

**Core systems (all in `gameplay.tscn`):**
- `ActionResolver` — resolves probe, laser, missile, move actions
- `TurnManager` — orchestrates turn sequence: energy regen → player actions → shield regen → win check
- `GridRenderer` — renders 80×20 grids with fog-of-war and probe illumination; uses SubViewport + Camera2D
- `BattleLog` — scrollable event log with three detail tiers (blind / ghost / active probe)

**Grid cells** use sparse dictionaries keyed by `Vector2i`. `CellRecord` tracks fog state, probe coverage, ship presence.

**Turn sequence per player:**
1. `turn_start()` — age existing probes, regen +50 energy per ship
2. Player selects ships and queues actions (probe/laser/missile/move)
3. `ActionResolver` processes each action
4. `turn_end()` — apply shield regen from sliders, check win condition
5. Load `handoff.tscn` or `victory.tscn`

## Key Data Models (from spec.md)

- `ShipInstance` — runtime ship state (position, heading, shields, armor, energy)
- `FogShipRecord` — what one player knows about an enemy ship (ghost vs active intel)
- `ShipDefinitions` — static data (size, base stats) for the 5 ship types
- Energy sliders control split between shield regen and laser power (minimum = 0, no floor)

## Ship Roster (fixed fleet, both players identical)

| Ship | Size | Notes |
|------|------|-------|
| Battleship | 5 sq | 1000 shields/armor |
| Probe Ship | 4 sq | 6×6 probe area, 50 energy cost |
| Destroyer | 3 sq | ×2 per fleet |
| Cruiser | 2 sq | 2 move actions per turn |

## Development Notes

- Movement uses screen-relative WASD (not ship-relative) — intentional design decision
- Probe fade: 2–3 turns full detail → ghost markers → permanent intel (load-bearing mechanic)
- Laser damage: 75% to shields, overflow to armor
- Missile damage: 250 armor / 125 shields (bypasses shields partially)
- No external dependencies, no backend, no APIs — fully self-contained
