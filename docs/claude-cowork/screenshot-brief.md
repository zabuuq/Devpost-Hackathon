# Screenshot brief for Claude Cowork

You're capturing screenshots of *Battlestations: Nebula* for the in-game tutorial overlay and the itch.io marketing reel. This brief is the only context you have. Read it end to end before opening the browser.

## 1. Where to run the game

**Use this exact URL. The unsecret form 404s:**

```
https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk
```

The build is a draft on itch.io. Without the `?secret=...` query string, the page returns Not Found. Don't strip it, don't share it, don't bookmark a clean version.

- **Build version:** butler build #1608182, channel `zabuuq/battlestations-nebula:html5`, deployed Apr 11, 2026 (I2-1 deploy record in `process-notes.md`).
- **Page state:** Itch.io renders a "Run game" button before the canvas appears. Click it once to load the WebAssembly bundle. The canvas replaces the button in place.
- **WASM load delay:** Plan for 5 to 15 seconds of black canvas after you click "Run game." Wait for the splash screen to render before sending any input.
- **Audio unlock:** The first key press or mouse click on the splash screen calls `AudioServer.unlock()` and advances to the main menu (`scripts/splash.gd:7-14`). That single input both starts audio and progresses the scene. Don't double-tap; one click is enough.
- **Keyboard focus:** Click the canvas once after it appears so keyboard events route to the game and not the itch.io page chrome.

## 2. Game identity and framing

- **Title:** Battlestations: Nebula
- **One-sentence pitch:** A turn-based hot-seat space combat game where two commanders hunt each other across an 80 by 20 nebula grid using probes, lasers, and missiles, with intel that fades from sharp to ghostly over a few turns.
- **Genre:** Turn-based hot-seat tactical, top-down 2D, hidden-fleet fog-of-war.
- **Resolution:** The Godot project has no explicit window size in `project.godot`, so it inherits the engine default (1152 by 648). The HTML5 export uses `html/canvas_resize_policy=2` (adaptive), so the canvas fills whatever the itch.io embed gives it. Use the embedded canvas at the itch.io page's default size. Don't force fullscreen.
- **Aspect ratio:** Roughly 16:9. The grid is wide and short (80 columns, 20 rows), so wider is better than taller.
- **Keyboard focus behavior:** The canvas takes focus on first click. WASD, Q, E, Enter, and Escape all route through Godot once focus is set.

## 3. Controls reference

Pulled from `scripts/splash.gd`, `scripts/main_menu.gd`, `scripts/fleet_placement.gd`, `scripts/gameplay.gd`, and `scripts/ui/ship_panel.gd`.

