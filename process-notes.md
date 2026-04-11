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

## /build

### Step 5: Fleet Placement scene — bug fixes

**What was built:**
- Fixed ghost-offset bug: replaced manual container→viewport coordinate math in `_screen_to_grid()` with `grid_node.get_local_mouse_position()`. Godot handles SubViewportContainer stretch and Camera2D transform internally, bypassing the coordinate conversion that was wrong across 4 prior attempts.
- Added scroll-wheel zoom (`_zoom_camera`) and middle-mouse pan to `_on_viewport_gui_input`, ported from `gameplay.gd`. Added `MIN_ZOOM`/`MAX_ZOOM` constants and `is_panning`/`pan_start_*` state variables.
- Added `_zoom_camera()` and `_clamp_camera()` helper methods matching the gameplay.gd pattern.

**Issues:** Root cause of the offset bug was the manual container math — it didn't account for Godot's internal transforms. The `get_local_mouse_position()` approach resolves this cleanly.

**Verification:** Requires in-game test — move cursor over grid and confirm ghost ship tracks cursor correctly; zoom with scroll wheel; pan with middle-mouse drag.

### Step 7: GridRenderer — Command Grid and Target Grid rendering

**What was built:**
- `scripts/ui/grid_renderer.gd` — full `_draw()` implementation with 8 rendering layers: background, grid lines, Command Grid ship rendering (full color + facing arrow), Target Grid fog-of-war rendering (full/ghost/blind hit based on CellRecord state), probe area highlight (4×4 or 6×6, clamped to grid bounds, tracks mouse in real time). Placeholder colored rectangles for ships — one color per ship type.
- `scenes/gameplay.tscn` — added GridRenderer script reference and `is_command_grid` export on both GridNode instances.
- `scripts/gameplay.gd` — added SubViewport references, typed GridRenderer `@onready` vars, `_container_to_world()` coordinate conversion helper, mouse world pos forwarding on mouse motion events, and `refresh()` calls on scene ready.

**Issues:** None. No verification yet (checkpoint 3 is after item 9).

## /checklist

### Sequencing decisions and rationale
Jason's instinct: start with data structures. Correct call — `ShipInstance`, `CellRecord`, `FogShipRecord`, and `ShipDefinitions` are referenced by every downstream system. Final sequence: data model → autoloads → simple scenes → fleet placement → gameplay layout → grid rendering → turn manager → action resolvers (probe/combat, then move separately) → battle log/victory → audio/polish → Devpost.

Move action isolated to its own item (item 10) because the net displacement + preview mode system is significantly more complex than probe/laser/missile.

### Methodology preferences
- **Build mode:** Autonomous
- **Verification:** Yes — summary + in-game verification at checkpoints
- **Checkpoint cadence:** Every 3 items (after items 3, 6, 9)
- **Comprehension checks:** N/A
- **Git cadence:** Commit after each checklist item

### Checklist stats
- 12 items total
- Estimated build time: ~4–5 hours (items vary 15–45 min; move system and grid renderer are the longest)
- 3 verification checkpoints + final submission

### What Jason was confident about vs. needed guidance on
- **Confident:** Data-first sequencing (immediate, unprompted). Autonomous mode (quick decision). Verification model (wanted both summary and in-game check). Git cadence (agreed immediately).
- **Needed clarification:** Step-by-step granularity — asked whether steps were the 8 high-level sequences or more granular items. Good question; confirmed items are more atomic (10–12 items vs 8 sequences).

### Submission planning notes
- Core story confirmed: tribute to dad's Pascal game
- Two wow moments: (1) probe fade mechanic — tactical tension of stale intel, (2) visual artistry — nebula background + probe illumination overlay
- Screenshots planned: fleet placement, gameplay with active probe illumination, ship panel with energy sliders, victory screen
- Deploy to itch.io: yes, via Butler push
- GitHub repo: already public; submission item includes push confirmation

### Deepening rounds
Zero deepening rounds chosen. Jason accepted the proposed checklist without requesting refinement rounds. The sequencing logic and item granularity were clear enough that he didn't need to dig in. The clarifying question about step-by-step granularity was the only point of active engagement — good signal that he understood the structure before committing.

### Active shaping
Minimal but purposeful. Jason set the direction (data structures first) which locked the sequencing. His clarifying question about step granularity showed he was thinking about the actual build experience, not just approving a list. No pushback on item order or groupings — accepted the dependency logic as presented.

## /iterate — Iteration 1

### What the learner chose and why
Audio SFX — all 6 sound effects (laser, missile, probe, explosion, hit, click). No ambient music this round. Jason identified audio as the highest-impact polish item: the code is fully wired up in AudioManager but zero audio files exist. The game is silent, which undermines the space combat atmosphere.

### What the review pass surfaced
- Audio files are the biggest gap between "code complete" and "submission ready"
- Several trivial backlog items exist (instant win, uniform probe cost, cruiser rotation bug) but Jason prioritized audio first — right call for submission impact
- Python + numpy synthesis approach chosen to keep everything in the terminal without manual asset sourcing

### How many iteration items were created
3 items: install numpy, generate 6 SFX files via Python script, verify playback in-game.

