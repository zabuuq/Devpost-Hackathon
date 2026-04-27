# Battlestations: Nebula Color Scheme

## What this document is

The canonical palette for *Battlestations: Nebula*. Every color the game renders, grouped by function, with hex codes, Godot `Color()` float values, the role the color plays, and the source file and line where it lives.

Two audiences:

- **Cowork (and anyone dressing an external surface, such as the itch.io theme, press kit, thumbnails).** The itch.io theme subset is called out at the bottom. For fuller context, scan the sections above.
- **Future development.** When adding a new UI element, check whether an existing color already fits the role before inventing a new one. Most of the game should read as a handful of consistent hues across many surfaces.

Hex codes are alpha-stripped unless alpha is load-bearing (then `#RRGGBBAA`). Where a color lives in a Godot scene file, the line number points to the `color =` or `theme_override_colors/font_color =` assignment.

## Palette source: sampled from the nebula

The whole palette is pulled from `assets/backgrounds/nebula.jpg` (5333×3555, AveCalvar on Envato Elements, Lifetime Commercial License via Core plan). The raw cloud mass is muted, so UI accents are boosted variants of the sampled averages, not the raw values. The sampling script lives at `tools/sample_nebula.py` and any future re-theming pass should start there.

Raw regional averages from the image (for reference):

| Region | Raw hex | Notes |
|---|---|---|
| Teal cloud core | `#4a8186` | Dominant teal cloud mass, hue ~183°. Boosted to `#5ce0d1` for UI. |
| Coral rim | `#884a50` | Dominant coral rim around the cloud, hue ~354°. Boosted to `#ff8c80` for UI. |
| Warm star highlight | `#faf5e6` (brightest) / `#998066` (mid) | The bottom-right orange star and its halo. Boosted to `#ffb266` for UI. |
| Deep navy edge | `#0d0f24` (darkest blues) / `#25031e` (quantized deepest, magenta-tilted) | Mixed to `#140f29` for the flat UI background. |
| Star white (teal-tinted) | `#eaf6f3` | Brightest teal-adjacent pixels. Informs the near-white body text `#e6f5f0`. |

Everything below is the UI-ready variant.

## Base palette