| Context | Input | Action |
|---|---|---|
| Splash | Any key or mouse click | Unlock audio, advance to main menu (`splash.gd:7-14`) |
| Main menu | Click `Start Game` | Load fleet placement for Player 1 |
| Main menu | Click `How to Play` | Open the tutorial overlay (currently a single label; you're shooting the screenshots that will replace it) |
| Main menu | Click `SFX: ON/OFF` | Toggle SFX |
| Main menu | Click `Music: ON/OFF` | Toggle music |
| Fleet placement | Click a ship in the left list | Select that ship for placement (`fleet_placement.gd:59`) |
| Fleet placement | Move mouse over grid | Ghost ship follows the cursor |
| Fleet placement | `Q` | Rotate ghost counter-clockwise (`fleet_placement.gd:88-92`) |
| Fleet placement | `E` | Rotate ghost clockwise |
| Fleet placement | Left click on grid | Place ship at ghost location (only if ghost is green) |
| Fleet placement | Right click | Cancel current ship selection (`fleet_placement.gd:119`) |
| Fleet placement | Scroll wheel up | Zoom camera in |
| Fleet placement | Scroll wheel down | Zoom camera out |
| Fleet placement | Middle mouse drag | Pan camera |
| Fleet placement | Click `Done` | Lock fleet, advance to handoff (enabled only after all 5 ships are placed) |
| Handoff | Click `Next` | Advance to the next scene (placement for P2 or gameplay for both) |
| Gameplay | Click `Command Grid` tab | Show your own fleet (`gameplay.gd:118`) |
| Gameplay | Click `Target Grid` tab | Show enemy fog-of-war view |
| Gameplay | Click `Battle Log` tab | Show the scrolling action log on the left panel |
| Gameplay | Click `Ship Panel` tab | Show the selected ship's details |
| Gameplay | Left click your ship on Command Grid | Select that ship; opens Ship Panel |
| Gameplay | Left click the same ship again | Deselect |
| Gameplay | Left click a probed enemy ship on Target Grid | Show enemy ship details in Ship Panel (`gameplay.gd:215`) |
| Gameplay | Scroll wheel up/down | Zoom the active grid camera (`gameplay.gd:149-152`) |
| Gameplay | Middle mouse drag | Pan the active grid camera (`gameplay.gd:153-159`) |
| Gameplay | Click `Launch Probe` in Ship Panel | Enter probe targeting mode; auto-switches to Target Grid; shows the probe area highlight under the cursor |
| Gameplay | Click `Shoot Laser` | Enter laser targeting mode (auto-switches to Target Grid). Set Laser Power slider above 0 first or the button stays disabled (`ship_panel.gd:213`) |
| Gameplay | Click `Launch Missile` | Enter missile targeting mode |
| Gameplay | Click `Move Ship` | Enter move preview mode; ghost ship appears at the ship's current position |
| Gameplay (targeting) | Left click on Target Grid | Fire the queued action at that cell |
| Gameplay (move preview) | `W` | Shift ghost up one cell |
| Gameplay (move preview) | `A` | Shift ghost left one cell |
| Gameplay (move preview) | `S` | Shift ghost down one cell |
| Gameplay (move preview) | `D` | Shift ghost right one cell |
| Gameplay (move preview) | `Q` | Rotate ghost counter-clockwise (max 1 net rotation per move) |
| Gameplay (move preview) | `E` | Rotate ghost clockwise |
| Gameplay (move preview) | `Enter` | Submit the move (opens confirmation dialog) |
| Gameplay (move preview) | `Escape` | Cancel the move and exit preview |
| Gameplay (move preview) | Click `Submit Move` button | Same as Enter |
| Gameplay (move preview) | Click `Cancel Move` button | Same as Escape |
| Confirm dialog | Click `OK` | Execute the move |
| Gameplay | Drag Shield Regen / Laser Power sliders in Ship Panel | Allocate energy. Shields take priority if you exceed available energy (`ship_panel.gd:236-261`) |
| Gameplay | Click `End Turn` | End your turn, swap to handoff. Disabled during move preview (`gameplay.gd:541-546`) |

Notes:
- The game has no Pause button and no Restart binding. The only recovery path is reloading the browser tab.
- There's no gamepad support. Keyboard and mouse cover everything.
- The `End Turn` button is the top-right confirm; you can't end a turn while a move preview is open.

## 4. Intended playthrough path

Run this exact path. Cell coordinates are `(column, row)` with column 0 to 79 left to right and row 0 to 19 top to bottom. Origin cells assume facing 0 (North); the ship's body extends downward (south) from the origin.

1. **Open the secret URL.** Wait for the itch.io page to render. Click the `Run game` button. Wait 5 to 15 seconds for the WASM bundle.
2. **Splash screen renders.** Take screenshot 01 (see Section 5). Click the canvas once. Audio unlocks; the main menu loads.
3. **Main menu renders.** Take screenshot 02. Click `How to Play` if you want a reference frame of the current overlay (optional, not in the plan). Click `Start Game`.
4. **Player 1 fleet placement loads.** The grid is 80 columns by 20 rows on a dark blue background. Take screenshot 03 of the empty grid with the ship list visible.
5. **Place Player 1's fleet.** Click each ship in the left list, hover the grid cell listed below, press `Q` or `E` if rotation is called for, then left click to lock it. Place them in this order:
    1. **Battleship (5 squares).** Click `Battleship`. Don't rotate. Hover cell `(10, 9)` and click. The body fills `(10, 9)` through `(10, 13)` running downward.
    2. **Probe Ship (4 squares).** Click `Probe Ship`. Don't rotate. Hover `(20, 9)` and click. The body fills `(20, 9)` through `(20, 12)`.
    3. **Destroyer (3 squares).** Click the first `Destroyer`. Don't rotate. Hover `(30, 9)` and click.
    4. **Destroyer (3 squares).** Click the second `Destroyer`. Don't rotate. Hover `(40, 9)` and click.
    5. **Cruiser (2 squares).** Click `Cruiser`. Don't rotate. Hover `(50, 9)` and click. Body fills `(50, 9)` and `(50, 10)`.
6. **Take screenshot 04** of the fully-placed Player 1 fleet with all 5 ships visible and the `Done` button enabled. Hold the cursor still for one second before capturing so the ghost layer settles.
7. **Click `Done`.** Handoff loads. The label reads `Player 2, your turn.` Click `Next`.
8. **Player 2 fleet placement loads.** Place Player 2's fleet on the right side of the grid in this exact order:
    1. **Battleship.** Hover `(70, 9)` and click.
    2. **Probe Ship.** Hover `(60, 9)` and click.
    3. **Destroyer.** Hover `(55, 9)` and click. (Two columns away from the cruiser-side neighbor.)
    4. **Destroyer.** Hover `(65, 9)` and click.
    5. **Cruiser.** Hover `(75, 9)` and click.
9. **Click `Done`.** Handoff loads. Click `Next`. The gameplay scene loads with `Player 1 — Turn 1`.
10. **Gameplay Turn 1, Player 1.** Confirm you're on the Command Grid (default). Take screenshot 05 of the gameplay layout: Command Grid visible with all 5 P1 ships, Battle Log on the left.
11. **Probe an enemy ship.**
    - Click your `Probe Ship` at `(20, 9)`. The Ship Panel opens on the left.
    - Click `Launch Probe`. The view auto-switches to the Target Grid. A 6 by 6 highlight box follows the cursor.
    - Hover the cursor over cell `(70, 11)`. The highlight should cover columns 67 to 72 and rows 8 to 13, which contains Player 2's Battleship at `(70, 9)`-`(70, 13)`.
    - Take screenshot 06 with the cursor steady on `(70, 11)` showing the probe highlight box hovering over the (still-hidden) enemy battleship area.
    - Left click to fire the probe. The Battleship reveals inside the illuminated box.
    - Take screenshot 07 of the Target Grid right after the probe fires, with the revealed Battleship visible inside the blue probe overlay.
12. **Fire a laser at the probed target.**
    - Click `Command Grid` to switch back. Click your `Battleship` at `(10, 9)`. The Ship Panel opens.
    - Drag the `Laser Power` slider to the right (any value above 0; aim for around 250 if the slider allows). Note the live `Energy after use` readout updating.
    - Take screenshot 08 of the Ship Panel with sliders mid-drag and the action buttons visible.
    - Click `Shoot Laser`. The view auto-switches to the Target Grid.
    - Left click cell `(70, 11)`. The laser fires and lands on the Battleship. The Battle Log gets a new entry; SFX plays. The Target Grid still shows the probed Battleship with updated shield/armor numbers if you click it.
13. **Move a ship.**
    - Click `Command Grid`. Click your `Cruiser` at `(50, 9)`. Click `Move Ship` in the Ship Panel. A ghost copy appears at the cruiser's location and the bottom shows `Move Points: 0.0 / X.X | Energy cost: 0`.
    - Press `D` twice. The ghost slides two columns right (to origin `(52, 9)`). The cost updates live.
    - Take screenshot 09 of the move preview state with the ghost cruiser visible to the right of the original position and the cost label showing non-zero values.
    - Press `Enter`. The confirmation dialog opens. Click `OK`. The cruiser moves.
14. **End turn.** Click `End Turn` in the top-right. Handoff loads.
15. **Player 2 turn.** Click `Next`. The gameplay scene loads with `Player 2 — Turn 1`.
    - Click P2's `Probe Ship` at `(60, 9)`. Click `Launch Probe`. Hover cell `(13, 11)`. The 6 by 6 highlight should cover the area around P1's Battleship at `(10, 9)`-`(10, 13)`. Left click to fire. The Battleship reveals.
    - Click `Command Grid`. Click P2's `Battleship` at `(70, 9)`. Drag `Laser Power` slider above 0. Click `Shoot Laser`. Click cell `(10, 11)` on the Target Grid. The laser lands.
    - Click `End Turn`. Handoff loads. Click `Next`. The gameplay scene loads with `Player 1 — Turn 2`.
16. **End state shot.** You're now on Player 1, Turn 2. The Target Grid still has an active probe over the Player 2 Battleship from Turn 1 (probes fade after 2 of your turns for a standard probe and 3 for a Probe Ship probe; this one is a Probe Ship probe so it's still fresh).
    - Click `Target Grid`.
    - Click cell `(70, 11)` to select the probed enemy Battleship. The Ship Panel switches to enemy view showing `Battleship (Enemy)` with current shields and armor.
    - Take screenshot 10 of the Target Grid with the active 6 by 6 probe overlay visible over the enemy Battleship and the Ship Panel showing the enemy Battleship's stats.
    - Take screenshot 11 zoomed in (scroll wheel up a few clicks) on the same probed area so the nebula background, probe overlay, and ship cells are all readable up close.