### Observations
Jason asked the right process question: "do we write checklist items or just do it here?" Shows he's internalized the workflow and is thinking about when structure helps vs. when it's overhead. He also asked about tool options (numpy vs scipy) and made a clear cost/benefit decision. Working more as a collaborator than a learner at this point — the structured phase served its purpose.

### Build results
- Numpy synthesis produced 6 sounds but they sounded fake. Jason flagged all 6 as needing work — too high-pitched, jarring, artificial.
- Jason suggested switching to open-source CC0 sounds instead of synthesizing — correct instinct. Pivoted to Kenney asset packs (sci-fi-sounds, impact-sounds, interface-sounds), all CC0.
- Also fixed AudioManager timing: weapon SFX (laser/missile) now plays first, impact/explosion follows after a delay so both sounds are audible in sequence.
- Applied ffmpeg fade-in/fade-out to all 6 files to smooth the onset. Jason approved after this pass.
- All 3 iteration items complete.

## /iterate — Iteration 2

### What Jason chose and why
Submission-readiness content work: README, in-game "How to Play" rewrite, itch.io page description. Framing: "I want to get all of those up-to-date, accurate, user friendly, and helpful" before deploying for the Devpost submission. Hackathon deadline is April 29, 2026 (non-competitive Learning Hackathon: Spec Driven Development). Confirmed during scoping that continued iteration is allowed post-submission (Devpost allows edits until deadline, itch.io link is not frozen), so the plan is to submit after this iteration, then do one more iteration cycle before the deadline.

### What the review pass surfaced
- README does not exist at project root. Devpost submission requires a public repo link with instructions, so a README is effectively required.
- "How to Play" overlay is a single 18-line `Label` in `scenes/main_menu.tscn`. Accurate but terse and dense. Missing: hot-seat flow, keyboard reference, Command/Target Grid explanation, probe fade explanation. No visual structure.
- itch.io page description and Devpost project story both blank. These share DNA with the README and with each other, so a single source-of-truth pitch doc was agreed on up front.
- Devpost project story was already bundled into checklist item #12. Clean split chosen: this iteration handles README, in-game tutorial, and itch.io page; item #12 handles the Devpost-specific content and the final submit.

### Key scoping decisions
- **Core pitch file (`docs/pitch.md`)**: single source of truth for reusable content (elevator pitch, taglines, tribute story, feature hooks, bullets, credits). README cribs a paragraph, itch.io description adapts the whole thing, item #12's Devpost content references it. No content written twice.
- **How to Play structure**: Option 3 (paged overlay with Next/Previous buttons) chosen over Option 2 (sectioned single screen). Screenshots need room to breathe, the game's existing polish level calls for a tutorial that matches, implementation cost is modest with a single templated page.
- **Welcome page voice locked first**: Jason provided a seed paragraph about being pulled from hyperspace into an unmapped nebula. The agent drafted a dark-playful second-person version ("a bored god flipping a circuit breaker," "the nebula is watching"). Jason approved with "I love it!" before anything else was scoped, so the voice became the tonal anchor for every other piece of content.
- **WRITING-STYLE.md uploaded**: Jason added `WRITING-STYLE.md` at the project root mid-iteration and asked Claude to adhere to it. Banned words list, no em dashes, no LLM clichés, confident direct voice, active voice, second person. Applied to all Iteration 2 content and to every response in the scoping conversation after the upload.
- **Technical README (Option 2)**: Not a pitch-first README. Setup/run/build-for-web is the primary job. One-paragraph pitch at the top, no hero screenshot. Story lives on itch.io.
- **Early deploy as task 1**: Jason's idea. Deploy the current build to itch.io before anything else. Two reasons: (1) flush out web-export bugs (audio autoplay, path case sensitivity, threading quirks) early rather than at the deadline, (2) give Cowork a live URL to work from for screenshot capture.
- **Failure handling**: Halt iteration on I2-1 failure (option a). No content items proceed on a broken build.
- **Claude Cowork for screenshots and itch.io page setup**: Jason uses Cowork to automate browser-based tasks. Cowork runs in parallel with the build agent's content work. Two Cowork sessions needed: (1) screenshot capture after I2-2, (2) theme update and description upload after I2-6. Two explicit PAUSE comments added to the checklist to tell the `/build` agent to stop.
- **Theme + description upload bundled**: Both are Cowork operations on the same itch.io page edit screen. Combined into one brief (I2-6) rather than two. Cowork applies the theme and pastes the description in a single session.
- **Item #12 held to last**: Two layers of defense. (1) Iteration 2 section inserted above item #12 in the checklist file so `/build` picks up Iteration 2 items first in file order. (2) HOLD HTML comment marker added to item #12 during I2-7's execution as insurance.

### Iteration size
8 items. No artificial cap applied. Items reflect the work: one deploy, two Cowork briefs, three content files (pitch, README, itch description), one item #12 update, one overlay rewrite.

### Observations
Jason is working as a collaborator rather than a learner at this point. He drove the ordering change (early deploy, parallel Cowork), added the theme task mid-draft, flagged the item #12 ordering problem unprompted, and set the Welcome page voice with a specific seed. The structured `/iterate` flow served as a forcing function to turn his ideas into a concrete, ordered checklist with pause points. Noteworthy: he asked the agent's opinion on decisions before making them (theme task bundling, README tone, combat/energy page merge) rather than just dictating, which kept the collaboration honest in both directions.
