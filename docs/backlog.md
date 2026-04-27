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
| Ship naming | Allow players to name their individual ships before or during fleet placement. Would require distinguishing between the two Destroyers. |
| Audio: ambient music | SFX are present in `assets/audio/sfx/` (click, probe, laser, missile, hit, explosion) and remain wired up. Music was deferred during I10: the Music toggle button, `AudioManager.play_music`/`stop_music`/`set_music_enabled`, the `_music_player`, the `MUSIC_PATH` constant, and the `GameState.music_enabled` flag were all removed. Picking this up means re-adding the toggle to `scenes/main_menu.tscn`, restoring the music API in `AudioManager`, putting `music_enabled` back on `GameState`, sourcing a royalty-free ambient track (freesound.org / incompetech / pixabay), and dropping it at `assets/audio/music/ambient_space.ogg`. |
| Audio: improve SFX | The current SFX set (click, probe, laser, missile, hit, explosion) is functional but placeholder-grade. Source higher-quality replacements — punchier laser, more substantial missile launch, bigger explosion. Files live at `assets/audio/sfx/*.ogg`; `AudioManager.play_sfx(name)` is the single integration point, so swapping is a file-replacement job once new sources are picked. |
| Per-ship portrait art | I12 brought the Kenney UI Pack Space Expansion in for chrome (panels, buttons, sliders, progress bars, font) but the pack contains widget art only — no ship sprites. The Ship Panel still shows ships as colored rectangles, and the fleet-placement detail panel has no illustration. Touchpoints: `scripts/ui/ship_panel.gd` (own + enemy ship cards), `scripts/fleet_placement.gd` (right-side detail panel). Sourcing options: Kenney's space-shooter packs, Ansimuz's pixel-ship sets, or commissioned art for the four hull types (battleship, probe ship, destroyer, cruiser). |
| Kenney UI chrome — playing interface phase 2 | I12 used Kenney UI Pack Space Expansion for buttons, panels, sliders, progress bars, font, and the hover tooltip. The pack still has art we haven't touched: crosshairs (4 colorways × 2 styles + 4 neutrals in Extra), header button variants (`button_square_header_blade_*` / `_notch_*` / `_large_*` — only `_small_rectangle` is wired today), notched / screwed panel variants (`panel_glass_notch_*`, `panel_glass_tab`, `panel_rectangle_screws`, `panel_square_screws`), bar art at large sizes plus 9-slice L/M/R pieces in 6 colors, and 8 cursor variants. Specific gameplay-screen touchpoints still on default chrome: (1) `scenes/gameplay.tscn` — LeftPanel + TopBar are widgets floating on the dark `Background` ColorRect with no panel chrome behind them; wrapping them in `panel_rectangle_screws.png` or `panel_glass.png` would unify the readout. (2) `scripts/ui/ship_panel.gd` — accordion mini shield/armor bars are flat StyleBoxFlat (I12-4 punted at 60×6); the L/M/R 3-slice Kenney bar art could replace them, possibly at 60×10 to give the art room. (3) `scripts/ui/grid_renderer.gd::_draw_probe_highlight` — probe shows a translucent rect; laser/missile fire on click with no reticule. A Kenney `crosshair_color_*.png` on the cursor during targeting would be a real game-feel upgrade. (4) Battle Log header label, Actions sub-label in expanded ship detail, accordion row headers — plain text or default Buttons today; could become notched/blade Kenney header chips. (5) `scenes/gameplay.tscn` MoveButtons + MoveInfoLabel — float at bottom with no panel; a glass strip would tie them in. |

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
