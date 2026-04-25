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

### Step 12: HTML5 export, itch.io deploy, and Devpost submission

**Mode:** Guided-with-gates, not autonomous. Item 12's HOLD LIFTED marker on 2026-04-22 explicitly required explicit user confirmation before each external action. Seven gates, all passed:

1. HTML5 export to `export/web/` via `godot --headless --path . --export-release "Web"`.
2. Local smoke test on `python -m http.server 8000`. Splash → menu → How to Play → Start verified by Jason.
3. Butler push to `zabuuq/battlestations-nebula:html5`. New build #1632255 (version 3) replaces the April 11 I2-1 build #1608182. 99.14% patch savings — the 37 MB wasm blob was unchanged.
4. Live-build verification at the secret URL before public flip.
5. `git push origin main` — pushed e3f071b (I2-11) so the public repo matched the live build.
6. itch.io page flipped Draft → Public via dashboard.
7. Devpost submission.

**What was drafted for submission:**
- `docs/devpost-submission.md` — pasteable source mapping every Devpost form field. Three pages: overview, project details (name, tagline, elevator pitch, project story, built-with tags, try-it links, image gallery, video), and Learning Hackathon feedback (hours, rating, most valuable parts, stuck points, approach change, likelihood of reuse, what to change). Project story rewritten in the Gallows Deadpan voice consistent with the itch.io description and tutorial pages. User-edited tags after generation.
- Elevator pitch (198 of 200 chars): "Hot-seat space combat tribute to my dad's 1980s Turbo Pascal game. Hide five ships in the nebula, fire probes to pull enemies out of fog, then shoot lasers and missiles before your intel goes stale."

**Screenshot refinements done during item 12:**
- Shot 12 converted from a full-viewport capture to a 200×540 LeftPanel crop matching shot 08a's dimensions. Now functions as a matched closeup pair with 08a in the Devpost gallery.
- Shot 13 rewritten to use a seeded-random P1 fleet (SHOT_13_SEED=1337). Camera fills the viewport vertically via `_gameplay_fill_view` (no letterbox gray bands) and pans to the median ship x so the cluster lands in frame. At least three ships visible; the seed constant is the single knob for rerolling.

