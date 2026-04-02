# Nebula [TBD] — Space Battleship Tribute

## Idea
A turn-based, hidden-fleet space combat game for two hot-seat players — a personal tribute to a Pascal game built by Jason's father ~35 years ago, rebuilt in Godot and exported to the browser for itch.io.

## Who It's For
Two players sitting at the same computer who want a tense, tactical hidden-information game with more depth than classic Battleship. The primary emotional audience is Jason and his dad — it's a tribute first, a game second.

## Inspiration & References
- **Space Battleship by karran (itch.io)** — https://karran.itch.io/space-battleship — Browser-playable HTML5 Battleship in space. Useful as a scope/tone reference for what works at zero download friction.
- **Battleship Lonewolf (Steam)** — https://store.steampowered.com/app/732470/Battleship_Lonewolf/ — Single-player space battleship with layered mechanics: shields, energy management, named abilities. Good feature-depth reference.
- **Stars in Shadow (Steam)** — https://store.steampowered.com/app/464880/Stars_in_Shadow/ — Sparked the idea of faction/ship visual character: distinct cartoon-style art per ship type, personality per unit.

**Visual direction:** Rich graphical UI. Beautiful nebula backdrop behind the grid — deep space purples, blues, teals with color and life. Probed areas illuminate/highlight rather than just flip to a plain color; the nebula stays visible beneath. Ship portraits appear in a side panel when a ship is selected (Stars in Shadow faction-card energy). Not ASCII, not corporate — purposeful, colorful, atmospheric.

**Name:** TBD. Direction: something nebula-themed. Candidates: *Nebula Protocol*, *Dark Fleet*, *Void Sector*. Open to incorporating a reference to the original or to Jason's dad.

## Goals
- Ship a complete, playable, beautiful tribute to his dad's original Pascal game
- Build it in a way that honors what made the original fun: hidden information, tense turn-by-turn decisions, the feeling that your opponent could be anywhere
- Create something polished enough to put on itch.io and feel proud showing it off
- Use this as the hands-on TypeScript/Godot learning project for the hackathon
- Demonstrate spec-driven development end-to-end

## What "Done" Looks Like
Two players can sit down at a browser, go through a setup phase (fleet placement, hot-seat handoff with a blank interstitial screen), and play a full game to completion. Each player has a separate hidden grid (~80×20 cells). Each turn, the active player clicks through their ships one at a time, choosing one action each (probe, shoot, move, or special ability). Between turns, a handoff screen shows what happened to your ships last turn (probes detected, damage received). The game ends when one fleet is completely destroyed.

The UI looks good — nebula background, ship portraits, probed areas illuminated, clear shield/armor/energy readouts. There are sound effects. It runs in a browser and could be published to itch.io as-is.

## Ship Roster (Fixed Fleet — Preset for Hackathon)

| Ship | Size | Special | Notes |
|---|---|---|---|
| Battleship | Large | — | Heaviest weapons, strongest shields, most armor |
| Destroyer | Medium | — | Balanced all-rounder, no special ability |
| Cruiser | Medium-small | Fast (2 moves/turn) | Speed as the core differentiator |
| Probe Ship | Small | Larger probe area, cheaper probe energy cost | Built for intel gathering |
| Stealth Ship | Small | Cloak toggle (invisible to probes while active) | High risk/reward |

Each ship gets one action per turn: **Probe**, **Shoot** (laser or missile), **Move**, or **Special Ability**.

## Core Mechanics Summary

**Grid:** Two separate hidden grids (~80×20). Each player places their fleet on their own grid; you never see the opponent's grid directly — only what probes reveal.

**Probing:** Costs energy. Reveals a 3×3 area (standard) or larger (Probe Ship). Probe intel fades over turns — turn 1: full detail, turn 2: visible if ship still in area, turn 3: visible only if nearby, turn 4+: gone, leaves a "?" marker. If the opponent moves a ship into an active probe zone, it becomes visible.

**Combat:** Lasers (energy-powered, unlimited uses but drain energy) are more effective against shields. Missiles (finite per ship, vary by ship type) are more effective against armor. Tactical flow: use lasers to strip shields, then missiles to destroy armor.

**Energy Allocation:** Each turn, players set energy split between lasers and shields for each ship. More to shields = faster shield regen, weaker laser output. More to lasers = stronger shots, shields regen slower or drain. Shields regenerate automatically when not hit; armor damage is permanent.

**Stealth:** Stealth Ship can activate cloak for 1-2 turns — invisible to probes while active, but can still be hit if fired upon directly.

**Movement:** Ships move 1 space per turn (Cruiser: 2). Facing direction matters — turning costs a move point. Ships must be oriented before moving.

**Win Condition:** Destroy all enemy ships. Last fleet standing wins.

**Hot-Seat Handoff:** A blank/interstitial UI screen between turns. Player 1 takes their turn → handoff screen appears → Player 2 takes their turn. Start-of-turn summary shows: ships detected by probes, damage received, ships lost.

## What's Explicitly Cut

| Feature | Rationale |
|---|---|
| Networked multiplayer | Major infrastructure scope (WebSocket relay server, state sync). Post-hackathon. |
| AI opponent | Satisfying AI requires real design investment. Post-hackathon. |
| Points-based fleet builder | Not in the original game; scope creep risk. Post-hackathon. |
| Ship upgrades / loadout customization | Same as above. Post-hackathon. |
| Energy transfer between ships | Interesting ability but adds system complexity. Post-hackathon maybe. |
| Faction system | Inspired by Stars in Shadow; cool idea but not core. Post-hackathon. |
| Persistent save / resume | Out of scope for a hackathon demo. |

## Loose Implementation Notes
- **Engine:** Godot 4, exported to HTML5. GDScript (or GDScript + some TypeScript via tooling if feasible — TypeScript is Jason's stretch goal).
- **Grid rendering:** The ~80×20 grid will need to be scrollable or zoomable in the browser — it's too wide to fit at full cell size on most screens. Consider a minimap or viewport pan.
- **Two-grid UI layout:** Player sees their own fleet grid + their fog-of-war view of the opponent's grid. Probe illumination overlaid on the nebula texture.
- **Ship portraits:** Side panel that shows a detailed ship illustration + current stats (shield %, armor %, energy allocation, missiles remaining) when a ship is selected.
- **Sound:** Ambient space audio, laser/missile SFX, probe SFX, explosion SFX. Godot's AudioStreamPlayer handles this cleanly.
- **State management:** Turn state, ship stats, probe map (with fade counters), action-taken flags per ship — all needs to be clearly architected before building.
- **Previous attempt:** Jason has already started a version of this project with AI assistance. The fresh spec-driven approach here is intentional — the goal is to see what the structured process produces differently.