Timing hints:
- After clicking `Run game`, wait until the Godot splash logo or the game's splash screen appears before sending input. Waiting 10 seconds is a safe default.
- After entering targeting mode, hold the cursor still on the target cell for one second before capturing so the highlight box settles.
- After firing any action, the Battle Log scrolls and SFX plays. Wait one second for the screen to settle before the next click.

## 5. Screenshot plan

Save all files to `assets/screenshots/` in the project repo. Filename pattern: `NN_<name>.png` (zero-padded two-digit prefix, lowercase, underscores). Capture the game canvas region only, not the full browser. Use the embedded itch.io canvas size; no resize.

| # | Filename | Moment in playthrough | What must be on screen | Cursor / selection state |
|---|---|---|---|---|
| 01 | `01_welcome.png` | Step 2 | Splash screen with the game title and the "Press any key" prompt. Background is the dark nebula. | Cursor anywhere outside the prompt text |
| 02 | `02_main_menu.png` | Step 3 | Main menu with `Start Game`, `How to Play`, `SFX: ON`, `Music: ON` buttons stacked. | Cursor not hovering any button |
| 03 | `03_fleet_placement_empty.png` | Step 4 | Empty Player 1 fleet placement grid. Left panel shows all 5 ships listed. `Done` is greyed out. Player label reads `Player 1 — Place Your Fleet`. | No ship selected; no ghost on the grid |
| 04 | `04_fleet_placement_full.png` | Step 6 | Player 1 grid with all 5 ships placed in a horizontal row across columns 10, 20, 30, 40, 50. Yellow facing triangles point north on each ship. `Done` button is enabled. | Cursor parked outside the grid; no active ghost |
| 05 | `05_command_grid.png` | Step 10 | Gameplay Command Grid tab active. All 5 Player 1 ships visible in their starting columns. Battle Log tab visible on left (empty or with the Turn 1 start message). Top bar shows `Player 1 — Turn 1`. | No ship selected |
| 06 | `06_probe_aiming.png` | Step 11 | Target Grid active. Empty fog-of-war background. A 6 by 6 light-blue probe highlight box hovers around cell `(70, 11)`. Top bar still shows `Player 1 — Turn 1`. | Cursor steady on `(70, 11)`; Probe Ship is the queued shooter |
| 07 | `07_probe_revealed.png` | Step 11 | Target Grid showing the result of the probe firing: a 6 by 6 blue illumination overlay around `(70, 11)` with the Player 2 Battleship now visible inside it. Battle Log on the left has a new probe entry. | Cursor outside the highlight |
| 08 | `08_ship_panel_sliders.png` | Step 12 | Ship Panel tab active on the left. Player 1 Battleship's stats are visible with `Shield Regen` and `Laser Power` sliders, the energy-after-sliders readout, and the four action buttons (`Launch Probe`, `Shoot Laser`, `Launch Missile`, `Move Ship`). | Cursor over the `Laser Power` slider thumb |
| 09 | `09_move_preview.png` | Step 13 | Command Grid with the Cruiser at `(50, 9)` and a translucent ghost cruiser two cells to the right at `(52, 9)`. Bottom info label reads `Move Points: 1.0 / 2.0 \| Energy cost: 50` (or similar non-zero values). `Submit Move` and `Cancel Move` buttons visible. | Move preview active; no cursor over any button |
| 10 | `10_active_probe_enemy_panel.png` | Step 16 | Target Grid with the 6 by 6 probe overlay still active over the Player 2 Battleship. Ship Panel on the left shows `Battleship (Enemy)` with current shields and armor. Top bar shows `Player 1 — Turn 2`. | Cursor near the probed area |
| 11 | `11_probe_closeup.png` | Step 16 (zoomed) | Same scene as #10 but zoomed in 2x to 3x via scroll wheel. The nebula background, probe illumination, ship cells, and grid lines are all readable. This is the hero/marketing shot. | Cursor outside the visible area |
| 12 | `12_battle_log_detail.png` | Optional, Step 16 | Close-up of the Battle Log panel after both players have fired. At least one probe entry, one laser-hit entry, and one move entry visible. | Cursor outside the panel |
| 13 | `13_command_overview.png` | Optional, Step 10 | Wide marketing shot of the full Command Grid zoomed all the way out, showing the entire 80 by 20 grid with all 5 P1 ships in a horizontal row. | No selection |

