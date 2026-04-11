# Battlestations: Nebula

*Hunt blind. Probe twice. Fire once.*

## A Pascal ghost, rebuilt for the browser

Thirty-five years ago, a man wrote a hidden-fleet space combat game in Pascal. He's Jason's dad. The game ran on a machine nobody owns anymore, in a language nobody ships anymore, and it was quiet, tense, two-player, and you remember it for decades after the floppy disk rots.

![Command overview](13_command_overview.png)

This is that game, rebuilt. It runs in a browser now. It has a nebula instead of a green CRT. It has sound. The bones are the same: you place your fleet where the other person can't see it, you take turns reaching into the dark, and you lose ships because you guessed wrong about where someone was three turns ago.

Two commanders. One 80 by 20 nebula. Five ships each, hidden in the dust. You and a friend pass one keyboard back and forth, and the nebula decides who walks out.

![Probe closeup](11_probe_closeup.png)

## How to play

1. **Place your fleet.** Drop your Battleship, Probe Ship, two Destroyers, and Cruiser anywhere on your half of the grid. Rotate with `Q` and `E`.
2. **Hand off to the other player.** One screen, no leaks. They place their fleet on the far side.
3. **Read the two grids.** The **Command Grid** shows your own ships in full color. The **Target Grid** shows the enemy side, hidden in fog until you spend energy to see it.
4. **Probe to reveal enemy ships.** Fire a probe at a patch of nebula. Standard probes light up a 4 by 4 box; Probe Ship probes light up 6 by 6. Any enemy ship caught inside shows up with type, facing, shields, and armor.

![Probe reveal](07_probe_revealed.png)

5. **Strip shields, then break armor.** Lasers deal full damage to shields and 75% to armor. Missiles deal 250 to armor and 125 to shields, and cost no energy to fire. Strip with lasers, break with missiles.
6. **Move with WASD.** Ghost your ship around the grid in a live preview, watch the energy cost update, press `Enter` to commit or `Escape` to back out.
7. **Manage energy with sliders.** Every ship splits its energy between Shield Regen and Laser Power. Shields take priority when energy is tight.
8. **Win by breaking every enemy armor bar to zero.** Shields are a buffer. Armor is the life bar. Pop all five and the battle ends.

## Features

![Move preview](09_move_preview.png)

- **Two-player hot-seat in the browser.** One keyboard, one mouse, one nebula, two commanders. A handoff screen between every turn keeps the hidden information honest.
- **Probe fade as a load-bearing mechanic.** Standard probes give two turns of full detail, then degrade to a permanent ghost marker. Probe Ship probes give three. Ghost markers never clear; you can fire on them and miss empty space because the enemy moved three turns ago.
- **Fixed 5-ship fleet, identical on both sides.** One Battleship, one Probe Ship, two Destroyers, one Cruiser. Seventeen squares of fleet across an 80 by 20 grid.
- **Four actions per ship per turn.** Launch Probe, Shoot Laser, Launch Missile, Move. The Cruiser gets two Move actions because the Cruiser is fast.
- **Energy allocation sliders on every ship.** Split between Shield Regen (0 to 250) and Laser Power (0 to 500, or 0 to 200 on the Probe Ship).
- **Combat math with real tradeoffs.** Lasers: full to shields, 75% to armor. Missiles: 250 armor / 125 shields, no energy cost. Strip, then break.
- **Screen-relative WASD movement in a live preview.** Ghost your ship around the grid, watch the move cost update live, press Enter to commit or Escape to cancel. No wasted actions.
- **Painted nebula backdrop that doubles as the information layer.** Probes illuminate cells instead of erasing fog. Ghost markers pin to the cloud like scars.
- **Battle Log with three detail tiers** depending on your probe coverage: blind, ghost, or active. Active probes give you coordinates and damage numbers. Blind fire gives you almost nothing.
- **Full audio coverage** using Kenney CC0 packs: laser, missile, probe, hit, explosion, and UI click. The splash screen unlocks web audio on first input, so the first laser fires loud.

## Controls

- **Mouse:** click to select ships, drag sliders to allocate energy, click cells to target, scroll wheel to zoom, middle-mouse drag to pan.
- **Keyboard (fleet placement and move preview):** `W` `A` `S` `D` to slide the ghost, `Q` and `E` to rotate, `Enter` to submit, `Escape` to cancel.

The game has no gamepad support. Keyboard and mouse cover everything. Every action can be undone until you commit, and you can't end a turn with a move preview still open.

## Credits

- **Engine:** Godot 4.6.2.
- **Language:** GDScript, statically typed throughout.
- **Audio:** Kenney CC0 asset packs. *Sci-fi Sounds*, *Impact Sounds*, and *Interface Sounds*, all public domain.
- **Deployment:** HTML5 export, pushed to itch.io via Butler.
- **Design tribute:** Jason's father's original Pascal hidden-fleet combat game, circa 1990. The bones are his. The nebula is new.
- **Built for:** Devpost Learning Hackathon: Spec Driven Development.

## Links

- **Live build:** [https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk](https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk)
- **GitHub repo:** [github.com/zabuuq/Devpost-Hackathon](https://github.com/zabuuq/Devpost-Hackathon)
- **Devpost submission:** *pending (Iteration 2 final step)*
