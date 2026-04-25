# Product Requirements Document
## Battlestations: Nebula — Space Battleship Tribute

---

## 1. Overview

A turn-based, hidden-fleet space combat game for two hot-seat players. A personal tribute to a Pascal game built by Jason's father ~35 years ago. Two players share one browser, taking turns attacking each other's hidden fleet using probes, lasers, and missiles. The game ends when one fleet is completely destroyed.

**Platform:** Godot 4, exported to HTML5. Runs in-browser, no download required.  
**Target devices:** Desktop, tablet-friendly. Phone support is post-hackathon.  
**Browser targets:** Modern browsers (no specific browser required).

---

## 2. Screen States & User Flows

### 2.1 Main Menu
The entry point when the browser loads.

**Required elements:**
- Start Game button
- How to Play button — opens an in-screen reference with text and images walking through gameplay steps and UI overview
- Sound toggle (on/off)
- Music toggle (on/off)

No separate options screen — toggles live directly on the menu.

---

### 2.2 Fleet Placement — Player 1
Triggered after pressing Start Game.

**Intro prompt before the grid appears:**
> "Player 1 — place your fleet. Player 2, look away."

Player 1 clicks Next to proceed to the placement grid.

**Placement screen layout:**
- **Left panel:** Ship list. Each ship displayed as a horizontal strip showing its square count. Clicking a ship selects it and highlights it for drag placement.
- **Center:** The 80×20 grid. Ships are dragged from the left panel onto the grid. Once placed, ships can be nudged with arrow keys or re-dragged. A rotate button (or keyboard shortcut) rotates the selected ship.
- **Right panel:** Selected ship detail card — ship illustration (if available), name, special ability description, and stats: max shields, max armor, max energy, laser strength, missile count, probe count.
- **Done button:** Confirms placement and advances to handoff.

**Placement rules:**
- Ships may be placed adjacent to each other but may not overlap.
- Ships can face any of 4 directions: up, down, left, right. No diagonal.
- All ships must be placed before Done is available.

---

### 2.3 Fleet Placement — Player 2
Same layout and rules as Player 1 placement. Preceded by the same handoff screen (see 2.4).

---

### 2.4 Handoff Screen
Appears between every player turn throughout the entire game — after fleet placement and after every gameplay turn.

**Content:**
> "Player X, your turn. You took X hits from Player Y. Click Next to start your turn."

- Hit count is shown. No ship names, no damage amounts, no locations.
- The previous player looks away. The incoming player reads their hit count and clicks Next.
- First turn of the game: "You took 0 hits" (or omit the hit line entirely on the very first turn).

---

### 2.5 Gameplay Screen
The main game loop. Active for all turns after fleet placement is complete.

**Grid view modes (player chooses):**
- **Side-by-side:** Both grids visible simultaneously. Requires panning/scrolling to navigate.
- **Tabbed:** One grid fills the screen at max size. Tab key (or button) switches between My Fleet grid and Enemy grid.

**Grid navigation:**
- Zoom in/out — fully zoomed out shows the entire 80×20 grid; zoomed in allows detail navigation.
- Pan by clicking and dragging on empty grid space.
- Movement during gameplay is action-based (select ship → choose action → choose direction). No drag-to-move.

**Left panel — Battle Report:**
- Log of events this turn and recent turns: probes detected, hits received, ships lost.
- First turn: empty.

**Right panel — Ship Actions:**
Activated when a ship is clicked on your fleet grid.

- Ship name and illustration
- Current stats: shield HP, armor HP, current energy, missiles remaining, probes remaining
- **Energy allocation sliders** (persist between turns, auto-adjust if energy is insufficient):
  - Shield Regen slider: 0–250, increments of 50
  - Laser Power slider: 0–500 (0–200 for Probe Ship), increments of 50
  - Total of both sliders cannot exceed current available energy
  - Shield regen takes priority — if energy drops below combined setting, shields fill first, lasers get the remainder (may be 0)
