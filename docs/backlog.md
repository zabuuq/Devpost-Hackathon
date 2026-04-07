# Backlog — Nebula [TBD]

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
| Click-to-ghost movement during gameplay | During a move phase, allow player to click a ship and move it ghost-style (like placement) instead of WASD. Some players may prefer this. Evaluate in /iterate. |
| Click-to-pick-up during placement | Clicking an already-placed ship on the grid should pick it back up so the player can reposition it. Currently ships are locked once placed. |
| Ship naming | Allow players to name their individual ships before or during fleet placement. Would require distinguishing between the two Destroyers. |
| Stay on Target Grid after action | After firing laser/missile or launching probe, stay on Target Grid and auto-switch left panel to Battle Log so player can see results. Currently snaps back to Command Grid after every action, forcing tedious back-and-forth. |
| Ship list in left panel | Add a collapsible list of all your ships in the left panel. Click a ship name to expand and see its stats/actions (like the current ship panel). Allows selecting ships without switching to Command Grid. Only switch to Command Grid automatically if the player clicks "Move Ship." Works with the "stay on Target Grid" item above to reduce tab-switching. |
| Auto-set shield regen slider | When a ship's shields are damaged, automatically set the shield regen slider to the optimal value: min(damage taken, slider max 250, current energy). E.g. 50 damage → regen 50; 500 damage → regen 250; 150 damage but 50 energy → regen 50. Saves the player from manually adjusting every ship every turn. |
| Clean up enemy ship panel display | When viewing an enemy ship via probe, the panel still shows the "Actions:" label, separator lines from sliders, etc. Strip all of that out so the enemy view only shows the ship name, type, and shield/armor stats. |
| Hide empty opponent probes in battle log | Only report an opponent's probe in the battle log if it discovers one of the player's ships. Probes that find nothing are noise and give away that the opponent is searching in your area without useful info for the player. Additionally, don't reveal which ship type launched the probe — just say "Opponent launched a probe" to avoid leaking fleet composition info. |

