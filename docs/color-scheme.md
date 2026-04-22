# Battlestations: Nebula — Color Scheme

## What this document is

The canonical palette for *Battlestations: Nebula*. Every color the game renders, grouped by function, with hex codes, Godot `Color()` float values, the role the color plays, and the source file and line where it lives.

Two audiences:

- **Cowork (and anyone dressing an external surface — itch.io theme, press kit, thumbnails).** The itch.io theme subset is called out at the bottom. For fuller context, scan the sections above.
- **Future development.** When adding a new UI element, check whether an existing color already fits the role before inventing a new one. Most of the game should read as a handful of consistent hues across many surfaces.

Hex codes are alpha-stripped unless alpha is load-bearing (then `#RRGGBBAA`). Where a color lives in a Godot scene file, the line number points to the `color =` or `theme_override_colors/font_color =` assignment.

## Base palette

The spine of the visual identity. Dark nebula backdrop, cyan accents, soft blue-lavender text, indigo chrome.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#0d0d26` | `Color(0.05, 0.05, 0.15, 1.0)` | App background (every scene) | `scenes/main_menu.tscn:18`, `scenes/splash.tscn:17`, `scenes/handoff.tscn:17`, `scenes/fleet_placement.tscn:17`, `scenes/gameplay.tscn:21`, `scenes/victory.tscn:21`, `scripts/ui/grid_renderer.gd:8` (`COLOR_BG`) |
| `#00001a` (α `e6`) | `Color(0.0, 0.0, 0.1, 0.9)` | How to Play overlay backdrop (near-black with slight alpha) | `scenes/main_menu.tscn:76` |
| `#66ccff` | `Color(0.4, 0.8, 1.0, 1.0)` | Title / link cyan (used everywhere a color acts as a "link" or an active/selected heading) | `scenes/main_menu.tscn:37`, `scenes/fleet_placement.tscn:31`, `scenes/gameplay.tscn:38`, `scripts/ui/ship_panel.gd:34` |
| `#3366ff` | `Color(0.2, 0.4, 1.0, 1.0)` | Primary button / call-to-action (battleship blue, also the Battleship ship tint) | `scripts/ui/grid_renderer.gd:18` (`SHIP_COLORS.battleship`) |
| `#4db3ff` | `Color(0.3, 0.7, 1.0, 0.9)` | Hover / probe halo ring | `scripts/ui/grid_renderer.gd:11` (`COLOR_PROBE_BORDER`) |
| `#26264d` | `Color(0.15, 0.15, 0.3, 0.8)` | Border / embed frame (indigo grid line) | `scripts/ui/grid_renderer.gd:9` (`COLOR_GRID_LINE`) |
| `#9999cc` | `Color(0.6, 0.6, 0.8, 1.0)` | Default body text (soft blue-lavender, readable on `#0d0d26`) | `scenes/main_menu.tscn:43`, `scenes/main_menu.tscn:149` |
| `#ffffff` | `Color(1, 1, 1, 1)` | Pure white (button text, contrast against `#3366ff`) | convention |

## Ship fleet colors

Each ship type has a fixed tint used on both the Command Grid and the Target Grid (when probed). The Battleship blue doubles as the base palette button color.

| Hex | `Color()` | Ship | Source |
|---|---|---|---|
| `#3366ff` | `Color(0.2, 0.4, 1.0, 1.0)` | Battleship | `scripts/ui/grid_renderer.gd:18` |
| `#33d973` | `Color(0.2, 0.85, 0.45, 1.0)` | Probe Ship | `scripts/ui/grid_renderer.gd:19` |
| `#4dccff` | `Color(0.3, 0.8, 1.0, 1.0)` | Destroyer (two on the fleet) | `scripts/ui/grid_renderer.gd:20` |
| `#ffa633` | `Color(1.0, 0.65, 0.2, 1.0)` | Cruiser | `scripts/ui/grid_renderer.gd:21` |
| `#ffff4d` (α `99`) | `Color(1.0, 1.0, 0.3, 0.6)` | Selected ship highlight (yellow glow over the ship tint) | `scripts/ui/grid_renderer.gd:26` (`COLOR_SELECTED_SHIP`) |
| `#ffff4d` | `Color(1.0, 1.0, 0.3, 1.0)` | Facing indicator (yellow triangle on front cell) | `scripts/ui/grid_renderer.gd:15` (`COLOR_FACING`) |

