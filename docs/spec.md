# Battlestations: Nebula — Technical Spec

## Stack

| Layer | Tool | Docs |
|---|---|---|
| Engine | Godot 4.6.2 | [godotengine.org/download/archive](https://godotengine.org/download/archive/) |
| Language | GDScript (statically typed) | [GDScript reference](https://docs.godotengine.org/en/4.6/tutorials/scripting/gdscript/gdscript_basics.html) |
| Export target | HTML5 / Web | [Exporting for the Web](https://docs.godotengine.org/en/4.6/tutorials/export/exporting_for_web.html) |
| Deployment | itch.io via Butler CLI | [Butler docs](https://itch.io/docs/butler/) · [Pushing builds](https://itch.io/docs/butler/pushing.html) |

**GDScript note:** Use static typing throughout (`var x: int`, `func foo() -> void`). Godot 4.6 has measurable performance improvements for statically typed scripts — relevant for grid logic loops over an 80×20 board.

---

## Runtime & Deployment

- **Runs:** In-browser, no download required. HTML5 export from Godot 4.6.
- **Threading:** Disable threading in Web export settings. Simplest path — no SharedArrayBuffer headers required, works on itch.io and all modern browsers without server config.
- **Export templates:** Must match Godot 4.6.2 exactly. Install via Editor → Manage Export Templates → Download and Install. If auto-download fails, grab from [godotengine.org/download/archive](https://godotengine.org/download/archive/).
- **Export output:** `export/web/` folder containing `.html`, `.js`, `.wasm`, `.pck`, `.png`. Gitignored.
- **Butler deploy command:**
  ```bash
  butler push ./export/web <username>/<game-slug>:html5
  ```
- **One-time manual step on itch.io:** Edit game → Kind of project: HTML → mark channel as "Playable in browser."
- **Audio unlock:** Browsers block audio autoplay. Call `AudioServer.unlock()` on first input in `splash.tscn`. After that, all music and SFX fire normally.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Godot Scene Tree                      │
│                                                             │
│  Autoloads (singletons, always loaded)                      │
│  ├── GameState          ← all runtime game data             │
│  └── AudioManager       ← SFX + music control              │
│                                                             │
│  Active Scene (swapped by Main.tscn)                        │
│  ├── splash.tscn        → main_menu.tscn                    │
│  ├── main_menu.tscn     → fleet_placement.tscn              │
│  ├── fleet_placement.tscn → handoff.tscn (×2, P1 then P2)  │
│  ├── handoff.tscn       → fleet_placement / gameplay /      │
│  │                          victory                         │
│  ├── gameplay.tscn      → handoff.tscn (each turn end)      │
│  └── victory.tscn       → main_menu.tscn                    │
└─────────────────────────────────────────────────────────────┘
```

**Data flow — a player's turn:**
```
turn_start()
  → age_probes() on this player's CellRecord map
  → regen energy (+50 per ship)
  → recalculate slider settings vs available energy
  → player takes actions (probe / fire / move per ship)
      → action_resolver.gd handles each action
      → results written to GameState + battle log
turn_end()
  → fire shield regen per ship slider settings
  → deduct energy
  → check win condition
      → if win: load victory.tscn
      → else: write last_turn_hits to GameState, load handoff.tscn
```

---

## Autoloads

### GameState
`scripts/autoloads/game_state.gd`

Singleton. Holds all runtime state. Persists across scene transitions.
Implements `prd.md > 2. Screen States & User Flows` (drives scene progression).

```gdscript
enum Phase { SPLASH, MENU, PLACEMENT, HANDOFF, GAMEPLAY, VICTORY }

var phase: Phase
var current_player: int          # 0 or 1
var turn_number: int
var last_turn_hits: int          # shown on handoff screen

var players: Array = [
    {
        "fleet": [],             # Array[ShipInstance]
        "cell_records": {},      # Dictionary[Vector2i → CellRecord]
                                 # sparse — only cells with data
        "turn_stats": {
            "probes_launched": 0,
            "hits_scored": 0
        }
    },
    { ... }                      # Player 2, same shape
]
```

### AudioManager
`scripts/autoloads/audio_manager.gd`

Singleton. Wraps Godot's `AudioStreamPlayer` nodes. Exposes:
- `play_sfx(name: String)` — plays named SFX one-shot
- `play_music(name: String)` — starts looping music track
- `stop_music()`
- `set_sfx_enabled(enabled: bool)`
- `set_music_enabled(enabled: bool)`

Music and SFX enabled states persisted in `GameState` (read from main menu toggles).

---

## Scenes

### Splash Screen
`scenes/splash.tscn` | `scripts/splash.gd`
Implements `prd.md > 2.1 Main Menu` (entry point).

- Nebula background image (sets visual tone before menu loads)
- Game name centered on screen
- "Press any key to load game" prompt
- On any `_input` event: call `AudioServer.unlock()` → transition to `main_menu.tscn`
- No music on splash — first music starts on main menu

### Main Menu
`scenes/main_menu.tscn` | `scripts/main_menu.gd`
Implements `prd.md > 2.1 Main Menu`.

- Start Game button → loads `fleet_placement.tscn`, sets `GameState.current_player = 0`
- How to Play button → opens in-screen overlay with gameplay reference (text + images)
- Sound toggle (on/off) → `AudioManager.set_sfx_enabled()`
- Music toggle (on/off) → `AudioManager.set_music_enabled()`
- Ambient music starts here (first scene after audio unlock)
- All buttons play click SFX

### Fleet Placement
`scenes/fleet_placement.tscn` | `scripts/fleet_placement.gd`
Implements `prd.md > 2.2–2.3 Fleet Placement` and `prd.md > 8. Fleet Placement Rules`.

Reused for both players. Reads `GameState.current_player` to know whose fleet is being placed.

**Layout:**
```
┌──────────────┬────────────────────────────────┬───────────────┐
│  Ship List   │   SubViewportContainer          │  Ship Detail  │
│  (left panel)│   (Command Grid — this player)  │  (right panel)│
│              │                                 │               │
│  [ Done ]    │                                 │               │
└──────────────┴────────────────────────────────┴───────────────┘
```

**Left panel — Ship List:**
- Displays 5 ships as horizontal strips (squares shown to scale)
- Unplaced ships: clickable. Click → ship enters ghost/cursor mode
- Placed ships: shown as "placed" indicator in list

**Center — Command Grid (SubViewport + Camera2D):**
- 80×20 grid, nebula background behind cells
- Ghost ship follows cursor when a ship is selected
- Click to place at valid position (not red/overlapping)
- Click an already-placed ship → picks it back up into ghost mode
- **Controls during placement:**
  - Q → rotate counterclockwise
  - E → rotate clockwise
  - Ghost turns red when placement is invalid (overlap or out of bounds)

**Right panel — Ship Detail:**
- Shows name, illustration, special ability, stats for selected ship

**Done button:**
- Disabled until all 5 ships are placed
- Confirms placement → loads `handoff.tscn`

**Placement rules (from `prd.md > 8`):**
- Ships may be adjacent but not overlapping
- 4 cardinal facings: up, down, left, right
- All 5 ships must be placed before Done is active

### Handoff Screen
`scenes/handoff.tscn` | `scripts/handoff.gd`
Implements `prd.md > 2.4 Handoff Screen`.

Appears after each fleet placement and after each gameplay turn.

- Text: "Player [X], your turn. You took [N] hits. Click Next to start your turn."
- First turn of game: omit hit line (or show "You took 0 hits")
- N = `GameState.last_turn_hits` (number of shots that landed on this player's ships last turn)
- Previous player looks away. Incoming player reads and clicks Next.
- Next button → loads appropriate next scene:
  - During placement phase: load `fleet_placement.tscn` for Player 2, then `gameplay.tscn`
  - During gameplay: load `gameplay.tscn`

### Gameplay Screen
`scenes/gameplay.tscn` | `scripts/gameplay.gd`
Implements `prd.md > 2.5 Gameplay Screen`.

**Layout:**
```
┌────────────────────────────────────────────────────────────┐
│  [Command Grid] [Target Grid]        ← grid tab buttons    │
├────────────────┬───────────────────────────────────────────┤
│ [Battle Log]   │                                           │
│ [Ship Panel]   │   SubViewportContainer (active grid)      │
│  ← tabs        │                                           │
│                │                                           │
│ auto-focus:    │                                           │
│  ship selected │                                           │
│  → Ship Panel  │                                           │
│  deselected    │                                           │
│  → Battle Log  │                                           │
└────────────────┴───────────────────────────────────────────┘
```

**Grid tabs (top):** Command Grid / Target Grid. Default at turn start: Command Grid.
**View modes:** Tabbed (default) or side-by-side. Player can switch freely during turn.

**Left panel — tabbed:**
- **Battle Log tab:** Turn event log. Auto-focused when no ship selected.
- **Ship Panel tab:** Selected ship detail + action buttons + energy sliders. Auto-focused when ship clicked.

**Grid view — SubViewport + Camera2D:**
- Two SubViewport instances (Command Grid, Target Grid)
- Camera2D in each handles zoom/pan natively
- Full zoom-out shows entire 80×20 grid; zoom in for cell detail
- Pan: click and drag on empty grid space
- Probe illumination rendered as overlay on nebula texture (illuminated, not replaced)

**Ship Panel (when ship selected):**
- Ship name + portrait
- Current stats: shield HP, armor HP, current energy, missiles remaining, probes remaining
- Energy allocation sliders:
  - Shield Regen: 0–250, increments of 50
  - Laser Power: 0–500 (0–200 for Probe Ship), increments of 50
  - Combined total cannot exceed available energy
  - Settings persist between turns; auto-adjusted at turn start if energy insufficient (shields first)
- Action buttons: Probe, Shoot Laser, Launch Missile, Move
- Move button greyed out if `available_move_points == 0`
- Cruiser: Move action available twice per turn

**Victory Screen**
`scenes/victory.tscn` | `scripts/victory.gd`
Implements `prd.md > 2.6 Victory Screen`.

- Winner announcement
- Per-player stats side by side: probes launched, total hits scored
- Play Again button → returns to `main_menu.tscn`

---

## Grid Rendering

### GridRenderer
`scripts/ui/grid_renderer.gd`

Attached to a Node2D inside each SubViewport. Handles all drawing for one grid (Command or Target).

**Rendering layers (drawn in order):**
1. Nebula background texture (tiled or stretched to 80×20 grid bounds)
2. Grid cell lines
3. Wreckage markers (decorative only — passthrough for movement)
4. Ships (Command Grid: full color; Target Grid: ghost/clear based on probe state)
5. Probe illumination overlay (semi-transparent highlight over nebula)
6. Ghost markers (permanent intel markers)
7. Blind hit markers
8. Targeting reticule / probe area highlight (during action targeting)

**Command Grid rendering (player's own fleet):**
- Living ships: full color, facing indicator
- Destroyed ships: wreckage marker at all occupied cells
- Energy/shield state not shown on grid (shown in Ship Panel)

**Target Grid rendering (enemy fog-of-war):**
- Reads `GameState.players[current_player].cell_records`
- For each `CellRecord`:
  - `has_probe == true`, `ship != null`: render ship clearly (full color, correct type sprite)
  - `has_probe == false`, `ship != null` (ghost): render ship blurred/semi-transparent
  - `has_blind_hit == true`: render hit graphic (no ship shape)
  - Ghost cells outside ship bounds: omitted (only ship cells ghosted)

**Probe area highlight (during probe targeting):**
- 4×4 or 6×6 highlight centered on mouse cursor
- Clamped to grid bounds at edges
- Moves with mouse in real time

### SubViewport Setup
Each grid uses:
```
SubViewportContainer
└── SubViewport
    └── Node2D (GridRenderer attached)
        └── Camera2D (zoom/pan)
```

Camera2D zoom limits: fully zoomed out = entire 80×20 visible; max zoom in = TBD during build (suggest ~4× cell size).

---

## Action System

### ActionResolver
`scripts/gameplay/action_resolver.gd`

Handles all four action types. Called by `TurnManager`. Returns result data written to battle log.
Implements `prd.md > 4. Combat Mechanics`, `prd.md > 5. Probe Mechanics`, `prd.md > 7. Movement`.

#### Probe Action
```gdscript
func resolve_probe(acting_ship: ShipInstance, target_cell: Vector2i,
                   player_idx: int) -> ProbeResult:
```
1. Determine probe area (4×4 standard, 6×6 for Probe Ship), clamped to grid bounds
2. Deduct energy: 50 (uniform across all ships)
3. Decrement `acting_ship.probes_remaining`
4. For each cell in probe area:
   - If enemy ship occupies cell: create/update `FogShipRecord` and set on all cells that ship occupies
   - If cell has existing `CellRecord` with ghost or blind hit: clear it, write fresh probe data
   - Set `expires_in`: standard probe = 2, Probe Ship probe = 3
5. Return `ProbeResult` (ship count detected) for battle log

**Battle log format:** `"[Ship type] probe deployed at ([x], [y]). [N] ships detected."`

#### Laser Action

Target cell selected on Target Grid. Cursor: reticule icon.

```gdscript
func resolve_laser(acting_ship: ShipInstance, target_cell: Vector2i,
                   opponent_fleet: Array, has_active_probe: bool) -> ShotResult:
```
1. Deduct energy: `acting_ship.laser_power_setting`
2. Check if target cell is occupied by an enemy ship
3. **Miss:** log entry, return
4. **Hit:**
   - `laser_power = acting_ship.laser_power_setting`
   - `shields_absorbed = min(target_ship.current_shields, laser_power)`
   - `overflow = laser_power - shields_absorbed`
   - `armor_damage = round(overflow * 0.75)`
   - Apply damage. Check ship destruction (armor ≤ 0).
   - If blind fire (no active probe on target cell): set `has_blind_hit = true` on `CellRecord`
   - Increment `GameState.players[current_player].turn_stats.hits_scored`
   - Increment `GameState.last_turn_hits` (for handoff screen)

**Battle log format:**
- Active probe on target: `"[Ship] laser fired at ([x], [y]). Hit — [N] shield damage."` / `"Hit — [N] armor damage."` / `"Hit — shields destroyed, [N] armor damage."`
- Blind fire / ghost: `"[Ship] laser fired. Hit."`
- Miss: `"[Ship] laser fired. Miss."`

#### Missile Action

Same targeting UX as laser. No energy cost.

```gdscript
func resolve_missile(acting_ship: ShipInstance, target_cell: Vector2i,
                     opponent_fleet: Array, has_active_probe: bool) -> ShotResult:
```
1. Decrement `acting_ship.missiles_remaining`
2. Check hit/miss
3. **Hit — shields present:**
   - `shields_absorbed = min(target_ship.current_shields, 125)`
   - `overflow = 125 - shields_absorbed`
   - `armor_damage = overflow` (no percentage — missiles do full armor damage)
   - Apply damage
4. **Hit — no shields:**
   - `armor_damage = 250`
   - Apply damage
5. Blind hit handling same as laser

**Battle log format:** Same tier logic as laser. Damage detail only shown when active probe covers target.

#### Move Action

Implements `prd.md > 7. Movement`.

**Move phase UX:**
1. Player clicks Move action button
2. Ship enters preview mode — ghost ship shows proposed position
3. Live display: `"Move Points: X.X / Y.Y  |  Energy cost: Z"`
4. **Controls:**
   - WASD: screen-relative movement (W=up, S=down, A=left, D=right)
   - Q: rotate counterclockwise (50 energy, 1.0 move point)
   - E: rotate clockwise (50 energy, 1.0 move point)
   - After rotation, forward = new facing direction (0.5 move points, 25 energy)
5. Cost calculated from **net displacement from origin** (not cumulative path)
6. Submit button → "Are you sure?" confirmation → move executes

**Move point costs:**

| Action | Move points | Energy |
|---|---|---|
| Move in facing direction (forward) | 0.5 | 25 |
| Slide sideways or backward | 1.0 | 50 |
| Rotate (Q or E) | 1.0 | 50 |
| Max 1 rotation per move action | — | — |

**Available move points at move phase entry:**
```gdscript
var energy_pts = floor(ship.current_energy / 25.0) * 0.5
var available = min(ship.base_move_points, energy_pts)
# Move button greyed out if available == 0
```

**Collision detection:**
- Wreckage: passthrough. No collision.
- Living ships: blocked. Show message: "Can't move that direction — something is in the way." Action point NOT consumed. Player may try different direction.

```gdscript
func resolve_move(ship: ShipInstance, net_displacement: Vector2i,
                  net_rotation: int, all_ships: Array) -> MoveResult:
    var target_cells = calculate_target_cells(ship, net_displacement, net_rotation)
    for cell in target_cells:
        if is_occupied_by_living_ship(cell, ship, all_ships):
            return MoveResult.blocked("Can't move that direction — something is in the way.")
    execute_move(ship, net_displacement, net_rotation)
    deduct_move_cost(ship, net_displacement, net_rotation)
    return MoveResult.success()
```

---

## Turn Manager

`scripts/gameplay/turn_manager.gd`
Implements `prd.md > 2.5 Gameplay Screen > Per-turn flow`.

```gdscript
func turn_start() -> void:
    var player = GameState.players[GameState.current_player]
    age_cell_records(player.cell_records)   # decrement expires_in, convert to ghost/delete
    for ship in player.fleet:
        if not ship.is_destroyed:
            ship.current_energy += 50
            ship.action_taken = false
            recalculate_sliders(ship)       # adjust if energy insufficient

func turn_end() -> void:
    var player = GameState.players[GameState.current_player]
    for ship in player.fleet:
        if not ship.is_destroyed:
            fire_shield_regen(ship)         # deduct energy per shield_regen_setting
    if check_win_condition():
        get_tree().change_scene_to_file("res://scenes/victory.tscn")
    else:
        GameState.current_player = 1 - GameState.current_player
        get_tree().change_scene_to_file("res://scenes/handoff.tscn")

func fire_shield_regen(ship: ShipInstance) -> void:
    var regen_amount = min(ship.shield_regen_setting, ship.current_energy)
    ship.current_shields = min(ship.current_shields + regen_amount,
                               ShipDefinitions.SHIPS[ship.ship_type].max_shields)
    ship.current_energy -= regen_amount

func check_win_condition() -> bool:
    var opponent = GameState.players[1 - GameState.current_player]
    return opponent.fleet.all(func(s): return s.is_destroyed)
```

---

## Data Model

### ShipDefinitions
`scripts/data/ship_definitions.gd`

Static data only. Single source of truth for ship stats.

```gdscript
class_name ShipDefinitions

const SHIPS: Dictionary = {
    "battleship": {
        "squares": 5, "max_energy": 1000, "max_shields": 1000, "max_armor": 1000,
        "laser_strength": 250, "missiles": 24, "probes": 10,
        "probe_area": 4, "probe_cost": 50, "laser_max": 500,
        "base_move_points": 1.0, "special": ""
    },
    "probe_ship": {
        "squares": 4, "max_energy": 1000, "max_shields": 750, "max_armor": 750,
        "laser_strength": 100, "missiles": 0, "probes": 24,
        "probe_area": 6, "probe_cost": 50, "laser_max": 200,
        "base_move_points": 1.0, "special": "large_probe"
    },
    "destroyer": {
        "squares": 3, "max_energy": 750, "max_shields": 750, "max_armor": 750,
        "laser_strength": 250, "missiles": 12, "probes": 12,
        "probe_area": 4, "probe_cost": 50, "laser_max": 500,
        "base_move_points": 1.0, "special": ""
    },
    "cruiser": {
        "squares": 2, "max_energy": 500, "max_shields": 500, "max_armor": 500,
        "laser_strength": 250, "missiles": 10, "probes": 10,
        "probe_area": 4, "probe_cost": 50, "laser_max": 500,
        "base_move_points": 2.0, "special": "double_move"
    }
}

# Fleet composition per player — two destroyers
const FLEET: Array = ["battleship", "probe_ship", "destroyer", "destroyer", "cruiser"]
```

### ShipInstance
`scripts/gameplay/ship_instance.gd`

Mutable runtime state per ship. Max values always looked up from `ShipDefinitions`.

```gdscript
class_name ShipInstance

var ship_type: String           # key into ShipDefinitions.SHIPS
var position: Vector2i          # grid cell of ship's origin square
var facing: int                 # 0=up, 1=right, 2=down, 3=left

# Current stats
var current_shields: int
var current_armor: int
var current_energy: int
var missiles_remaining: int
var probes_remaining: int

# Slider settings (persist between turns)
var shield_regen_setting: int   # 0–250, increments of 50
var laser_power_setting: int    # 0–500 (or 0–200 for probe_ship), increments of 50

# Turn state (reset each turn_start)
var action_taken: bool
var move_actions_taken: int     # Cruiser gets 2; others get 1
var is_destroyed: bool
```

### FogShipRecord
`scripts/gameplay/fog_ship_record.gd`

Attacker's partial view of an enemy ship. Created when a probe detects a ship. Referenced from all cells that ship occupies in the fog-of-war map.

```gdscript
class_name FogShipRecord

var ship_type: String           # for rendering correct sprite/portrait
var position: Vector2i          # origin cell on enemy grid
var facing: int
var last_shields: int           # visible only when has_probe == true (PRD 4.3)
var last_armor: int             # visible only when has_probe == true
```

### CellRecord
`scripts/gameplay/cell_record.gd`

Per-cell fog-of-war state. Sparse dictionary — only cells with data get an entry.
Key: `Vector2i` cell coordinates. Stored in `GameState.players[n].cell_records`.

```gdscript
class_name CellRecord

var has_probe: bool             # active probe covering this cell
var expires_in: int             # countdown: decrements at YOUR turn start
                                # standard probe: set to 2; Probe Ship: set to 3
                                # when reaches 0: ship → ghost, empty → delete record
var has_blind_hit: bool         # hit landed here without probe coverage
var ship: FogShipRecord         # null if no ship detected in this cell
```

**Probe age → expire logic (called in `turn_start()`):**
```gdscript
func age_cell_records(cell_records: Dictionary) -> void:
    var to_delete = []
    for cell in cell_records.keys():
        var record: CellRecord = cell_records[cell]
        if record.has_probe:
            record.expires_in -= 1
            if record.expires_in <= 0:
                record.has_probe = false
                if record.ship == null:
                    to_delete.append(cell)   # empty probed cell — nothing to ghost
                # ship != null: stays as ghost (has_probe=false, ship persists)
    for cell in to_delete:
        cell_records.erase(cell)
```

**Probe coverage fade schedule:**

| `expires_in` at launch | Turns of full detail | Fades to ghost at |
|---|---|---|
| 2 (standard probe) | 2 turns | Turn 3 of YOUR turns |
| 3 (Probe Ship probe) | 3 turns | Turn 4 of YOUR turns |

**Probe overlap rules:**
- New probe over any cell: complete reset. Previous state (ghost, blind hit, old probe) cleared.
- New `FogShipRecord` overlapping old `FogShipRecord`: old record deleted from all its cells before new one is written.

### Rotation Pivot Points
Implements `prd.md > 7.2 Rotation Pivot Points`.

| Ship | Size | Pivot square (1-indexed from front) |
|---|---|---|
| Battleship | 5 | Square 3 (center) |
| Probe Ship | 4 | Square 3 |
| Destroyer | 3 | Square 2 (center) |
| Cruiser | 2 | Square 2 (back) |

---

## Battle Log

`scripts/ui/battle_log.gd`
Implements `prd.md > 2.5 Left panel — Battle Report`.

Scrollable log of events this turn and recent turns. Auto-focused (tab switches to Battle Log) when no ship is selected.

**Entry format by action and probe coverage:**

| Situation | Format |
|---|---|
| Probe | `"[Ship] probe deployed at ([x], [y]). [N] ships detected."` |
| Fire — miss | `"[Ship] [laser/missile] fired. Miss."` |
| Fire — hit, blind (no active probe) | `"[Ship] [laser/missile] fired. Hit."` |
| Fire — hit, active probe on target | `"[Ship] [laser/missile] fired at ([x], [y]). Hit — [N] shield damage."` or `"[N] armor damage."` |
| Move | `"[Ship] moved."` |
| Ship destroyed | `"[Ship] destroyed."` (appended to hit entry) |

- Always show firing ship type (`"Battleship"`, `"Probe Ship"`, `"Destroyer"`, `"Cruiser"`)
- Two Destroyers: both logged as `"Destroyer"` — no distinction required
- Hit count for handoff screen: incremented per shot that lands, regardless of cell or ship

---

## Audio

`assets/audio/`
Implements `prd.md > 10. Audio`.

| Sound | Type | File |
|---|---|---|
| Ambient space atmosphere | Music (looping) | `audio/music/ambient_space.ogg` |
| Laser fire | SFX | `audio/sfx/laser.ogg` |
| Missile launch | SFX | `audio/sfx/missile.ogg` |
| Probe deploy | SFX | `audio/sfx/probe.ogg` |
| Explosion (ship destroyed) | SFX | `audio/sfx/explosion.ogg` |
| Hit (non-destroy) | SFX | `audio/sfx/hit.ogg` |
| UI button click | SFX | `audio/sfx/click.ogg` |

**Audio unlock:** `AudioServer.unlock()` called on first input in `splash.tscn`. Ambient music starts on `main_menu.tscn`. All SFX available immediately after splash.

Music and SFX controlled independently via toggles on main menu. States stored in `GameState`, read by `AudioManager`.

---

## File Structure

```
battlestations-nebula/                   ← project root
├── project.godot
├── process-notes.md
├── docs/
│   ├── learner-profile.md
│   ├── scope.md
│   ├── prd.md
│   ├── spec.md                          ← this file
│   └── backlog.md                       ← post-hackathon feature ideas
│
├── scenes/
│   ├── main.tscn                        ← root scene; scene switcher only
│   ├── splash.tscn                      ← press any key, audio unlock
│   ├── main_menu.tscn                   ← start, how to play, toggles
│   ├── fleet_placement.tscn             ← reused for P1 and P2
│   ├── handoff.tscn                     ← between every turn
│   ├── gameplay.tscn                    ← main game loop
│   └── victory.tscn                     ← winner + stats
│
├── scripts/
│   ├── autoloads/
│   │   ├── game_state.gd                ← singleton; all runtime state
│   │   └── audio_manager.gd             ← singleton; SFX + music
│   ├── data/
│   │   └── ship_definitions.gd          ← static ship stats + FLEET constant
│   ├── gameplay/
│   │   ├── ship_instance.gd             ← mutable runtime ship state
│   │   ├── fog_ship_record.gd           ← attacker's partial view of enemy ship
│   │   ├── cell_record.gd               ← per-cell fog-of-war (probe + blind hit)
│   │   ├── action_resolver.gd           ← probe, move, laser, missile resolution
│   │   └── turn_manager.gd              ← turn sequence orchestrator
│   ├── ui/
│   │   ├── grid_renderer.gd             ← draws cells, ships, overlays per grid
│   │   ├── ship_panel.gd                ← ship detail + action buttons + sliders
│   │   └── battle_log.gd                ← scrollable turn event log
│   ├── splash.gd
│   ├── main_menu.gd
│   ├── fleet_placement.gd
│   ├── handoff.gd
│   ├── gameplay.gd
│   └── victory.gd
│
├── assets/
│   ├── sprites/
│   │   ├── ships/                       ← portraits + grid sprites (per ship type)
│   │   ├── backgrounds/                 ← nebula texture
│   │   └── ui/                          ← buttons, icons, panel frames, reticule
│   └── audio/
│       ├── music/
│       │   └── ambient_space.ogg
│       └── sfx/
│           ├── laser.ogg
│           ├── missile.ogg
│           ├── probe.ogg
│           ├── explosion.ogg
│           ├── hit.ogg
│           └── click.ogg
│
└── export/                              ← gitignored
    └── web/                             ← butler pushes from here
```

---

## Key Technical Decisions

### SubViewport + Camera2D for grid rendering
**Decision:** Each grid (Command + Target) is a SubViewport with a Camera2D child.
**Why:** Zoom and pan come for free via Camera2D. Grid coordinate math stays clean — all ship positions and probe hits are in grid-space, Camera2D handles screen transform. Alternative (custom `_draw()` on a Control) would require manual coordinate conversions and zoom scaling.
**Tradeoff accepted:** SubViewport mouse event forwarding requires explicit wiring — mouse position must be converted from viewport space to world space. Worth the clean architecture.

### Net displacement for movement cost calculation
**Decision:** Movement cost is calculated from the ship's final position relative to its starting position — not the cumulative path taken.
**Why:** Lets players experiment freely during the move phase without being penalized for changing their mind. Preview mode shows live cost updates; cost is only locked in on Submit.
**Tradeoff accepted:** Implementation is slightly more complex (track origin, calculate net vector) vs. simple per-step deduction. The UX benefit justifies it.

### Sparse Dictionary for fog-of-war (CellRecord)
**Decision:** `cell_records` is a `Dictionary[Vector2i → CellRecord]` with entries only for cells that have data.
**Why:** 80×20 = 1600 cells per player per grid. Most cells will never have probe data. Dictionary lookup is O(1) in GDScript. Iterating only cells with data (for aging) is more efficient than iterating the full grid.
**Tradeoff accepted:** Slightly less obvious to iterate than a 2D array. Mitigated by clear naming and comments.

### Screen-relative WASD movement
**Decision:** W/S/A/D move ships relative to the screen, not the ship's facing direction.
**Why:** Facing-relative controls would mean pressing W moves the ship differently depending on which way it's pointing — unintuitive for hot-seat players who just took over from the opponent.
**Tradeoff accepted:** "Forward" (0.5 move points) is determined by comparing input direction to the ship's current facing — adds a small calculation step but preserves the movement point economy from the PRD.

---

## Dependencies & External Services

| Dependency | Purpose | Docs | Notes |
|---|---|---|---|
| Godot 4.6.2 | Game engine | [godotengine.org](https://godotengine.org/download/archive/) | Export templates must match version exactly |
| Butler CLI | itch.io deployment | [itch.io/docs/butler](https://itch.io/docs/butler/) | Already installed. `butler push ./export/web user/slug:html5` |
| itch.io | Hosting + distribution | [itch.io/docs](https://itch.io/docs) | One-time: set project type to HTML, mark channel as playable in browser |

No external APIs. No backend. No database. No API keys required. Entirely self-contained.

---

## Open Issues

1. **Zoom levels for Camera2D** — max zoom-in level not specified. Suggest starting at 4× cell size during build and adjusting based on how it feels. Needs to be comfortable for selecting individual cells on the 80×20 grid.

2. **Ship sprite / portrait assets** — not yet sourced. The spec assumes one portrait and one grid sprite per ship type (5 types). These need to exist before `grid_renderer.gd` and `ship_panel.gd` can be completed. Placeholder colored rectangles are fine for build; swap in art during `/iterate`.

3. ~~**Game title**~~ — resolved: **Battlestations: Nebula**.

4. **Energy cap** — PRD notes "unused energy carries over between turns (no cap stated — TBD in spec)." Recommend no cap for simplicity. Ships with high energy reserves become more capable over time — interesting strategic dimension.

5. **Probe area clamping at grid edges** — when cursor is near the edge, the 4×4 or 6×6 probe area clips to the grid boundary. Spec assumes clamped area (smaller effective probe near edges). This should be visually clear to the player in the highlight.