- **Action buttons:** Probe, Shoot Laser, Launch Missile, Move
- Special ability button (Cruiser only: 2nd Move action)

**Per-turn flow:**
1. Turn starts — energy regenerates (+50)
2. Handoff screen clears, player sees their current grid state
3. Player clicks through their ships, selecting one action per ship
4. Each ship gets exactly one action per turn (Cruiser gets 2 Move actions)
5. At turn end — shield regen fires per each ship's slider setting, deducting from remaining energy
6. Done — handoff screen appears for next player

---

### 2.6 Victory Screen
Triggered when one player's entire fleet armor reaches 0.

**Content:**
- Winner announcement
- Per-player stats displayed side by side:
  - Probes launched
  - Total hits
- Accept / Play Again button → returns to Main Menu

---

## 3. Ship Roster

Each player commands an identical fleet of 5 ships.

| Ship | Squares | Energy | Shields | Armor | Laser Str. | Missiles | Probes | Special |
|---|---|---|---|---|---|---|---|---|
| Battleship | 5 | 1000 | 1000 | 1000 | 250 | 24 | 10 | — |
| Probe Ship | 4 | 1000 | 750 | 750 | 100 | 0 | 24 | 7×7 probe area |
| Destroyer | 3 | 750 | 750 | 750 | 250 | 12 | 12 | — |
| Destroyer | 3 | 750 | 750 | 750 | 250 | 12 | 12 | — |
| Cruiser | 2 | 500 | 500 | 500 | 250 | 10 | 10 | 2 move actions per turn |

**Total fleet footprint per player:** 17 squares across 5 ships on an 80×20 grid.

---

## 4. Combat Mechanics

### 4.1 Damage Rules
- **Lasers:** Full laser strength vs shields. 75% laser strength vs armor.
- **Missiles:** 250 damage vs armor. 125 damage vs shields. Flat across all ships. No energy cost.
- **Damage scale example (Battleship laser at full power):** 250 vs shields / ~188 vs armor.

### 4.2 Ship Destruction
- A ship is destroyed when its **armor reaches 0**. Shields are a buffer only.
- Destroyed ships leave a **wreckage marker** on the owner's grid. Other ships may pass through wreckage freely.
- From the attacker's perspective: wreckage squares register as hits. The attacker does not know the ship is destroyed unless an active probe covers that area.

### 4.3 Probe Visibility
- **Active probe over an enemy ship:** Attacker can see the ship's current shield HP and armor HP. Energy and missile count remain hidden.
- **No active probe:** Attacker only knows they scored a hit. No stats visible.

---

## 5. Probe Mechanics

### 5.1 Probe Areas
| Ship | Probe Area | Energy Cost |
|---|---|---|
| All ships (except Probe Ship) | 4×4 | 50 |
| Probe Ship | 7×7 | 50 |

### 5.2 Probe Reveal
When a probe lands, any enemy ship squares within the probe area are revealed: ship type, which squares are occupied, and facing direction are visible.

### 5.3 Probe Fade
Probe intel degrades over the probing player's subsequent turns:

| Turn | Standard Probe | Probe Ship Probe |
|---|---|---|
| Launch turn | Full detail | Full detail |
| Your next turn | Full detail | Full detail |
| Turn after that | Ghost marker | Full detail |
| Turn after that | — | Ghost marker |
| Turn after that | — | — |

**Ghost marker:** A permanent indicator that a ship was detected in that area at some point. Ghost markers never disappear — they are persistent intel. The player must probe or fire to determine if the ship is still there.

**Dynamic detection:** If an enemy ship moves into an active probe zone during their turn, it becomes visible on the probing player's next turn.

---

## 6. Energy System

### 6.1 Energy Regeneration
- All ships regenerate **+50 energy at the start of each turn**, including turns where the ship took damage.
- Unused energy carries over between turns (no cap stated — TBD in spec).