Minimum required: shots 01 through 11. Shots 12 and 13 are stretch marketing shots. Capture them if the playthrough is still in a clean state.

## 6. How to Play page alignment

The in-game tutorial overlay (rebuilt in step I2-8) has 8 pages. Each page needs a dedicated screenshot. Map them like this:

| Tutorial page | Topic | Screenshot file |
|---|---|---|
| 1 | Welcome / Objective | `01_welcome.png` |
| 2 | Fleet Placement | `04_fleet_placement_full.png` |
| 3 | Command Grid vs Target Grid | `05_command_grid.png` |
| 4 | Probing | `07_probe_revealed.png` |
| 5 | Lasers and Missiles | `08_ship_panel_sliders.png` |
| 6 | Movement | `09_move_preview.png` |
| 7 | Energy and Shields | `08_ship_panel_sliders.png` (reused; the sliders are the energy story) |
| 8 | Winning | `10_active_probe_enemy_panel.png` |

If pages 5 and 7 reusing the same screenshot feels weak when I2-8 runs, the writer can swap page 7 to `12_battle_log_detail.png` or request a fresh shot. Capturing #08 once is enough for now.

The marketing shots `06_probe_aiming.png`, `11_probe_closeup.png`, `12_battle_log_detail.png`, and `13_command_overview.png` go to the itch.io page and Devpost gallery, not the tutorial.