The spine of the visual identity. Warm-purple nebula-edge navy, teal accents pulled from the cloud core, soft blue-teal text, cooler indigo chrome.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#140f29` | `Color(0.08, 0.06, 0.16, 1.0)` | App flat background (where the nebula texture is not already filling the screen) | `scenes/gameplay.tscn:21`, `scenes/fleet_placement.tscn:17`, `scripts/ui/grid_renderer.gd:13` (`COLOR_BG`) |
| `#0a081a` (α `e6`) | `Color(0.04, 0.03, 0.1, 0.9)` | How to Play overlay backdrop (near-black with slight alpha) | `scenes/main_menu.tscn:101` |
| `#5ce0d1` | `Color(0.36, 0.88, 0.82, 1.0)` | Primary teal / title accent (pulled from the nebula's cloud core, used everywhere a color acts as a "link" or an active/selected heading) | `scenes/main_menu.tscn:55`, `scenes/main_menu.tscn:62`, `scenes/main_menu.tscn:120`, `scenes/fleet_placement.tscn:31`, `scenes/gameplay.tscn:38`, `scripts/ui/ship_panel.gd:34` |
| `#3366ff` | `Color(0.2, 0.4, 1.0, 1.0)` | Battleship ship tint (also primary CTA on itch.io, legacy from old palette) | `scripts/ui/grid_renderer.gd:23` (`SHIP_COLORS.battleship`) |
| `#66e0d1` | `Color(0.4, 0.88, 0.82, 0.9)` | Probe halo ring (rebuilt around the new primary teal) | `scripts/ui/grid_renderer.gd:16` (`COLOR_PROBE_BORDER`) |
| `#1f2640` (α `cc`) | `Color(0.12, 0.15, 0.25, 0.8)` | Grid line (deeper, cooler indigo so nebula doesn't drown it) | `scripts/ui/grid_renderer.gd:14` (`COLOR_GRID_LINE`) |
| `#99b8cc` | `Color(0.6, 0.72, 0.8, 1.0)` | Default body text (soft blue-teal, readable on the dimmed nebula and on `#141028`) | `scenes/main_menu.tscn:68`, `scenes/main_menu.tscn:174` |
| `#ffffff` | `Color(1, 1, 1, 1)` | Pure white (button text, default label text on splash) | convention |

## Ship fleet colors

Each ship type has a fixed tint used on both the Command Grid and the Target Grid (when probed). The Battleship blue doubles as the legacy primary CTA color on itch.io.

| Hex | `Color()` | Ship | Source |
|---|---|---|---|
| `#3366ff` | `Color(0.2, 0.4, 1.0, 1.0)` | Battleship (kept, deep blue reads clearly against the nebula's teal and coral) | `scripts/ui/grid_renderer.gd:23` |
| `#33d973` | `Color(0.2, 0.85, 0.45, 1.0)` | Probe Ship (kept green on purpose, the only non-nebula-family ship tint, reads as "that one is yours") | `scripts/ui/grid_renderer.gd:24` |
| `#59a6ff` | `Color(0.35, 0.65, 1.0, 1.0)` | Destroyer, two per fleet (shifted from the old `#4dccff` toward indigo so it doesn't blend with the new primary teal) | `scripts/ui/grid_renderer.gd:25` |
| `#ffa633` | `Color(1.0, 0.65, 0.2, 1.0)` | Cruiser (kept, warm orange is distinct from both nebula family and battleship blue) | `scripts/ui/grid_renderer.gd:26` |
| `#ffff4d` (α `99`) | `Color(1.0, 1.0, 0.3, 0.6)` | Selected ship highlight (yellow glow over the ship tint, kept as a functional selection affordance) | `scripts/ui/grid_renderer.gd:31` (`COLOR_SELECTED_SHIP`) |
| `#ffff4d` | `Color(1.0, 1.0, 0.3, 1.0)` | Facing indicator (yellow triangle on front cell, kept as a functional affordance) | `scripts/ui/grid_renderer.gd:20` (`COLOR_FACING`) |

## Ghost ship states (placement and move preview)

Ghost-valid green and ghost-invalid red are kept as universal UI signals. They are not shifted toward the nebula family on purpose: "OK" and "not OK" need to read instantly in any light.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#ffffff` (α `59`) | `Color(1.0, 1.0, 1.0, 0.35)` | Ghost ship, valid placement (grid renderer) | `scripts/ui/grid_renderer.gd:29` (`COLOR_GHOST_SHIP`) |
| `#ff3333` (α `59`) | `Color(1.0, 0.2, 0.2, 0.35)` | Ghost ship, invalid or overlap (grid renderer) | `scripts/ui/grid_renderer.gd:30` (`COLOR_GHOST_SHIP_INVALID`) |
| varies (ship tint lerped toward `#4dff4d`) | n/a | Ghost placement, valid (fleet placement scene blends the selected ship's tint with green so you can tell which ship you are placing) | `scripts/fleet_placement.gd:215` |
| `#ff3333` (α `80`) | `Color(1.0, 0.2, 0.2, 0.5)` | Ghost placement, invalid (fleet placement scene) | `scripts/fleet_placement.gd:217` |
| `#66ff66` | `Color(0.4, 1.0, 0.4, 1.0)` | Selected ship button modulate (left panel, fleet placement) | `scripts/fleet_placement.gd:167` |

Note: the grid renderer and the fleet placement scene each carry their own ghost colors because the fleet placement scene predates the shared renderer abstraction. A future refactor should consolidate them.

## Grid, probe, and combat markers

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#1f2640` (α `cc`) | `Color(0.12, 0.15, 0.25, 0.8)` | Grid line (gameplay + target grids) | `scripts/ui/grid_renderer.gd:14` |
| `#263352` (α `99`) | `Color(0.15, 0.2, 0.32, 0.6)` | Grid line (fleet placement scene, slightly lighter to compensate for the lower alpha) | `scripts/fleet_placement.gd:192` |
| `#000000` (α `73`) | `Color(0.0, 0.0, 0.0, 0.45)` | Probe illumination fill (landed in I3-1 cont., dims the nebula inside probed cells so fog-reveal reads as "lit" against the unprobed cloud) | `scripts/ui/grid_renderer.gd:15` (`COLOR_PROBE_FILL`) |
| `#66e0d1` (α `e6`) | `Color(0.4, 0.88, 0.82, 0.9)` | Probe illumination border (new primary teal) | `scripts/ui/grid_renderer.gd:16` (`COLOR_PROBE_BORDER`) |
| `#594026` | `Color(0.35, 0.25, 0.15, 1.0)` | Wreckage hull (kept, charred brown reads as inert) | `scripts/ui/grid_renderer.gd:17` (`COLOR_WRECKAGE`) |
| `#8c734d` | `Color(0.55, 0.45, 0.3, 1.0)` | Wreckage X marker (kept) | `scripts/ui/grid_renderer.gd:18` (`COLOR_WRECKAGE_X`) |
| `#ff2626` | `Color(1.0, 0.15, 0.15, 1.0)` | Hit + miss + near-miss marker, current turn (bright red — applied uniformly across Command Grid and Target Grid; glyph differentiates: hit = filled circle, miss / near-miss = X) | `scripts/ui/grid_renderer.gd:28` (`COLOR_MARKER_FRESH`) |
| `#999999` | `Color(0.6, 0.6, 0.6, 1.0)` | Hit + miss + near-miss marker, faded after their landing turn (gray reads as "stale intel"); also used for the historical probe border so the persistent layer reads as one quiet system | `scripts/ui/grid_renderer.gd:29` (`COLOR_MARKER_PERSISTENT`), `scripts/ui/grid_renderer.gd:21` (`COLOR_HISTORICAL_PROBE`) |

## Text and labels, by role

All text renders either on the dimmed nebula (static scenes, 0.45 black overlay) or on the flat navy `#141028` (gameplay HUD panels). Groupings below are by functional role, not by hue.

### Headings and titles

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#5ce0d1` | `Color(0.36, 0.88, 0.82, 1.0)` | Primary teal (game title, section titles, active tabs, ship names) | `scenes/main_menu.tscn:55`, `scenes/main_menu.tscn:62`, `scenes/main_menu.tscn:120`, `scenes/fleet_placement.tscn:31`, `scenes/gameplay.tscn:38`, `scripts/ui/ship_panel.gd:34` |
| `#99ebde` | `Color(0.6, 0.92, 0.87, 1.0)` | Sub-heading (fleet placement panel labels, lighter variant of primary teal) | `scenes/fleet_placement.tscn:47`, `scenes/fleet_placement.tscn:87` |
| `#66e6d9` | `Color(0.4, 0.9, 0.85, 1.0)` | Victory screen accent (winner title, stat labels, a brighter teal for celebratory weight) | `scenes/victory.tscn:60`, `scenes/victory.tscn:67`, `scenes/victory.tscn:74`, `scenes/victory.tscn:90`, `scenes/victory.tscn:115` |

### Body text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#99b8cc` | `Color(0.6, 0.72, 0.8, 1.0)` | Default body (main menu subtitle, nav indicator) | `scenes/main_menu.tscn:68`, `scenes/main_menu.tscn:174` |
| `#e6f5f0` | `Color(0.9, 0.96, 0.94, 1.0)` | Body, high contrast (handoff prompt, fleet placement ship name) | `scenes/handoff.tscn:49`, `scenes/fleet_placement.tscn:96` |
| `#d9f0eb` | `Color(0.85, 0.94, 0.92, 1.0)` | How to Play body text / `TextWrap` default | `scenes/main_menu.tscn:137`, `scripts/ui/text_wrap.gd:53` |
| `#b2cfcc` | `Color(0.7, 0.81, 0.8, 1.0)` | Body, secondary (fleet placement ship stats) | `scenes/fleet_placement.tscn:101` |
| `#bfd6d1` | `Color(0.75, 0.84, 0.82, 1.0)` | Victory screen body (muted blue-teal) | `scenes/victory.tscn:97`, `scenes/victory.tscn:104`, `scenes/victory.tscn:122`, `scenes/victory.tscn:129` |

### Dim / supporting text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#b2c4cc` | `Color(0.7, 0.77, 0.8, 1.0)` | Splash "press any key" prompt, ship panel stats | `scenes/splash.tscn:59`, `scripts/ui/ship_panel.gd:40` |
| `#8099b2` | `Color(0.5, 0.6, 0.7, 1.0)` | Tertiary label (fleet placement hint) | `scenes/fleet_placement.tscn:58` |
| `#80949e` | `Color(0.5, 0.58, 0.62, 1.0)` | Dim (gameplay HUD empty-state labels) | `scenes/gameplay.tscn:83`, `scenes/gameplay.tscn:93` |

### Inline status text

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#99ff99` | `Color(0.6, 1.0, 0.6, 1.0)` | Positive feedback / valid move indicator (kept as functional "OK" green) | `scenes/gameplay.tscn:157`, `scripts/gameplay.gd:411` |
| `#4dff4d` | `Color(0.3, 1.0, 0.3, 1.0)` | Strong positive / Submit Move button (kept green) | `scenes/gameplay.tscn:178` |
| `#ff8c80` | `Color(1.0, 0.55, 0.5, 1.0)` | Cancel Move button / warning inline (coral pulled from nebula rim) | `scenes/gameplay.tscn:183` |
| `#ff7366` | `Color(1.0, 0.45, 0.4, 1.0)` | Invalid move cost indicator (slightly brighter coral for the inline "nope") | `scripts/gameplay.gd:409` |
| `#ffb266` | `Color(1.0, 0.7, 0.4, 1.0)` | End Turn button label (warm orange, shared with blind hit marker) | `scenes/gameplay.tscn:51` |

### Ship Panel role labels

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#99e699` | `Color(0.6, 0.9, 0.6, 1.0)` | Energy remaining label (kept, functional "OK" green) | `scripts/ui/ship_panel.gd:90` |
| `#ccd9ab` | `Color(0.8, 0.85, 0.67, 1.0)` | Action group label (shifted slightly toward the new green-gray family) | `scripts/ui/ship_panel.gd:100` |

## Battle Log event tiers

The battle log colors each event type by what the player learns from it. Higher saturation = higher intel value. Hit and Destroy are now pulled from the nebula coral. Probe shifts to the new primary teal. Miss and Move stay neutral.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#ff9980` | `Color(1.0, 0.6, 0.5, 1.0)` | Hit (nebula-coral warning) | `scripts/ui/battle_log.gd:12` (`COLOR_HIT`) |
| `#ff4c33` | `Color(1.0, 0.3, 0.2, 1.0)` | Destroyed (deeper coral) | `scripts/ui/battle_log.gd:13` (`COLOR_DESTROY`) |
| `#9999a6` | `Color(0.6, 0.6, 0.65, 1.0)` | Miss (neutral gray, kept) | `scripts/ui/battle_log.gd:14` (`COLOR_MISS`) |
| `#66d9d1` | `Color(0.4, 0.85, 0.82, 1.0)` | Probe (pulled to the new primary teal family) | `scripts/ui/battle_log.gd:15` (`COLOR_PROBE`) |
| `#b3d9b3` | `Color(0.7, 0.85, 0.7, 1.0)` | Move (neutral green-gray, kept) | `scripts/ui/battle_log.gd:16` (`COLOR_MOVE`) |

## Tab / button modulate states

Inactive tab buttons are dimmed with a neutral gray modulate; active tabs use `Color.WHITE`.

| Hex | `Color()` | Role | Source |
|---|---|---|---|
| `#999999` | `Color(0.6, 0.6, 0.6, 1.0)` | Inactive tab modulate (Command/Target grid buttons, Battle Log/Ship Panel buttons) | `scripts/gameplay.gd:106-115` |

## Itch.io theme subset (Cowork quick reference)

When dressing the itch.io page theme, use this eight-color subset. These are the values the theme editor exposes. Source of truth for every hex below is the section above. The theme is a projection of the base palette onto itch.io's theme fields.

| itch.io field | Hex | Role in-game |
|---|---|---|
| Background | `#140f29` | App flat background |
| Text | `#99b8cc` | Default body |
| Link color | `#5ce0d1` | Primary teal |
| Link hover color | `#66e0d1` | Probe halo (brighter teal) |
| Button color | `#3366ff` | Battleship blue / legacy CTA |
| Button text color | `#ffffff` | White |
| Button hover color | `#5ce0d1` | Primary teal (shifts on hover) |
| Border / embed frame | `#1f2640` | Grid line indigo |

`docs/claude-cowork/itch-page-setup-brief.md` Section 2 carries the same table inline for Cowork convenience. Treat this document as the source when either diverges.

## Parking lot

- **Itch.io page theme is out of date.** The theme live on itch.io was set in I2-11 from the old palette (`#0d0d26` / `#9999cc` / `#3366ff` / `#66ccff`). I3-6 swapped the in-game palette but did not re-theme the itch.io page. If the user wants the live page to match the new in-game look, that is a Cowork follow-up: apply the "Itch.io theme subset" table above via `docs/claude-cowork/itch-page-setup-brief.md` Section 2.
- **Ghost color consolidation.** `scripts/fleet_placement.gd` and `scripts/ui/grid_renderer.gd` still carry independent ghost-ship colors. Not a bug, but a cleanup pass could collapse them into a single shared constant.

## How to extend this document

When a new UI element introduces a new color:

1. Check whether an existing color in the tables above already fills the role. Reuse first.
2. If a new color is needed, pick it from a `const COLOR_*` constant in a script rather than an inline `Color(...)` literal, so it can be swapped centrally later.
3. Add a row to the relevant section above with the hex, float values, role, and source file:line.
4. If the new color plausibly belongs on itch.io's theme, add a row to the itch.io subset table and update the Cowork brief.
5. If the palette as a whole needs re-sampling from the nebula art, `tools/sample_nebula.py` prints regional averages, quantized top-15, and brightest pixels. Rerun it and update the raw-sample table at the top.

Colors that exist only as inline literals (most of the `scenes/*.tscn` `theme_override_colors/font_color` assignments) are candidates for future consolidation into a shared theme resource.