### 6.2 Energy Costs
| Action | Cost |
|---|---|
| Probe (standard) | 50 |
| Probe (Probe Ship) | 50 |
| Move (any type) | 50 |
| Laser shot | Equal to laser power setting (0–500, or 0–200 for Probe Ship) |
| Shield regen | Equal to regen amount set (0–250) |
| Missile | 0 (self-propelled) |

### 6.3 Energy Allocation Sliders
- **Shield Regen slider:** 0–250, in increments of 50.
- **Laser Power slider:** 0–500 (0–200 for Probe Ship), in increments of 50.
- Combined slider total cannot exceed available energy for that turn.
- **Priority:** Shields fill first. If energy is insufficient for both settings, shields get what's available; lasers get the remainder (may be 0).
- Slider settings **persist between turns**. If available energy drops below the persisted total, sliders auto-adjust downward (shields first) to match available energy.
- Shield regen fires at **end of turn** after all actions are taken.

### 6.4 Energy Deficit
If a ship has insufficient energy for a desired action, that action is unavailable. A ship at 0 energy cannot fire lasers, probe, or move — but will regenerate 50 energy at the start of the next turn.

---

## 7. Movement

### 7.1 Move Actions
Each move action costs **50 energy**.

| Action | Result |
|---|---|
| Move forward | Advance 2 squares in facing direction |
| Slide left / right / backward | Move 1 square in that direction, facing unchanged |
| Rotate | Change facing direction 90°, position unchanged |

### 7.2 Rotation Pivot Points
Rotation pivots on the ship's center or near-center square:

| Ship | Size | Pivot Square |
|---|---|---|
| Battleship | 5 | Square 3 (center) |
| Probe Ship | 4 | Square 3 (next-to-last from front) |
| Destroyer | 3 | Square 2 (center) |
| Cruiser | 2 | Square 2 (back square) |

### 7.3 Cruiser Special
The Cruiser may take **2 move actions per turn** (costs 100 energy total if both are used).

---

## 8. Fleet Placement Rules

- Ships may be placed adjacent to each other.
- Ships may not overlap.
- Ships may face any of 4 cardinal directions: up, down, left, right.
- All 5 ships must be placed before the player can confirm placement.
- Placement is hidden — each player places on their own grid, invisible to the opponent.

---

## 9. Grid

- **Dimensions:** 80×20 cells per player. Two separate hidden grids — one per player.
- **Zoom:** Full zoom-out shows the entire 80×20 grid. Zoom in for detail (exact zoom levels TBD in spec).
- **Pan:** Click and drag on empty grid space. During fleet placement, clicking a ship selects/drags it — panning only triggers on empty cells.
- **Nebula background:** Deep space purples, blues, teals. Probed areas illuminate/highlight over the nebula texture rather than replacing it.

---

## 10. Audio

| Sound | Type |
|---|---|
| Ambient space atmosphere | Music (toggleable) |
| Laser fire | SFX |
| Missile launch | SFX |
| Probe deploy | SFX |
| Explosion (ship destroyed) | SFX |
| Hit (non-destroy) | SFX |

Sound and music controlled independently via Main Menu toggles.

---

## 11. What's Out of Scope

| Feature | Status |
|---|---|
| Networked multiplayer | Post-hackathon |
| AI opponent | Post-hackathon |
| Points-based fleet builder | Post-hackathon |
| Ship upgrades / loadout customization | Post-hackathon |
| Energy transfer between ships | Post-hackathon |
| Faction system | Post-hackathon |
| Persistent save / resume | Out of scope |
| Phone / small screen support | Post-hackathon |
| Player messaging | Post-hackathon (tied to networking) |
| Stealth Ship | Post-hackathon |

---

## 12. Success Criteria

The game is complete when:
- Two players can sit down at a browser and play a full game to completion with no bugs blocking progress
- Fleet placement, hot-seat handoff, and all core actions (probe, laser, missile, move) function correctly
- The probe fade system works as specified
- The energy system (regen, allocation, shield regen priority) behaves correctly
- The UI is visually polished — nebula background, ship portraits, clear stat readouts
- Sound effects are present for all major actions
- The game runs without download and is publishable to itch.io as-is
