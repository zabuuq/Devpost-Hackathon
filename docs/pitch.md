# Battlestations: Nebula

## 1. Elevator pitch

Battlestations: Nebula is a turn-based, hot-seat space combat game where two commanders hunt each other's hidden fleet across an 80 by 20 nebula grid. You fire probes to pull enemy ships out of the dark, then burn lasers and missiles into coordinates your intel swears are still accurate. The intel is lying. The nebula is watching.

## 2. Tagline candidates

- Hunt blind. Probe twice. Fire once.
- A Pascal ghost, rebuilt for the browser; your father's war, your turn to fight it.
- Two commanders. One nebula. Zero trust in yesterday's map.
- Every probe is a flashlight in a haunted house.
- Stale intel kills faster than lasers.

## 3. The tribute story

Thirty-five years ago, a man wrote a hidden-fleet space combat game in Pascal. His name does not matter to you. He's Jason's dad. The game ran on a machine nobody owns anymore, in a language nobody ships anymore, and it was quiet, tense, two-player, and you remember it for decades after the floppy disk has rotted.

This is that game, rebuilt.

It runs in a browser now. It has a nebula instead of a green CRT. It has sound. But the bones are the same: you place your fleet where the other person can't see it, you take turns reaching into the dark, and you lose ships because you guessed wrong about where someone was three turns ago.

You were pulled out of hyperspace into an unmapped nebula. So was the other commander. Neither of you asked for this. Somewhere up the chain, a bored god flipped a circuit breaker and dropped you both into the same cloud of gas and dust and static. You have five ships. They have five ships. The nebula is watching, and the nebula does not care which of you walks out.

Neither did the original Pascal game. That's the part worth rebuilding.

## 4. The mechanical hook: probe fade

A probe is a flashlight. It costs energy. It lights up a 4 by 4 box of nebula (6 by 6 if you fired it from a Probe Ship), and any enemy ship caught inside that box appears on your Target Grid in full detail: type, facing, shields, armor.

You get two turns of that detail. Three if a Probe Ship fired it. Then the lights go out.

What stays is a ghost marker. A permanent stain on your map that says: a ship was here once. It never disappears. It is the only memory the nebula gives you, and it is worse than nothing, because it feels like information.

You can fire on a ghost. You can burn a Battleship volley into those coordinates and feel good about it. The enemy moved three turns ago. Your shot hits empty space. Your log says "miss." You do not get the energy back. You do not get the turn back. You probe again or you guess again, and while you're deciding, the other commander is probing you.

This is the game. Probes are expensive. Sight is temporary. Memory is a trap.

## 5. The visual hook: nebula and probe illumination

Every grid cell in this game sits on a painted deep-space nebula. Purples, blues, teals, dust and light. It is not a backdrop you ignore; it is the surface you are fighting on.

Probes do not erase the nebula. They illuminate it. A fresh probe drops a cone of blue light over seven-by-seven cells of painted cloud, and inside that light you see enemy ships rendered cleanly over the same texture you were squinting at a second ago. When the probe fades, the light goes, and the ghost marker stays pinned to the nebula like a scar.

The Command Grid and the Target Grid share the same nebula art. Your own fleet sits on it in full color; the enemy lives in fog until you spend energy to see them. Zoom out and you see the whole 80 by 20 battlefield as a wide, thin strip of cloud with ships scattered across it. Zoom in and you see the grid lines, the facing arrows, the probe halos, the ghost markers. The art is the information layer. You read the nebula the way a sailor reads weather.

## 6. Feature bullets

- Two-player hot-seat in the browser. One keyboard, one mouse, one nebula, two commanders. A handoff screen between every turn keeps the hidden information honest.
- Fixed 5-ship fleet, identical for both sides: one Battleship, one Probe Ship, two Destroyers, one Cruiser. Seventeen squares of fleet across an 80 by 20 grid.
- Four actions per ship per turn: Launch Probe, Shoot Laser, Launch Missile, Move. The Cruiser gets two Move actions because the Cruiser is fast.
- Probe fade as a load-bearing mechanic. Standard probes give two turns of full detail then degrade to a permanent ghost marker. Probe Ship probes give three turns of full detail before degrading. Ghost markers never clear.
- Energy allocation sliders on every ship. Split your energy between Shield Regen (0 to 250) and Laser Power (0 to 500, or 0 to 200 on the Probe Ship). Shields fill first when energy is tight.
- Combat math with real tradeoffs. Lasers deal full strength to shields and 75% to armor. Missiles deal 250 to armor and 125 to shields, and cost no energy to fire. Strip shields with lasers, break armor with missiles.
- Screen-relative WASD movement in a live preview. Ghost your ship around the grid, see the move point cost update live, press Enter to commit or Escape to cancel. No wasted actions.
- Command Grid and Target Grid as separate tabbed views, both on the same painted nebula. Zoom and pan with scroll wheel and middle mouse. Battle Log on the left reports events in three detail tiers depending on probe coverage.
- Hidden-information integrity by design. You never see the opponent's grid; you only see what your probes and your incoming damage tell you. The handoff screen between turns reports hit counts only. No ship names, no locations, no damage numbers.
- Full audio coverage. Kenney CC0 packs for laser, missile, probe, hit, explosion, and UI click. The splash screen unlocks web audio on first input, so the first laser fires loud.

## 7. Credits

- **Engine:** Godot 4.6.2.
- **Language:** GDScript, statically typed throughout.
- **Audio:** Kenney CC0 asset packs. Sci-fi Sounds, Impact Sounds, and Interface Sounds, all public domain.
- **Deployment:** HTML5 export, pushed to itch.io via Butler.
- **Design tribute:** Jason's father's original Pascal hidden-fleet combat game, circa 1990. The bones are his. The nebula is new.
- **Built for:** Devpost Learning Hackathon: Spec Driven Development.
