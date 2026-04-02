# Process Notes

## /scope

### How the idea evolved
Jason arrived with a clear concept: a tribute to a hidden-fleet space combat game his father built in Pascal ~35 years ago. The core was already formed — grid-based, fog of war, turn-based — but the session surfaced and sharpened a lot of detail: the probe-fade mechanic, the laser/missile damage split (lasers vs shields, missiles vs armor), energy allocation as a per-turn decision, directional movement with turning costs, and the stealth ship's cloak ability.

The biggest structural decision was multiplayer format. Jason initially said "networked 2-player" — pushed back when asked to consider scope, he recognized hot-seat was actually more faithful to his dad's original game and much more achievable. Good self-correction.

### Pushback received and how Jason responded
- **Networked multiplayer:** Flagged as the single biggest scope risk. Jason initially asked if AI was actually easier than networking (fair question, engaged critically). After honest comparison, he landed on hot-seat as the right call — it honors the original and ships clean.
- **Points-based fleet builder:** He returned to this idea 3-4 times. Acknowledged it himself as scope creep risk each time. Final decision: post-hackathon feature. Fixed preset fleet for the hackathon.
- **Energy-transfer ability:** Surfaced it himself, let it go to the parking lot without prompting.

### References and what resonated
- **Stars in Shadow:** Didn't match the research description (it's a 4X, not a tactical combat game), but sparked the best idea of the session — distinct cartoon-style ship portraits with personality per unit. Jason was visibly excited about this visual direction.
- **Space Battleship (karran):** Useful as a negative reference — Jason clearly articulated what his game is NOT (same-grid, simultaneous resolution). Helped sharpen the fog-of-war / separate grid distinction.
- **Battleship Lonewolf:** Noted as different (real-time vs turn-based) but validated the energy/shield layering direction.

### Deepening rounds
Two rounds. 

Round 1 questions: visual style, ship types/name, complete game flow walkthrough.
Round 2 questions: grid size/structure, emotional "done" definition, points system decision.

The game flow walkthrough in Round 1 was the highest-value moment — Jason narrated a complete turn sequence including probe fade, energy redirection, movement, and attack chains. This gave the scope doc its concrete "What Done Looks Like" section and confirmed the probe-fade mechanic is load-bearing, not decorative.

Round 2 confirmed the grid (~80×20, separate hidden grids) and resolved the points system question cleanly.

### Active shaping
Jason drove almost all of it. He had the mechanics largely pre-formed — the session was extraction, not invention. Key moments where he steered independently: flagging the points system as potential scope creep (his words, not mine), correcting the Stars in Shadow description, deciding hot-seat was actually more faithful to the original than networking, and articulating the probe-fade mechanic in granular detail. The emotional hook (tribute to his dad) was entirely his — added real weight to the "done" definition.

## /prd

### Decisions made
- **Stealth Ship cut** — the more Jason thought through the cloak mechanic, the more he recognized it as a later-phase addition. Replaced with a second Destroyer. Clean call, made mid-interview without prompting.
- **Message area cut** — hot-seat messaging removed entirely. Post-hackathon, tied to networking.
- **Slider minimum set to 0** — overrode an earlier assumption of 50 minimum. Sliders go to zero.
- **Shield priority over lasers** — when energy is insufficient for both settings, shields take priority. Explicit design decision.
- **Ghost markers are permanent** — probe fade doesn't fully disappear. Ghost markers persist as permanent intel. "You just know a ship was there at some point."
- **Handoff screen simplified** — one screen, hit count only. No damage detail, no ship names. Incoming player sees hit count and clicks Next.
- **Missiles cost no energy** — self-propelled. Energy only governs lasers, probes, movement, and shield regen.
- **Ship destruction trigger** — armor hits 0. Shields are purely a buffer.
- **Energy regen at turn start, shield regen at turn end** — Jason liked the idea of knowing your energy going in, then spending it on regen as a deliberate end-of-turn choice.

### Pushback received
- **Laser minimum of 50** — corrected by Jason. Sliders should go to zero.
- **Probe Cruiser size discrepancy** — caught and corrected mid-session. Battleship went from 6→5, Probe Ship from 5→4.

### Deepening rounds
Two rounds.

Round 1: full screen flow walkthrough, ship stats (all 5 ships), probe mechanics and fade, fleet placement rules.

Round 2: destroyed ship behavior, movement/rotation details (pivot points surfaced here — good implementation detail), handoff screen content, energy slider persistence and priority logic, grid zoom/pan behavior, browser/device targets.

The pivot point question in Round 2 was a high-value moment — Jason hadn't explicitly thought through how rotation works for even vs odd ships. That's load-bearing for the movement system implementation.

The stealth ship cut was the most significant mid-session change. It happened naturally when the cloak mechanic question forced him to think through the implementation complexity. Good self-correction.

## /spec

### Technical decisions made