## Ghost ship states (placement and move preview)

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#ffffff` (α `59`) | `Color(1.0, 1.0, 1.0, 0.35)` | Ghost ship — valid placement (grid renderer) | `scripts/ui/grid_renderer.gd:24` (`COLOR_GHOST_SHIP`) |
| `#ff3333` (α `59`) | `Color(1.0, 0.2, 0.2, 0.35)` | Ghost ship — invalid / overlap (grid renderer) | `scripts/ui/grid_renderer.gd:25` (`COLOR_GHOST_SHIP_INVALID`) |
| `#4dff4d` (α `80`) | `Color(0.3, 1.0, 0.3, 0.5)` | Ghost placement — valid (fleet placement scene) | `scripts/fleet_placement.gd:197` |
| `#ff3333` (α `80`) | `Color(1.0, 0.2, 0.2, 0.5)` | Ghost placement — invalid (fleet placement scene) | `scripts/fleet_placement.gd:197` |
| `#66ff66` | `Color(0.4, 1.0, 0.4, 1.0)` | Selected ship button modulate (left panel, fleet placement) | `scripts/fleet_placement.gd:157` |

Note: the grid renderer and the fleet placement scene each carry their own ghost colors because the fleet placement scene predates the shared renderer abstraction. A future refactor should consolidate them.

## Grid, probe, and combat markers

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#26264d` (α `cc`) | `Color(0.15, 0.15, 0.3, 0.8)` | Grid line (gameplay + target grids) | `scripts/ui/grid_renderer.gd:9` |
| `#333366` (α `99`) | `Color(0.2, 0.2, 0.4, 0.6)` | Grid line (fleet placement scene) | `scripts/fleet_placement.gd:178` |
| `#4db3ff` (α `33`) | `Color(0.3, 0.7, 1.0, 0.2)` | Probe illumination fill | `scripts/ui/grid_renderer.gd:10` (`COLOR_PROBE_FILL`) |
| `#4db3ff` (α `e6`) | `Color(0.3, 0.7, 1.0, 0.9)` | Probe illumination border | `scripts/ui/grid_renderer.gd:11` (`COLOR_PROBE_BORDER`) |
| `#594026` | `Color(0.35, 0.25, 0.15, 1.0)` | Wreckage hull | `scripts/ui/grid_renderer.gd:12` (`COLOR_WRECKAGE`) |
| `#8c734d` | `Color(0.55, 0.45, 0.3, 1.0)` | Wreckage X marker | `scripts/ui/grid_renderer.gd:13` (`COLOR_WRECKAGE_X`) |
| `#ff9933` | `Color(1.0, 0.6, 0.2, 1.0)` | Blind hit marker (orange, Target Grid) | `scripts/ui/grid_renderer.gd:14` (`COLOR_BLIND_HIT`) |

## Text and labels — by role

All text renders on `#0d0d26` (the base background). Groupings below are by functional role, not by hue.

### Headings and titles

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#66ccff` | `Color(0.4, 0.8, 1.0, 1.0)` | Primary title cyan (game title, section titles, active tabs, ship names) | `scenes/main_menu.tscn:37`, `scenes/fleet_placement.tscn:31`, `scenes/gameplay.tscn:38`, `scripts/ui/ship_panel.gd:34` |
| `#99ccff` | `Color(0.6, 0.8, 1.0, 1.0)` | Sub-heading (e.g., fleet placement panel labels) | `scenes/fleet_placement.tscn:47`, `scenes/fleet_placement.tscn:87` |
| `#4dd9e6` | `Color(0.3, 0.85, 0.9, 1.0)` | Victory screen accent (winner title, stat labels — distinct brighter teal) | `scenes/victory.tscn:41`, `scenes/victory.tscn:57`, `scenes/victory.tscn:82` |

### Body text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#9999cc` | `Color(0.6, 0.6, 0.8, 1.0)` | Default body (main menu subtitle) | `scenes/main_menu.tscn:43` |
| `#e6e6ff` | `Color(0.9, 0.9, 1.0, 1.0)` | Body — high contrast (handoff prompt, fleet placement body) | `scenes/handoff.tscn:37`, `scenes/fleet_placement.tscn:96` |
| `#d9e6ff` | `Color(0.85, 0.9, 1.0, 1.0)` | How to Play body text / `TextWrap` default | `scenes/main_menu.tscn:112`, `scripts/ui/text_wrap.gd:53` |
| `#b3b3e6` | `Color(0.7, 0.7, 0.9, 1.0)` | Body — secondary (fleet placement detail) | `scenes/fleet_placement.tscn:101` |
| `#bfccd9` | `Color(0.75, 0.8, 0.85, 1.0)` | Victory screen body (muted blue-gray) | `scenes/victory.tscn:64` |