## 7. Known issues and safe-mode

The build is post-Iteration 1 and pre-Iteration 2 content work. All checklist items 1 through 11 plus I1-1 through I1-3 are complete and committed. The I2-1 deploy verification ran via WebFetch only (no in-browser playthrough by the build agent), so this is the first real playtest the build will see.

- **Open issues:** None tracked as blockers. If anything weird happens (a button doesn't respond, the move preview won't exit, the grid renders blank), reload the browser tab and start over from step 1.
- **Recovery path:** No in-game restart binding. Reload the page to recover. There is no Escape-to-menu shortcut on the main gameplay scene; Escape only cancels move preview.
- **Probe fade timing:** A standard probe fades after 2 of your turns; a Probe Ship probe fades after 3. The Section 4 path uses a Probe Ship probe so it stays fresh through Player 1 Turn 2.
- **Slider quirk:** The `Shoot Laser` button stays disabled until you set the Laser Power slider above 0. If the button looks dead, drag the slider first.
- **Move collision:** Moving onto a friendly ship blocks and shows a message; it doesn't consume the action. Enemy ships don't block (you can't see them anyway).
- **Itch.io draft state:** The page is a draft. If itch.io ever changes its draft URL behavior, the secret query string is the only access path; don't try alternate URLs.

If you hit a soft-lock not listed here, take a screenshot named `bug_<short_description>.png` in `assets/screenshots/` and continue from a reload.

## 8. Reaction-time warning

There's no reaction time pressure. The game is fully turn-based. Take as long as you need on every step. Hold the cursor still for one second before any capture so highlight overlays settle. There are zero timed sequences, zero cutscenes, zero animations you have to interrupt. You can step away mid-playthrough and resume.

## 9. Audio and popups

- **Audio unlock:** Web browsers block audio until the user interacts with the page. The splash screen handles this: any key or click on the splash unlocks audio and advances to the main menu. One input does both jobs.
- **No cookie banner expected** on the itch.io game page when accessed via the secret URL. If one appears, dismiss it before clicking `Run game`.
- **Itch.io `Run game` button:** Itch.io shows a placeholder image of the game with a `Run game` button overlay before the WebAssembly bundle loads. You must click this once. After clicking, the canvas replaces the placeholder.
- **No in-game modal popups** appear during normal play. The only in-game modal is the move confirmation dialog (`Are you sure you want to move this ship?`), which you trigger yourself in step 13.
- **Music:** Ambient music plays from the main menu onward. Toggle it off via the `Music: ON` button on the main menu if it interferes with anything you're recording. The screenshot job doesn't capture audio, so leave it on for the playthrough; the screenshots are silent regardless.

## 10. Delivery

Save all screenshot files into `assets/screenshots/` inside the project repository. Use the exact filenames from the Section 5 table. PNG format. Game-canvas region only.

If your default delivery location is an external folder, stage the files into `assets/screenshots/` when you finish so the I2-8 build agent can wire them straight into the tutorial overlay.

There's no hard deadline beyond "before I2-8 runs." The build agent will pause after I2-2 (this brief), run I2-3 through I2-7 in parallel with your screenshot pass, then start I2-8 once your files land. Quality over speed; a clean set of 11 readable shots beats 13 rushed ones.

When you're done, leave a one-line note in `assets/screenshots/DELIVERED.txt` with the date and the count of files delivered, so the I2-8 agent has a clear handoff signal.