**Gaps noted:**
- `docs/claude-cowork/itch-page-setup-delivered.txt` was never written during I2-11 (the requirement wasn't communicated to Cowork). Jason confirmed the theme + description upload succeeded in practice and authorized trusting the I2-11 checkbox.

**Memory written during item 12:**
- `project_itch_devlog_on_updates.md` — reminder to draft a Gallows-Deadpan devlog note after every future butler push, for Jason to post manually via the itch.io Devlog editor.

**Backlog additions during item 12:**
- Two-line title treatment on splash / main menu / victory ("Battlestations:" on line 1, "NEBULA" on line 2, fully caps, larger font, stretched to match line 1's pixel width).

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

### I2-1 deploy record (Apr 11, 2026)
- **Live URL (draft with secret, Cowork-compatible):** `https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk`
- **itch.io channel:** `zabuuq/battlestations-nebula:html5`
- **Build:** butler build #1608182 (version 2), promoted from prior #1605057
- **Export:** Godot 4.6.1 headless (`godot --headless --path . --export-release "Web" export/web/index.html`). Project binary on disk is 4.6.1 even though CLAUDE.md spec references 4.6.2 — project.godot only requires the "4.6" feature tag so it works, but flagging for a future fix pass.
- **Page visibility:** Draft, kept draft intentionally for now. Public switch deferred until Iteration 2 is fully done. Secret URL is the access path Cowork (I2-2) and all downstream verification will use.
- **Verification:** WebFetch against the secret URL confirmed a valid itch.io game page rendering `init_ViewHtmlGame`, "Run game" button, Godot tag, and game metadata. No in-browser playthrough run by the build agent; local smoke test skipped per autonomous-mode intent.
- **Open note:** `itch-theme-screenshot.png` is at the project root and got auto-imported by Godot, so it's also bundled inside `index.pck` (trivial, ~43KB). Cleanup deferred to end of Iteration 2.

## /iterate — Iteration 3

Started 2026-04-23. Submission is live; Devpost edit window stays open until 2026-04-29. This pass is the final polish round before the deadline.

### What Jason chose and why
Graphics — specifically a real nebula background. The marketing copy (itch description, Devpost story, How to Play page 1, tagline "Hide five ships in the nebula") leans hard on the nebula concept, but the actual build still ships a flat `Color(0.05, 0.05, 0.15)` rectangle for every background. Closing that gap is the highest-impact visual change available before the deadline.

### What the review pass surfaced
- The nebula was actually in the original spec (`spec.md > Grid Rendering > GridRenderer` rendering layer 1, "nebula background texture") but got placeholdered in the build. This is debt payoff, not a new feature — single-insertion-point in `_draw_background()`.
- The probe illumination overlay is already semi-transparent and drawn on top, so the famous "active probe over nebula" hero shot just appears once a texture is swapped in. No structural changes needed.
- All four static scenes (splash/menu/handoff/victory) share the same flat dark color — natural extension if Jason wanted full atmospheric consistency. He did, picked Option B.
- Backlog scan: three adjacent visual items bundle naturally because they touch files we're already editing — two-line title treatment (splash/menu/victory), ship colors during placement (fleet_placement), wreckage z-order bug (grid_renderer.gd). Pulled all three in at Jason's request.

### Asset sourcing
Jason's constraint: public domain or properly licensed only, no pending-permission images. He directed me to his Envato Elements account (Core plan, unlimited stock downloads, Lifetime Commercial License). Drove the browser via Playwright MCP — he signed in, I searched. Walked through 12 candidate thumbnails across two scrolls; he ranked his top 4 (#4 > #2 > #6 > #8) and picked #4 ("Nebula Cloud Formation in Space with Stars" by AveCalvar, 5333×3555). Downloaded to `assets/backgrounds/nebula.jpg` (13 MB).

Important guidance Jason gave during selection: he wants the nebula to **fill** the frame ("ships are caught in the nebula") and is open to changing the game's color scheme to match the chosen image. Both shaped the checklist — I3-1 uses a centered horizontal-band crop, I3-3 uses Keep Aspect Covered, and I3-6 explicitly samples and applies a new palette.

### Iteration size
7 items. Bigger than the suggested 3-5, but defensible: Jason explicitly chose to expand scope (added all three backlog bundles). Each item maps to a single concern that benefits from its own acceptance/verify entry.

Sequence rationale:
1. I3-1 nebula on grids (the headline change)
2. I3-2 wreckage z-order fix (piggyback on I3-1's file)
3. I3-3 nebula on static scenes
4. I3-4 two-line title (after backgrounds so titles can be tuned against the nebula)
5. I3-5 ship colors during placement (independent visual fix)
6. I3-6 color scheme update (last visual change so palette can be sampled with full context)
7. I3-7 visual sanity + screenshot regen (final, captures everything in one pass)

### Observations
Jason continues to operate as a collaborator: gave clear sourcing constraints up front, used the Playwright session to drive the asset selection himself rather than delegating taste, and proactively asked "Are there any other items in the backlog about the color or look of the game?" — exactly the right question to ask once the iteration scope is forming. The bundling of three backlog items into the iteration came from him recognizing the file-overlap opportunity, not from me pushing it.

### Build summary (autonomous mode)

7 items completed across 3 checkpoints. Sequence held — no checklist revisions. Subagents handled each item; orchestrator paused at every-3 items for in-game verification per the checklist header.

Mid-item user-driven additions (logged as `(cont.)` commits, not separate items):
- **I3-1 (cont.)** `ee7ea67` — probe overlay flipped from cyan-additive (`Color(0.3, 0.7, 1.0, 0.2)`) to black-darken (`Color(0, 0, 0, 0.45)`). Jason's call: "you can see *through* the nebula better." Same commit added the nebula texture to the fleet placement grid (Jason flagged that placement should match gameplay). Both changes belonged conceptually to I3-1 so they were folded back into that step.
- **I3-4 (cont.)** `ad6b174` — title line-1 sizes bumped twice (40→60→56 splash, 28→44→41 main_menu, 16→24→22 victory). The original 2.5× ratio overshot — width-equalizing ratio in the default Godot font is closer to 1.8× because uppercase letters are wide and "NEBULA" is 6 of them.

Checkpoint observations:
- **CP1 (after I3-3):** Approved without tuning.
- **CP2 (after I3-6):** Approved after the title-size tune. Two rounds: first bump (I told user line 1 was likely too small at 40% of line 2 → moved to 60%), Jason said "slightly bigger than NEBULA," tuned down ~7% to land. Subagent's eyeball was workable but needed the human-in-loop pass.
- **CP3 (after I3-7):** Final item is itself a verification pass — subagent ran the screenshot script via the godot CLI runner per CLAUDE.md, spot-checked the regenerated PNGs, reported no tuning needed.

Subagent gotchas worth noting for future work:
- Subagents can't see rendered output. Width-matching font sizes via character-count ratio is unreliable; needs human verification or font metric measurement. Future similar items should either use a measured approach or include explicit "expect to tune at checkpoint."
- The screenshot runner lives at `scripts/debug/screenshot_runner.gd` and is invoked with `godot --path . -- --screenshot`. Subagent had to find Godot's binary (it was at `/c/Users/jcmcc/OneDrive/Godot/godot.exe`). Worth recording for future iterations.
- The `docs/color-scheme.md` rewrite in I3-6 included a "parking lot" note that the itch.io page theme (set in I2-11 from the old palette) is now stale. Cowork follow-up if Jason wants in-game and itch.io to match.

Overall impression: cleanest iteration yet. Nebula was load-bearing for the marketing copy ("hide five ships in the nebula"), and pulling it in closed the gap between what the game promised and what it actually rendered. Probe-darken UX flip was a subtle but important call — turns the probe from "fog" to "clearing." Two-line title is a small pixel win that punches above its weight in the hero shots.

## /iterate — Iteration 4

Started 2026-04-24. Devpost edit window closes 2026-04-29. This iteration is a viewport baseline fix plus a three-bug sweep; Jason listed them unprompted.

### What Jason chose and why
Two concerns driving the pass:
1. **Hi-res scaling.** On large monitors, buttons and text read as too small. itch.io also exposes a "Viewport dimensions" field that Jason wants to set correctly.
2. **Three latent bugs** that have been sitting in `backlog.md` since at least I3 — Cruiser forward-move cost after rotation, first-turn energy regen exceeding max, and the empty-state label persisting in the Ship Panel when a ship is selected.

### What the review pass surfaced
- `project.godot` has **no `[display]` section at all**. Godot's default 1152×648 viewport + `disabled` stretch mode are live. That's why UI looks tiny on big monitors — canvas grows, UI stays pixel-fixed.
- The game's scenes are laid out against 1600×900 in practice. The screenshot runner's crop math at `scripts/debug/screenshot_runner.gd` is keyed to a 1600×900 window, and every in-editor tuning pass so far has been done at that size. So the project's "real" base is 1600×900; `project.godot` just never got the memo.
- Web export preset already has `html/canvas_resize_policy=2` (Adaptive), which is the right setting to pair with `canvas_items` stretch. No export preset change needed.
- Empty-state label bug has a temporary workaround in `_shot_08a_ship_panel_tight()` that needs to be removed once the real fix lands — flagged in the backlog entry.

### Scoping decisions
- **Base resolution:** 1600×900 (matches screenshot runner + existing scene layouts, no re-tuning expected).
- **Stretch mode:** `canvas_items` + `expand` aspect. Scales UI proportionally, text stays crisp (no framebuffer scaling blur), widescreen canvases get extra horizontal space rather than letterboxing.
- **itch.io viewport field:** set to 1600×900 during I4-5 redeploy.
- **Redeploy handling:** I4-5 is guided-with-gates per item #12's model. Three explicit pauses: before butler push, before the itch.io field edit, and at the devlog draft stage. No draft/public state flip — page is already public. Devlog draft is required per `project_itch_devlog_on_updates.md` memory.

### Iteration size
5 items. One viewport/stretch fix, three bug fixes, one gated redeploy.

### Observations
Jason flagged the itch.io viewport field as the trigger for pulling this iteration together. That's a good catch — the field was never set, and the hi-res scaling issue had the same root cause. Bundling the three dormant bugs with the viewport fix also makes the redeploy worthwhile (one butler push, multiple fixes landing together) rather than shipping the viewport change solo.

### Build summary (autonomous + gated)

5 items completed. Autonomous dispatch for I4-1 through I4-4; I4-5 ran in guided-with-gates mode per item #12's model.

Commits (chronological):
- `b7a2c5d` I4-1 — `[display]` section added to `project.godot` (viewport 1600×900, `canvas_items` stretch, `expand` aspect).
- `62eab09` I4-2 — forward-cost discount now tracks post-rotation facing. Fix in `action_resolver.gd::resolve_move` and `gameplay.gd::_update_move_preview` (both passed the pre-rotation facing into `calc_move_cost`).
- `de0c2ae` I4-3 — `turn_start()` energy regen clamps to `max_energy` via `mini()`. First-turn overshoot resolved.
- `d2c6b0e` I4-4 — `ship_panel.gd` caches `_empty_label` and toggles it alongside `_container` in `show_ship` / `show_enemy_ship` / `clear_ship`. Screenshot-runner workaround in `_shot_08a_ship_panel_tight()` removed. Four shots regenerated on-disk (`06_probe_aiming`, `08_ship_panel_sliders`, `10_active_probe_enemy_panel`, `11_probe_closeup`, plus the intended `08a_ship_panel_tight`). Commit bundled the regenerated PNGs.
- `<pending>` I4-5 — deploy commit with checklist tick + devlog draft + this summary.

Checkpoint notes:
- **CP1 (after I4-3):** Jason approved without tuning — "I approve these changes."
- **I4-5 gates:**
  - Gate 1 (local smoke test at `http://localhost:8000`, python http.server): approved with "approve."
  - Gate 2 (itch.io Viewport dimensions field edit to 1600 × 900): Jason executed manually on the live page and confirmed with "I did it."
  - Gate 3 (devlog draft): saved as `docs/claude-cowork/devlog-i4.md`, Gallows-Deadpan voice, ~255 words, titled "Your monitor is not a postage stamp." Three bold lede phrases mirror the I3 devlog structure. Post manually from the itch.io Devlog editor.

Butler push result:
- New build **#1634061** (version 5) replaces prior live **#1632951** (I3 nebula build, version 4).
- 95.08% patch savings — only 3.46 MiB fresh data. Build was processing at push time; should be live on the itch.io URL shortly after the butler push.
- Binary on disk reports Godot 4.6.1; `project.godot` feature tag is `4.6`, so export succeeds. Version-bump to 4.6.2 remains a latent cleanup item (noted originally in I2-1's deploy record).

Overall impression: tight, clean sweep. The viewport fix was the most impactful single change of the iteration — the scenes had been tuned at 1600×900 the whole time, so flipping the stretch mode on essentially unlocked the work that was already done. The three bug fixes were small-surface, low-risk edits with clear root causes; no follow-on ambiguity surfaced during the dispatches.

## /iterate — Iteration 5

Started 2026-04-24 (same day as I4 landed). Devpost edit window closes 2026-04-29. This iteration is a camera/controls rework pulled from the existing backlog.

### What Jason chose and why
Jason asked for the Camera / controls category as a block. The backlog listed four items: scroll+zoom rework, zoom centered on mouse, persist map view between turns, probe activation outside grid. Jason asked for the full backlog list first to orient, then picked the category. When I flagged the click-vs-drag threshold as a new-behavior detail worth confirming, he said "I have nothing to add" — accepted the backlog spec as written.

### What the review pass surfaced
- All three camera items edit the same ~30-line region in `scripts/gameplay.gd::_handle_grid_input` (lines 146-170). Scroll rework and mouse-centered zoom share the zoom math. Natural bundle.
- Probe-activation-outside-grid is filed under Camera / controls in the backlog but is really targeting UX — the early-return on out-of-bounds cells lives in `_handle_grid_click`. Separate concern, but cheap and in the same file.
- Left-click-drag-to-pan requires a click-vs-drag threshold so selection still works. ~4 px is the standard. Called out in I5-1's spec so the implementer doesn't ship a regression where every click pans.
- Current camera defaults are computed in gameplay.gd lines 537-541 (fit-to-grid). Persist-map-view needs to fall back to those when no saved state exists.
- No change to `ActionResolver.resolve_probe` needed for I5-3 — its internal clamp is already correct. Only the gameplay-side early-return needs adjusting.

### Scoping decisions
- **Bundled to 3 items, not 4.** Scroll rework + mouse-centered zoom collapsed into I5-1.
- **Control scheme verbatim from backlog:** scroll=vertical pan, shift+scroll=horizontal, ctrl+scroll=zoom (mouse-centered), left-click-drag empty space=pan, middle-click removed.
- **Camera persistence scope:** per-player, per-grid (command and target independent), reset on new-game-from-main-menu to avoid stale state. No spec.md update required for this iteration — flagged as follow-up doc work.
- **Probe-outside-grid scope:** probe only. Lasers and missiles still reject out-of-grid clicks. Reticule clamp stays as-is.

### Iteration size
Expanded to 6 items after a follow-up pass. After I5-1/I5-2/I5-3 were written, Jason asked "are there any other items in the backlog that are similar?" — that surfaced three adjacent items, and he added all three. Also removed the "Click-to-ghost movement during gameplay" item from `backlog.md` (Jason's call — confirmed after I described the mechanic that it wasn't what he wanted; the item he did want was "Click-to-pick-up during placement," which was already on the list).

Final item list:
- **I5-1** — Scroll + zoom rework (scroll=vertical, shift+scroll=horizontal, ctrl+scroll=zoom mouse-centered, left-click-drag pan with 4 px threshold, middle-click removed).
- **I5-2** — Persist camera position and zoom per player, per grid, across turns. Reset on new game.
- **I5-3** — Allow probe clicks outside grid bounds (laser/missile still reject out-of-grid).
- **I5-4** — Partially probed ships fully clickable. Gate changes from per-cell `has_probe` check to "any cell of this fog ship has an active probe."
- **I5-5** — Click-to-pick-up during placement. Pick-up only fires when nothing is in hand; overlapping click with a ship in hand still silently fails.
- **I5-6** — Stay on Target Grid after probe/laser/missile, auto-switch left panel to Battle Log. No change to Move's post-resolve flow.

No gated redeploy in this iteration — Jason can decide post-build whether to butler push or batch with a future iteration.

### Observations
Jason continues to lean on the backlog as an already-scoped inventory — "give me the list" rather than freeform brainstorming. That keeps the iteration framing fast. The "I have nothing to add" moment on the control-scheme details is a validated-choice signal: the backlog spec was written with enough care that he doesn't need to redo the thinking at iterate time. Worth respecting — don't over-interview when the spec is already clear.

The follow-up "are there similar items?" question paid off — four of six items now bundle into this iteration and three of them touch the same input handler in `gameplay.gd`. Jason also used the moment to prune the backlog: removed the gameplay click-to-ghost item after realizing it wasn't what he'd remembered wanting. Worth noting for future iterations — Jason will ask "what else is adjacent?" when he's picking a theme, and that's a cue to look at file-proximity and pattern-sharing, not just topical similarity.

### Build summary (autonomous mode)

6 items completed across 2 checkpoints. Sequence held — no checklist revisions, but CP1 surfaced three real bugs that needed a dedicated fix pass before continuing.

Commits (chronological):
- `329619e` I5-1 — Scroll/zoom rework. New state vars (`mouse_down`, `mouse_down_pos`, `dragged`, `DRAG_THRESHOLD_PX`), new `_zoom_camera_at` helper for cursor-anchored zoom (`cam.position += world_before - world_after`).
- `952fa97` I5-2 — Per-player camera persistence. `command_camera`/`target_camera` dicts on each `GameState.players` entry; saves on every pan/zoom inside `_handle_grid_input`; restore on `_ready()` after `turn_start`. New-game reset already covered by `GameState.reset()` from main_menu.
- `94c3f74` I5-3 — Off-grid probe clicks. `_handle_grid_click` rebuilt with an `in_bounds` early-return that's bypassed only on `targeting_action == "probe"`; lasers/missiles/selection still reject off-grid.
- `ebbe601` CP1 fix — Three bugs found at the verification checkpoint and patched together: (1) fleet placement still had the old controls; mirrored I5-1's scheme into `fleet_placement.gd::_on_viewport_gui_input`. (2) Grid invisible on first round; the `_fit_camera` fallback in `_restore_camera_state` was overriding scene defaults badly, so the no-saved-state path was made a no-op (scene defaults stand). (3) **Camera state shared between players** — root cause was `turn_manager.turn_end()` flipping `GameState.current_player` *before* `change_scene_to_file`, so the `_exit_tree` safety-net save was writing the outgoing player's camera state into the incoming player's slot every handoff. Removed the safety net; per-input saves cover the normal pan/zoom path.
- `a073502` Polish on the CP1 fix — Jason asked for the gameplay scene's initial zoom to match the placement scene's. Camera2D zoom in `gameplay.tscn` switched from `(0.3, 0.3)` to `(1, 1)` on both Command Grid and Target Grid, so the view scale stays continuous from placement → first turn.
- `0b1d29d` I5-4 — Partial-probe ship selection. New gate in `_try_select_enemy_ship` scans `ShipDefinitions.get_ship_cells(record.ship.ship_type, record.ship.position, record.ship.facing)` for any cell with `has_probe = true`. Fully-faded ghosts stay un-clickable.
- `3e927c6` I5-5 — Click-to-pick-up during placement. New `_find_placed_ship_at(cell) -> int` helper plus `_try_pick_up_ship()` branch on left-release when `selected_ship_idx == -1`. Plays `click` SFX to mirror the strip-button feel; restores `ghost_facing` from the picked-up ship's facing.
- `1c00fe9` I5-6 — Stay-on-target-grid + auto-Battle-Log. Removed the `_switch_grid(ActiveGrid.COMMAND)` call at the end of `_execute_targeting_action`; added `_show_left_tab("battle_log")` after the ship-panel refresh. Move action's post-resolve flow untouched.

Checkpoint observations:
- **CP1 (after I5-3)** — three issues surfaced and were fixed before continuing: placement-scope mismatch on I5-1 (subagent honored my "don't touch fleet_placement" instruction; Jason wanted consistency), `_fit_camera` UX regression on fresh-game first turn, and the cross-player camera leak via `_exit_tree`. The third was the only "real" bug — the other two were scope/spec choices that didn't match what Jason wanted to see. The post-fix polish commit (`a073502`) bumped both gameplay cameras to zoom 1.0 to match placement scene. Jason: "confirmed."
- **Final checkpoint (after I5-6)** — Jason: "looks good." No tuning needed.

Subagent gotchas worth recording for future iterations:
- The "out-of-scope" instruction on I5-1 (don't touch fleet_placement) was correct *per the spec* but wrong *per Jason's expectations* — the new control scheme is a global convention, not a gameplay-only one. Default for control-scheme reworks: assume both placement and gameplay share the scheme unless explicitly scoped otherwise.
- `turn_manager.turn_end()` flipping `current_player` before `change_scene_to_file` is a recurring footgun for any state save in `_exit_tree` that's keyed to `current_player`. Anything saved at scene-exit time on the gameplay scene needs to either save *before* `turn_end()` runs or be keyed to a value that doesn't shift mid-handoff.
- Static-typed casts inside dictionary loops matter — the I5-4 subagent added `as CellRecord` when reading `.has_probe` from a `Dictionary` value. Consistent with the rest of the project; worth keeping.

Overall impression: cleanest control-rework the project has had. Six items shipped with one fix pass at the verification gate; both checkpoints landed without further tuning. The bundling of three input-handler items (I5-1, I5-2, I5-3 all touching `_handle_grid_input`) into the iteration meant the file got its rework in a single coherent pass instead of three drive-by edits, and the per-input save model from I5-2 turned out to be load-bearing for the CP1 cross-player fix — without it, removing the `_exit_tree` safety net would have cost the camera-persistence feature entirely. Bundling paid off.

## /iterate — Iteration 6

Started 2026-04-24. Devpost edit window closes 2026-04-29 (5 days out). I5 landed earlier the same day; this is a second iterate pass kicked off immediately after.

### Entry state
- All original checklist items (1-12) complete.
- I1 through I5 all complete on the checklist.
- Working tree has two uncommitted items from the I5 session: modified `docs/backlog.md` (the click-to-ghost prune) and new file `docs/claude-cowork/devlog-i3-nebula.md` (the I3 devlog brief).
- In-flight outside the checklist: How to Play overlay voice polish, pages 6-9 still in the older matter-of-fact register. Pages 1-5 polished and committed. Page 6 "Strip Shields. Break Armor." is the next resume point per the project memory note.

### Review pass (pre-scope)
Three threads are obvious candidates:
- **HTP polish resume** — pages 6-9 of the How to Play overlay, continuing the Gallows-Deadpan rewrite. Already has validated infrastructure (bold rendering, multi-image schema) and a draft/rewrite/wire-verbatim workflow pattern. Natural continuation of the in-flight work.
- **Backlog UX items** — several live items touch the gameplay loop cheaply: auto-set shield regen slider, clean up enemy ship panel display, hide empty opponent probes in battle log, blind hit clears ghost on that cell, battle log persist across turns, randomize fleet placement button. Most are local edits, not systemic.
- **Backlog visibility items** — Command Grid: show incoming hits / show opponent active probes. Adds hostile-intel visualization to the Command Grid, which today only shows the player's own fleet. More ambitious than the UX items; could be its own iteration.

### What Jason chose and why
Jason asked for the full live backlog list first, then picked the 7 battle-log items as a block. Extended victory statistics was a late add once I flagged it as living on a different surface — Jason said "add it," so all 7 items stay in scope.

Of note: the How to Play pages 6-9 polish thread that the in-flight memory note flagged is already done. Memory updated 2026-04-24 to reflect that the full 9-page overlay is complete.

### Scoping decisions
- **Persistence model** — per-player log stored in `GameState.players[n].battle_log`, capped at 200 entries (cap includes turn dividers), newest-first ordering (top of the side panel = latest action), turn-number dividers between entry blocks. Confirmed twice — Jason explicitly clarified that newest-first means "top of the list" and that this is the side-panel battle log, not the handoff hit count.
- **Near-miss filter** — applies only to the **defender's** view of opponent fire. Shooter still sees "[MyShip] fired. Miss." on their own log regardless. Proximity check is 8-way Chebyshev adjacency to any cell of any of the defender's living ships. Jason re-clarified this mid-conversation to make sure the directionality was right.
- **Opponent subject** — "Enemy" (option 1). Applies to all opponent-action entries that survive the other filters. For opponent probes that found zero ships, the entry is dropped entirely rather than logged as "Enemy" — that's the hide-empty-probes item, which takes precedence over the subject-rewrite.
- **"Shields down!" format** — inline append, with armor overflow shown after the marker when present: "... Hit — 125 shield damage. Shields down! 94 armor damage." When shields are depleted exactly (no overflow), the armor phrase is omitted.
- **Extended victory stats** — 6 rows per player, two-column layout: Probes launched, Laser shots, Missile shots, Total hits, Total damage, Total misses. Dropped per-weapon damage breakdowns and the total-shots-as-sum row as redundant with individual weapon counts.
- **Blind-destroy coloring** — surfaced during spec-writing: when a blind hit destroys an enemy ship, the destroy-red color also has to fall back to hit-red, not just the text suffix. Called out in I6-3 acceptance so the color signal doesn't leak information either.

### Iteration size
4 items after bundling:
- **I6-1** — Persistent per-player battle log (GameState schema, cap, dividers, newest-first render). Structural foundation; has to land first.
- **I6-2** — Opponent-side filters (Enemy subject, empty-probe suppression, near-miss gate). Render-time filters on the replay path.
- **I6-3** — Shooter-side polish (hide destruction on blind hits, Shields down! with overflow). Render-time tweaks on own-fire entries.
- **I6-4** — Extended victory statistics (four new `turn_stats` counters, victory-screen layout bump to 6 rows). Independent surface, can slot anywhere.

Dependency order: I6-1 → I6-2 → I6-3. I6-4 is independent. Build mode stays **autonomous with verification checkpoints every 3 items** per the top of the checklist — checkpoint after I6-3 (end of the battle-log chain) is a natural fit.

### Observations
The backlog list-first approach surfaced a useful pattern: Jason reads backlog groupings as tactical units ("the 7 battle log items") rather than as individual tickets. The tight thematic coupling (all six battle-log items share `_format_fire` / `_format_probe` surface area) and the render-time-filter nature of five of them made scoping quick — only persistence needed real architectural discussion, and the existing `last_turn_results` path gave us a clean staircase from "one turn back" to "full history with filtering."

Mid-conversation re-clarifications (near-miss directionality, side-panel vs handoff) were the right kind of signal: Jason checks his mental model against the agent's and corrects when they diverge, rather than waiting to see wrong output.


## /build — Iteration 6 (autonomous)

**Mode:** Autonomous with verification checkpoints every 3 items, per checklist Build Preferences header.

**Items completed (4/4):**
- I6-1: Persistent per-player battle log with cap, turn dividers, newest-first ordering
- I6-2: Opponent-side filters — "Enemy" subject, empty-probe suppression, near-miss gate
- I6-3: Shooter-side polish — hide destruction on blind hits, "Shields down!" with overflow
- I6-4: Extended victory statistics — 6 rows per player (Probes, Laser shots, Missile shots, Total hits, Total damage, Total misses)

**Checklist revised mid-build:** No. Spec held up through all four items.

**Checkpoint observations from Jason:**

First checkpoint (after I6-3) yielded six issues — a strong bug yield for a three-item batch:
- Defender 's log should name their own hit ship; destruction suffix for defender ships was gated on `has_probe` and incorrectly hidden from the defender.
- Defender near-miss entries should name the nearby defender ship(s) with coords.
- Destroy SFX (explosion) leaked blind-kill info — audio_manager needed the same `has_probe` gate the text already had.
- Turn divider stuck on "Turn 1" — `GameState.turn_number` was never incremented anywhere. Added per-player `turns_played` counter in `turn_end()` and rewired header label + dividers.
- Bold the most-recent (top) entry; unbold when it scrolls down. Switched per-entry `Label` → `RichTextLabel` with BBCode to get true bold.
- Hide the battle log scrollbar while preserving scroll behavior. `SCROLL_MODE_SHOW_NEVER` on the `ScrollContainer`.

Two follow-up issues after the first fix round:
- Divider should be pushed at turn END, not turn START — with newest-first rendering, the divider needs to be LAST in the push order to cap the turn from above. Moved "Your turn" push into `turn_manager.turn_end()`; moved "Enemy turn" push to after the replay loop in gameplay `_ready()`.
- Near-miss with two ships of the same type showed singular "Destroyer" instead of "Destroyers". Stopped deduping ship types in `_filter_opponent_entry`; formatter now counts per-type and pluralizes when count > 1.

One further edge case:
- Enemy turn divider only fired when `last_turn_results` was non-empty — so opponent-did-nothing vs opponent-did-only-filtered-stuff rendered differently. Changed to fire whenever opponent.turns_played > 0, with a "Nothing to report." entry inserted below the divider when no entries survive filtering.

I6-4 passed final verification cleanly.

**Overall impressions:**

Jason's verification habit is doing real work — not rubber-stamping. Nine real defects caught across two checkpoint rounds, each with precise reproduction framing (what happened, what should happen, sometimes the cause hypothesis). The agent-orchestrator pattern held up well: four subagents dispatched sequentially with the full spec + architectural context, and each returned clean commits. No subagent had to reopen an earlier file the next agent touched, which suggests the item boundaries were well-drawn.

The hidden-fleet-information-discipline theme kept surfacing as a unifying constraint — every filter, every SFX gate, every format branch comes back to "what can this player legitimately know?" That framing made the fixes feel coherent rather than ad-hoc, and made the backlog-batch approach (7 items → 4 items after bundling) trivially obvious in hindsight.


## /iterate — Iteration 7

Started 2026-04-25. Devpost edit window closes 2026-04-29 (4 days out). I6 landed yesterday.

### Entry state
- All checklist items 1–12 complete.
- I1 through I6 all complete on the checklist.
- Working tree: clean.
- Memory note `project_how_to_play_polish.md` confirms HTP voice polish is done (all 9 pages).

### Backlog cleanup (pre-scope)
Pruned 7 stale rows from `docs/backlog.md` before scoping I7. Three items had been done in earlier iterations but never crossed off (#14 partially-probed-ship clickability done in I5-4; #16 ship colors during placement done before; #21 wreckage z-order done before). Four bug rows had been quietly fixed: cruiser forward-cost-after-rotation (I4-2), first-turn energy regen cap (I4-3), empty-state ship panel label (I4-4), two-line title treatment (I3-4). Final remaining-row count: 57 table rows (was 64). Worth recording as a recurring pattern — backlog needs a sweep at iteration boundaries because items get fixed during related work without landing as their own backlog deletion.

### What Jason chose and why
The 6-item Battle Log / Hit Display cluster — every backlog row that touches "what shows on Target Grid or Command Grid about probes, hits, and misses." Jason picked it as a category after asking for the live backlog list and the long-term list together, then drilled into specific items (#14, #16, then #19–23) to confirm what was already done. Once the surviving items were clear, he picked the cluster wholesale.

### What the review pass surfaced
- Items 1, 2, 3, 6 all touch the Target Grid. Items 4 and 5 are the only Command Grid additions in the iteration.
- All six bundle cleanly because they share `grid_renderer.gd` plus 1–2 small touchpoints in `action_resolver.gd` (resolve_probe scan, resolve_laser/missile blind-hit branch).
- The data for item 4 is already in place — I6 added `battle_log` with `owner=1` opponent fire entries that include `target`, `hit`, `turn_number`. Render-only addition, no resolver work needed.
- Item 5 only needs read-only access to the opponent's `cell_records` plus the `_collect_defender_living_cells()` helper that already exists from I6 (`gameplay.gd` line 114).
- Item 1 fix is one line each in `resolve_laser` and `resolve_missile` — clear `record.ship = null` alongside the existing `record.has_blind_hit = true` write. The renderer already gates ghost ship rendering on `record.ship != null`, so the fix is purely a state-clear, no draw-order change.
- Item 2 (wreckage visible in newly probed areas) currently fails because `find_ship_at_cell` skips destroyed ships at line 18. Fix is a parallel scan over destroyed ships in `resolve_probe` plus matching cell-record writes; renderer already handles `last_armor <= 0 && any_probed` wreckage drawing.

### Scoping decisions
- **Item 5 reveal trigger — presence-based, not move-triggered.** Backlog text "(not revealed preemptively)" was ambiguous; Jason chose the simpler reading: the boundary shows whenever any of the player's living ships is inside an active opponent probe area, regardless of how the ship got there. "Not preemptively" interpreted as "not shown during real-time move-action planning before the move actually happens." Re-evaluation triggers: scene load (handled by existing `refresh()` in `_ready`) and after each completed move action (new `queue_redraw()` call to add).
- **Item 3 X-marker style — diagonal lines, no glyph asset.** Two `draw_line` calls per X. Two intensity levels (current turn full, older faded). Tracked via new `has_miss: bool` flag and `miss_turn: int` field on `CellRecord`.
- **Item 6 historical probe marker style — thin 1px interior border, faint blue tint.** Drawn between nebula background and active probe overlay. Skipped on cells with active probe coverage (active overlay takes precedence).
- **Item 4 fade pattern — 2 turns visible, gone on turn 3.** Backlog spec was already specific; no judgment call needed. Source-of-truth is the player's own battle log filtered for opponent fire entries by `turn_number`.
- **CellRecord schema additions — minimal.** Only two new fields total across the iteration: `has_miss: bool` (item 3), `was_probed: bool` (item 6). No structural rewrites.
- **Iteration size — 7 items.** Six feature items (one per backlog row, no bundling) plus one gated deploy/devlog/cleanup item. Larger than the 3–5 cap the iterate skill suggests, but consistent with I3 (7 items) and I5 (6 items) which similarly expanded scope at Jason's request. Each item maps to a single concern that benefits from its own acceptance/verify entry, and the 6 backlog items each test independently.
- **Build mode — autonomous with verification checkpoints.** Two checkpoints: after I7-3 (end of Target Grid items) and after I7-6 (end of Command Grid items). Final item I7-7 is gated like I4-5 with three explicit pauses (smoke test, butler push, devlog draft).
- **Backlog cleanup folded into I7-7.** Same commit as the devlog draft and the build summary appendage.

### Observations
Jason's iteration framing has stabilized into a repeatable pattern: ask for the live backlog list, drill into items he suspects are already done, prune them, then pick a category wholesale. Three iterations in a row now have started this way (I5, I6, I7). The "are these already done?" check at the start of I7 caught seven stale rows — bigger cleanup than usual because no one had swept the list since I3. Worth recording: backlog hygiene is iteration-boundary work, not in-flight work.

The scoping question on item 5 was the only design call requiring real input. Jason gave a clean "what you have laid out looks great to me" once I framed the two readings explicitly — same pattern as I5 ("I have nothing to add" on the click-vs-drag threshold). When the spec is already substantively reasoned through, he doesn't need to redo the thinking; he just needs the choices laid out. Don't over-interview when the design has already been done.