- **Engine + language:** Godot 4.6.2 + GDScript (statically typed). TypeScript deferred to a future project — Jason wants to learn it generally, not necessarily here.
- **HTML5 threading:** Disabled. Simplest path for itch.io — no SharedArrayBuffer headers needed.
- **Grid rendering:** SubViewport + Camera2D per grid. Chosen for native zoom/pan and clean coordinate math. Alternative (custom `_draw()`) ruled out due to manual coordinate conversion complexity.
- **Grid naming:** Command Grid (player's fleet) and Target Grid (enemy fog-of-war). Jason's call — more thematic than "My Fleet / Enemy."
- **Fog-of-war:** Sparse Dictionary (Vector2i → CellRecord). Per-cell, not per-probe-area. Jason corrected an initial per-probe-area proposal with a clear overlap scenario that proved per-cell is right.
- **FogShipRecord:** Lightweight partial view of enemy ship (type, position, facing, last-known shields/armor). Referenced from all cells the ship occupies — rendering checks `has_probe` per cell to decide clear vs ghost.
- **Movement:** Screen-relative WASD (not facing-relative). Net displacement from origin determines cost — players can experiment in preview without penalty. Q/E for rotation, consistent across placement and gameplay.
- **Move points:** Separate UI resource from energy. Forward = 0.5 pts / 25 energy; all other moves = 1.0 pts / 50 energy. Energy caps available move points at turn start.
- **Combat overflow:** Laser overflow hits armor at 75%. Missile overflow hits armor at face value (no conversion). Rounding: nearest whole number.
- **Battle log tiers:** Three tiers based on probe coverage — blind fire minimal, active probe full detail with coordinates and damage numbers.
- **Audio unlock:** Splash screen ("Press any key to load game") triggers `AudioServer.unlock()` on first input. Solves web audio autoplay restriction elegantly.
- **Post-hackathon Godotify pass:** Agreed to catalog signals, node connections, and other script-based setup that could be moved to the Godot editor after the build is done.

### What Jason was confident about vs. uncertain

- **Confident:** Core game mechanics (these were pre-formed before the session). Combat math framing once the overflow model was established. Screen-relative movement. The ghost/probe model once per-cell was confirmed.
- **Corrected the agent:** Per-cell vs per-probe-area (clear reasoning with overlap scenario). Slider minimum of 0 (not 50). Hot-seat = no mid-turn damage. "Press any key to begin" → "Press any key to load game" (UX reasoning). "Forward" after rotation = new facing direction.
- **Worked through together:** Move points system (took several exchanges to land on net displacement + live preview). Missile damage overflow (required clarifying the shield-absorbs-half mental model).

### Deepening rounds

Two rounds.

Round 1: Tech preferences + deployment, SubViewport architecture, ship data model, UI layout (Jason restructured to two-panel tabbed design), ProbeMap (major back-and-forth — per-cell correction, FogShipRecord concept, CellRecord simplification with expires_in).

Round 2: Combat math (laser + missile formulas, overflow, rounding), movement system (screen-relative, move points, energy cap, net displacement, preview + submit), targeting UX (reticule + probe area highlight, auto-switch to Target Grid), battle log format (three tiers), turn start sequence (hot-seat = no mid-turn damage), hit count definition (per shot landed).

The per-cell CellRecord discussion was the highest-value moment — Jason's overlap scenario was a clear architectural insight that saved a likely /build confusion. The move point system took the most iterations to land cleanly.

### Active shaping

Jason made nearly all architectural decisions when given options. Notable moments: restructured the UI layout from three panels to two (his initiative, not a prompted choice), corrected the per-probe-area model with a concrete scenario, introduced the FogShipRecord concept (instantiate a ship when probe reveals it), simplified CellRecord with `expires_in` countdown, insisted on screen-relative movement for UX clarity, added the splash screen to solve the audio unlock problem elegantly, named the grids Command Grid and Target Grid. Strong ownership throughout.

## /onboard

- **Technical experience:** Intermediate-to-experienced full-stack web dev. ColdFusion, PHP, Python (light), JS/CSS/HTML, MySQL/MSSQL/Oracle/MongoDB (light). Wants to explore TypeScript as primary stretch goal.
- **AI agent experience:** Has used Codex, Copilot, Gemini, Claude. Comfortable with AI tooling, ready to move beyond basic prompting.
- **Learning goals:** Understand spec-driven development hands-on — identify what his existing process gets right and where the gaps are.
- **Creative sensibility:** Sci-fi/fantasy + detective/spy crossover reader. Sandbox and strategy games. Built a Game Jam game (top-down 2D, nuclear meltdown mechanic). Eclectic music taste. Loves landscapes and colorful abstracts. Gravitates toward systems with depth and high-stakes tension.
- **Prior SDD experience:** Yes — used AI to define project scope, then structured work as GitHub epics and issues/stories. Reasonably formal, but front-loading of specification was likely thinner than what this process demands.
- **Energy/engagement:** Direct and experienced. Answers are concise and precise — doesn't over-explain. Will respond well to a brisk pace and peer-level tone. Not a hand-holding situation.