### Dim / supporting text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#b3b3cc` | `Color(0.7, 0.7, 0.8, 1.0)` | Splash "press any key" prompt, ship panel stats | `scenes/splash.tscn:45`, `scripts/ui/ship_panel.gd:40` |
| `#8080b3` | `Color(0.5, 0.5, 0.7, 1.0)` | Tertiary label (fleet placement hint) | `scenes/fleet_placement.tscn:58` |
| `#808099` | `Color(0.5, 0.5, 0.6, 1.0)` | Dim (gameplay HUD secondary) | `scenes/gameplay.tscn:83`, `scenes/gameplay.tscn:93` |

### Inline status text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#99ff99` | `Color(0.6, 1.0, 0.6, 1.0)` | Positive feedback / valid move indicator | `scenes/gameplay.tscn:157`, `scripts/gameplay.gd:411` |
| `#4dff4d` | `Color(0.3, 1.0, 0.3, 1.0)` | Strong positive (e.g., action confirmed) | `scenes/gameplay.tscn:177` |
| `#ff6666` | `Color(1.0, 0.4, 0.4, 1.0)` | Error / invalid (inline) | `scenes/gameplay.tscn:182` |
| `#ff4d4d` | `Color(1.0, 0.3, 0.3, 1.0)` | Invalid move cost indicator | `scripts/gameplay.gd:409` |
| `#ff9933` | `Color(1.0, 0.6, 0.2, 1.0)` | Command grid tab label (warm amber, shared with blind hit marker) | `scenes/gameplay.tscn:51` |

### Ship Panel role labels

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#99e699` | `Color(0.6, 0.9, 0.6, 1.0)` | Energy remaining label | `scripts/ui/ship_panel.gd:90` |
| `#cccc99` | `Color(0.8, 0.8, 0.6, 1.0)` | Action group label | `scripts/ui/ship_panel.gd:100` |

## Battle Log — event tiers

The battle log colors each event type by what the player learns from it. Higher saturation = higher intel value.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#ff734d` | `Color(1.0, 0.45, 0.3, 1.0)` | Hit | `scripts/ui/battle_log.gd:12` (`COLOR_HIT`) |
| `#ff331a` | `Color(1.0, 0.2, 0.1, 1.0)` | Destroyed | `scripts/ui/battle_log.gd:13` (`COLOR_DESTROY`) |
| `#9999a6` | `Color(0.6, 0.6, 0.65, 1.0)` | Miss | `scripts/ui/battle_log.gd:14` (`COLOR_MISS`) |
| `#66bfff` | `Color(0.4, 0.75, 1.0, 1.0)` | Probe | `scripts/ui/battle_log.gd:15` (`COLOR_PROBE`) |
| `#b3d9b3` | `Color(0.7, 0.85, 0.7, 1.0)` | Move | `scripts/ui/battle_log.gd:16` (`COLOR_MOVE`) |

## Tab / button modulate states

Inactive tab buttons are dimmed with a neutral gray modulate; active tabs use `Color.WHITE`.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#999999` | `Color(0.6, 0.6, 0.6, 1.0)` | Inactive tab modulate (Command/Target grid buttons, Battle Log/Ship Panel buttons) | `scripts/gameplay.gd:106-115` |

## Itch.io theme subset (Cowork quick reference)

When dressing the itch.io page theme, use this eight-color subset. These are the values the theme editor exposes. Source of truth for every hex below is the section above — the theme is a projection of the base palette onto itch.io's theme fields.

| itch.io field | Hex | Role in-game |
|---|---|---|
| Background | `#0d0d26` | App background |
| Text | `#9999cc` | Default body |
| Link color | `#66ccff` | Title / link cyan |
| Link hover color | `#4db3ff` | Probe halo |
| Button color | `#3366ff` | Battleship blue / primary CTA |
| Button text color | `#ffffff` | White |
| Button hover color | `#66ccff` | Title cyan (shifts brighter on hover) |
| Border / embed frame | `#26264d` | Indigo grid line |

`docs/claude-cowork/itch-page-setup-brief.md` Section 2 carries the same table inline for Cowork convenience. Treat this document as the source when either diverges.

## How to extend this document

When a new UI element introduces a new color:

1. Check whether an existing color in the tables above already fills the role. Reuse first.
2. If a new color is needed, pick it from a `const COLOR_*` constant in a script rather than an inline `Color(...)` literal, so it can be swapped centrally later.
3. Add a row to the relevant section above with the hex, float values, role, and source file:line.
4. If the new color plausibly belongs on itch.io's theme, add a row to the itch.io subset table and update the Cowork brief.

Colors that exist only as inline literals (most of the `scenes/*.tscn` `theme_override_colors/font_color` assignments) are candidates for future consolidation into a shared theme resource.
