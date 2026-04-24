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
