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

## /build — Iteration 7 (paused at Checkpoint 1, resume on new computer)

Started 2026-04-25. Working through I7 autonomous build. I7-1, I7-2, I7-3 shipped. Pausing at Checkpoint 1 so Jason can switch computers; resume by running `/build` on the new machine after `git pull`.

### Read this first when resuming

There is **one open bug** still blocking the move past Checkpoint 1. Fix it before doing anything else (do NOT proceed to I7-4 first). After the fix, walk Jason back through the Checkpoint 1 verification path, and once approved, mark task #4 completed and dispatch I7-4.

### Commits landed during the session

In order:
- `4ad6000` Complete step I7-1: Blind hit clears ghost ship reference on that cell only
- `58b50e2` Complete step I7-2: Wreckage visible in newly probed areas
- `4c6cfc8` Complete step I7-3: Miss indicators on Target Grid with persistence and decay
- `c90bf8e` Fade miss Xs to gray instead of desaturated red (Jason's color tweak — `COLOR_MISS_FADED` switched from desaturated red to `Color(0.6, 0.6, 0.6, 0.4)`)
- `5758a8b` Fix I7-1/I7-3 ghost+miss+hit interaction; add hit-marker fade
- `7bd9e4a` Preserve ghost ship intel when enemy ship moves (gated old-cells loop in `_update_opponent_probes_after_move` on `record.has_probe`)
- `6b1b097` Hide ghost ship cells where a miss has landed (renderer filter on `has_miss` in the living fog ship draw pass)

### Behavior reversals from the original I7-1 spec — important context

The original I7-1 task said "blind hit clears ghost ship reference on that cell." Jason course-corrected during Checkpoint 1: hits on a ghost cell should KEEP the ghost; only **misses** should clear ghost markers. The realized behavior in the codebase now is:

- **Hit (blind) on a ghost cell:** shows the hit dot, clears any miss X on that cell, keeps the ghost rendering.
- **Miss on any cell:** shows the miss X, clears any prior hit (`has_blind_hit`, `hit_turn`) and clears `record.ship`. Renderer also subtracts the miss cell from any overlapping ghost ship (the renderer filter in `6b1b097`).
- **Hit + miss now share the same color palette:** `COLOR_HIT_FULL` / `COLOR_MISS_FULL` = desaturated red `Color(0.8, 0.4, 0.4, 0.9)` for the current turn; `COLOR_HIT_FADED` / `COLOR_MISS_FADED` = gray `Color(0.6, 0.6, 0.6, 0.4)` for older turns. Glyphs (filled circle vs X) differentiate them.

The I7-1 checklist item title in `docs/checklist.md` still reads "Blind hit clears ghost ship reference on that cell only" — that's now misleading. Don't bother editing it; the realized behavior is captured in commits and these notes.

### THE BUG TO FIX BEFORE PROCEEDING

Jason reported, immediately before pausing:

> Player 1 ghost ships on target grid. Player 2 moved one ship backward one square, another forward one square, and the third one pivoted. New ghost ships appeared where Player 2's ships are now located. A player should not see any kind of movement from their opponent's ships if they are not in an active probe.

**Root cause:** Two helper functions update opponent fog records on EVERY cell where `record.ship != null`, not just cells with `record.has_probe == true`. So when an opponent moves or fires shield regen, the player's ghost cells get rebuilt to point at the OPPONENT's new FogShipRecord (which carries the new position). The renderer then collects two FogShipRecords (the old one frozen on cells that didn't get touched, and the new one written to cells the moved ship now sits on) and draws BOTH ghosts — original at old position, new at new position.

**Files and fixes:**

1. **`scripts/gameplay/turn_manager.gd::_refresh_opponent_probes_after_regen`** (around line 74-88). Current inner gate is `if record.ship != null:`. Change to `if record.has_probe:`. This stops shield-regen from leaking the opponent's current position and live shield/armor numbers into the player's ghost markers.

2. **`scripts/gameplay/action_resolver.gd::_refresh_probe_records_for_ship`** (around line 397-408). Same pattern, same fix. Inner gate is `if record.ship != null:`. Change to `if record.has_probe:`. This is called after laser/missile damage — the attacker should see updated shields/armor on actively probed cells but ghost cells should freeze at the FogShipRecord they had when the probe last saw the ship.

Both fixes are one-line each. Commit them together — same root cause, parallel logic.

**Suggested commit message:**
```
Freeze ghost FogShipRecords against opponent move/regen leaks

_refresh_opponent_probes_after_regen and _refresh_probe_records_for_ship
were updating ship references on every cell where record.ship != null.
That leaked the opponent's current ship position and live stats into
ghost cells, causing new ghosts to render at the opponent's new
positions whenever they moved or regenerated shields. Gate both updates
on record.has_probe so only active-probe cells receive live updates.
Ghost markers stay frozen at the FogShipRecord captured when the probe
last saw the ship (per PRD 4.3 / 5.3 — ghost intel is a snapshot).
```

### Verification path after the fix

1. P1 probes a P2 ship. Skip enough turns for the probe to expire — only ghost remains on P1's target grid.
2. P2's turn: move that ship backward one square, pivot another, slide a third forward.
3. P1's next turn: target grid should show ghosts at the OLD positions ONLY. No new ghosts at P2's new positions.
4. Bonus check: P2 fires shield regen on a probed-then-ghosted ship. P1's ghost ship card (if visible via clicking) should NOT show updated shield numbers — values should stay frozen at the last probe snapshot.

After Jason confirms the fix, also re-run the original Checkpoint 1 path (blind hit + ghost; miss + ghost; gray fade for older hits/misses; ghost preservation when opponent moves the ship to a non-overlapping position) to make sure nothing else regressed.

### State to set after Checkpoint 1 clears

- Mark task #4 (Checkpoint 1) `completed`.
- Mark task #5 (I7-4) `in_progress`.
- Dispatch the I7-4 subagent (Historical probe overlay on Target Grid). Prompt structure should mirror I7-1/I7-2/I7-3 dispatches: surgical context, no `git add -A`, ask for under-200-word report with commit SHA. The full I7-4 spec is in `docs/checklist.md` — load just that one item.

### Backlog deltas added during this session (8 new rows, post-I7 candidates)

These are appended at the bottom of `docs/backlog.md` "Ideas Surfaced During Development" table. None are committed to an iteration yet:
- Reverse shift+scroll horizontal pan direction
- Cell info tooltip on Target Grid hover (last probe / hit / miss with turn numbers)
- Rename "Energy after sliders:" → "Energy after use:"
- Probe Ship laser slider defaults to 100 (max stays 200)
- Always-visible split left panel (ship panel top 2/3, battle log bottom 1/3)
- Ship Panel as accordion ship list (clickable names expand + select on Command Grid)
- Nebula extends beyond grid bounds (fills viewport at full zoom-out, scales with camera)
- Escape cancels in-progress action (probe/laser/missile/move)

Worth raising at Jason's next iteration scope conversation. The split-panel + accordion pair, and the nebula-extends-bounds item, are bigger structural changes that would warrant their own iteration.

### Outstanding state at pause time

- **Tasks:** #1, #2, #3 completed. #4 (Checkpoint 1) in_progress. #5–#9 pending.
- **Working tree:** Clean after the resume-notes commit (this commit). Checklist ticks for I7-1/I7-2/I7-3 included.
- **Branch:** `main`, ahead of `origin/main` by all I7 commits. Not pushed.
- **Build mode:** Autonomous with verification checkpoints every 3 items per checklist header. Do not switch modes.

## /build — Iteration 7 (resumed and shipped)

Resumed 2026-04-25 on the new computer. The pause-time bug was the single
most surprising thing in I7: gating `_refresh_opponent_probes_after_regen`
and `_refresh_probe_records_for_ship` on `record.has_probe` instead of
`record.ship != null` was a one-line fix that closed a multi-symptom leak.

### Commits landed during the resume

In order:
- `230ca72` Freeze ghost FogShipRecords against opponent move/regen leaks (pre-I7-4 fix)
- `11f05a4` Filter ghost cells by exact fog ref, not just has_miss (Checkpoint 1 follow-up after Jason found a ghost-resurrection bug post-miss-then-hit)
- `d5a31a6` Complete step I7-4: Historical probe overlay on Target Grid
- `573c88b` Complete step I7-5: Command Grid incoming hits and near misses with fade
- `e3d53a9` Complete step I7-6: Command Grid opponent active probe boundaries
- `62a5116` Fix I7-5/I7-6 checkpoint regressions: per-probe gating + time-based fade

### Bugs found at Checkpoint 2 (one autonomous-build pattern worth noting)

Checkpoint 2 surfaced two real regressions that the subagents missed:

1. **I7-6 boundary gate was global, not per-region.** The original implementation set `gate_open` once any ship overlapped any probe cell, then drew boundaries around every probe cell in `probe_cells`. Result: an opponent probe over empty space drew a boundary the moment any *other* probe of theirs overlapped one of the viewer's ships. Jason caught it with a clean five-probe repro (two overlapping, three not) and the screenshots made it obvious. The fix groups `has_probe` cells into 4-connected components and only emits contours for components that overlap a viewer ship cell.

2. **I7-5 fade was log-driven, not time-driven.** The agent computed `latest_opp_turn` by scanning the battle log for the largest `turn_number`. If the opponent didn't fire on a cycle, the reference didn't advance, so old markers stayed full-intensity indefinitely. The fix reads `GameState.players[1 - current_player]["turns_played"]` directly so the fade tracks the player's turn cadence regardless of whether the opponent fires.

Lesson: when a subagent completes a feature and reports clean acceptance, the spec's acceptance bar is what got tested in their head, not what the human will exercise in five minutes of free play. Keep verification checkpoints frequent enough to catch these before the rationale fades.

### Devpost / Devlog deliverables landed

- **Build #1636456** pushed to itch.io via butler. 99.74% patch savings; 182.85 KiB patch over 234.80 KiB fresh data. Replaces previous live build #1635102.
- **Devlog brief** at `docs/claude-cowork/devlog-i7.md` — title "The grids stop forgetting", ~280 words, three bold lede phrases, Gallows-Deadpan voice. Jason posts it manually from itch.io's Devlog editor.
- **Backlog cleanup:** removed six rows from `docs/backlog.md` corresponding to the six I7 features (blind hit clears ghost; wreckage visible in newly probed areas; miss indicators on Target Grid; Command Grid incoming hits + near misses; Command Grid opponent active probes; historical probe overlay).

### Outstanding state at I7-7 close

- **Build:** complete. All checklist items checked.
- **Branch:** `main`, all I7 commits about to be pushed to `origin/main`.
- **Live game:** itch.io build #1636456 processing → live shortly.
- **Next steps for Jason:** post the devlog brief manually, link it back into Devpost if useful, and consider scoping Iteration 8 from the eight backlog deltas added during the I7 session (split-panel + accordion + nebula-extends-bounds are the biggest structural ones).

## /iterate — Iteration 8

Started 2026-04-25. Devpost edit window closes 2026-04-29 (4 days out — same window noted at I7 start, so 0 days have elapsed since I7 close from a deadline-counting perspective).

### Entry state
- All checklist items 1–12 complete, plus I1 through I7 (38 iteration items shipped).
- Working tree: clean.
- Last commit `db0c2dd` shipped I7-7 (redeploy + devlog + backlog cleanup).
- Live build on itch.io: #1636456.
- Backlog (`docs/backlog.md`) currently has ~22 surviving "Ideas Surfaced During Development" rows after the I7 cleanup, plus the long-term/exploratory section.

### What Jason chose and why
A 10-item bundle of small wins drawn from the live "Ideas Surfaced During Development" backlog table. Jason asked to see the list, then picked a dense slice across categories: input direction tweaks, label rename, slider default, keyboard escape, randomize button, instant win, two probe-rule data tweaks, auto-shield-regen, enemy-panel cleanup. Skipped during selection: #8 no-blind-hit-on-partially-probed, #11 direct vs partial hits (both have unresolved design questions), #14 audio (already shipped in I1 — likely a stale row).

### What the review pass surfaced
Three observations shared with Jason before scoping:
1. **#7 ghost-ship facing indicator was mostly already there** — `grid_renderer.gd:357-360` calls `_draw_facing_triangle` on the ghost path but gates it on `any_probed`. Work would have been a 5-line ungate. Jason chose to remove this item from the iteration AND from the backlog (deleted the row).
2. **#4 escape was half-done** — `gameplay.gd:597` already maps Escape to move-cancel during move preview. Real work is wiring it into the probe/laser/missile targeting handler.
3. **#9 + #10 have docs ripple** — both rule changes touch `prd.md`, `spec.md`, `fleet_placement.gd:92` strip-detail string, and the How to Play "Probes Are Flashlights" page. Each item is ~3-4 touchpoints, not one.

Final iteration count: 10 feature items + 1 gated deploy = 11 items (matches I7's size).

### Scoping decisions
- **#5 Randomize button** — placement: top of left ship-list panel, ABOVE the strip buttons, separated by an `HSeparator` so it visually reads as a non-ship action. Behavior: full clear + re-randomize on every click (option b — wipes manual placements). Repeated clicks cleanly re-randomize.
- **#12 Auto-shield-regen** — fires at damaged player's `turn_start` (after +50 regen). Formula: `min(max_shields - current_shields, 250, current_energy)`. Override behavior: option (c) — only auto-set if the player has never manually moved that ship's shield regen slider. Once they touch it, the auto-set never fires for that ship again, even if they move it back to 0. Implementation: per-ship `shield_regen_manually_set: bool` flag on `ShipInstance`, flipped true in `ship_panel.gd::_on_shield_slider_changed` (NOT in programmatic slider writes). Locked in without explicit confirmation per auto-mode operating rules; flagged for Jason's review.
- **#13 Enemy panel cleanup** — straightforward from code inspection; no design call needed. Cache the two `HSeparator` nodes (`ship_panel.gd:50` and `:99`) plus the "Actions:" label (`:102`) during `_build_ui`, hide them in `show_enemy_ship`, restore in `show_ship` and `clear_ship`. Result: enemy panel shows only name + shields/armor.

### Backlog deltas
Removed 1 row mid-scoping: "Ghost ship facing indicator" (Jason said "second thoughts" and asked to drop both from iteration and backlog). I8-11 will remove the 10 corresponding rows on close.

### Build mode
Autonomous per the top-of-file preferences. Verification checkpoints land naturally after I8-3 (small fixes), I8-6 (controls + randomize + instant win), and I8-10 (rule changes + UI polish). Final item I8-12 is gated like I4-5/I7-7 with three explicit pauses (smoke test, butler push, devlog draft).

### Late add — I8-11 tutorial + screenshot refresh
Jason flagged that the iteration's visible changes (Randomize button, 7×7 Probe Ship area, "Energy after use:" label, Probe Ship slider default, stripped enemy panel) need a How to Play page rewrite plus a screenshot regeneration before deploy. Originally requested as "before I8-10," but the dependency runs the other way: shot 10 (`10_active_probe_enemy_panel.png`) shows the enemy ship panel that I8-10's cleanup visibly changes, so the screenshot pass needs to run AFTER I8-10 to capture the cleanup in one go. Inserted as **I8-11** instead, deploy shifts to **I8-12**. Iteration is now 12 items.

I8-11 covers: tutorial copy edits to Fleet Placement (Randomize), Probes Are Flashlights (7-by-7 + uniform 50-energy), Energy & Shields (auto-regen mention), and any other page that references the old "Energy after sliders" label. Screenshot pass spot-checks shots 03, 04, 06, 07, 08, 08a, 10, 11. Voice workflow per memory: agent drafts, Jason runs through Grammarly, agent applies polished text verbatim.

### Observation on the iteration pattern
Same pattern as I7: Jason asked for the live backlog list, drilled into items he wanted to verify weren't already done, made one mid-scoping cut (the ghost-facing item) based on the review pass surfacing it as nearly trivial, then locked the scope. The auto-mode reminder during the final design call (#13) let me skip the third interview question entirely — the code structure made the answer obvious. Three interview questions across the conversation (one per non-trivial item: #5, #12, then auto-resolved #13). Continues the pattern noted in I7: when the design has been done substantively in the backlog text, don't over-interview.

## /build — Iteration 8 (shipped)

Shipped 2026-04-25 in the same session that opened it. Auto mode plus the three checkpoint structure (after I8-3, I8-6, I8-10) meant the iteration didn't pause for verification gaps — Jason verified at each checkpoint, course-corrected once, flagged unrelated bugs to the backlog, and confirmed.

### Commits landed during the iteration

In order:
- `313c317` Complete step I8-1: Reverse shift+scroll horizontal pan direction
- `3ef504e` Complete step I8-2: Rename "Energy after sliders:" to "Energy after use:"
- `80ec6ff` Complete step I8-3: Probe Ship laser slider defaults to 100
- `f088930` Course correct I8-3: default all ships' laser slider to 0 (Jason called the change at Checkpoint A)
- `6623cbc` Complete step I8-4: Escape cancels probe/laser/missile targeting
- `e59ac67` Complete step I8-5: Randomize fleet placement button
- `9f0c724` Complete step I8-6: Instant win on last kill
- `4ab5868` Complete step I8-7: Uniform probe cost (50 energy for all ships)
- `8d516a5` Complete step I8-8: Increase Probe Ship probe area to 7×7
- `2d3d382` Complete step I8-9: Auto-set shield regen slider on first damage
- `40d50dd` Complete step I8-10: Clean up enemy ship panel display
- `c60ee81` Complete step I8-11: How to Play Randomize callout + screenshot refresh

### Course correction at Checkpoint A (worth noting)

I8-3 as written said the Probe Ship's laser slider should default to 100 and other ships should "stay at 0." The pre-existing default was actually `stats["laser_strength"]` (250 for Battleship/Destroyer/Cruiser, 100 for Probe Ship — set during the original item-9 fix). The first I8-3 commit followed the spec literally: 100 for Probe Ship, 0 for everyone else, which silently dropped the other ships from 250 to 0. Jason saw the implication at Checkpoint A and called for ALL ships to default to 0 (including Probe Ship). Course correction landed in `f088930`.

Lesson: the two-step confirm at Checkpoint A worked exactly as intended — the orchestrator surfaced the unintended behavior change in the checkpoint summary instead of burying it, and Jason redirected before the iteration shipped on a wrong default. Keep checkpoint summaries explicit about side effects, especially when the spec assumed a state that turned out to be wrong.

### Backlog deltas added during the iteration (3 new rows, post-I8 candidates)

Jason flagged three Target Grid / probe-related observations mid-iteration, decided not to fix them inline, and asked for them on the backlog for the next iteration (where he also plans to rework probes more broadly). Added at the bottom of the "Ideas Surfaced During Development" table:

- Bug: destroyed ships render above other ships on Target Grid (the Command Grid two-pass z-order from I3-2 needs to be mirrored on the Target Grid render path)
- Hit/miss markers: unify Command Grid coloring with Target Grid (I7-3 vs I7-5 used different palettes; pick one and apply to both)
- Ship visibility around active probes is buggy (umbrella row for the probe-rework iteration; ships entering/leaving/moving inside an active probe area still produce wrong fog state in some cases)

The middle two are small. The third is structural and lines up with Jason's stated intent to rework probe mechanics next iteration, so the row exists so the smaller fixes don't ship piecemeal.

### Tutorial copy decisions

Drafted four edits across pages 2 (Place Your Fleet), 5 (Spend Your Energy), 6 (Probes Are Flashlights). Jason accepted only the page 2 Randomize sentence, declined the page 5 auto-shield-regen mention and the page 5 "Energy after sliders" → "Energy after use" relabel, and declined the page 6 uniform 50-energy callout. Page 5 still references the old "Energy after the sliders" label as a result — flagged but left in per Jason's call. The reader still parses it correctly even with the stale label name, and Jason owns the call.

### Devpost / Devlog deliverables landed

- **Build #1636747** pushed to itch.io via butler. 91.17% patch savings; 6.12 MiB patch over 6.78 MiB fresh data. Replaces previous live build #1636456.
- **Devlog brief** at `docs/claude-cowork/devlog-i8.md` — title "Less menu math, more space confetti", ~310 words, four bold lede phrases, Gallows-Deadpan voice. Jason posts it manually from itch.io's Devlog editor.
- **Backlog cleanup:** removed 10 rows from `docs/backlog.md` corresponding to the ten I8 features (shift+scroll flip, "Energy after use" rename, Probe Ship laser default, Escape cancels targeting, Randomize button, instant win, auto shield regen, enemy panel cleanup, uniform probe cost, 7×7 Probe Ship area).

### Outstanding state at I8-12 close

- **Build:** complete. All checklist items checked.
- **Branch:** `main`, all I8 commits about to be pushed to `origin/main`.
- **Live game:** itch.io build #1636747 processing → live shortly.
- **Next steps for Jason:** post the devlog brief manually. Consider scoping Iteration 9 from the three new bug rows (probe rework being the headline) plus whatever else has accumulated in the backlog.

## /iterate — Iteration 9 (opening)

Started 2026-04-25. Devpost edit window closes 2026-04-29 (4 days out — same window noted at I7 and I8 starts).

### Entry state
- All checklist items 1–12 + I1 through I8 complete (49 iteration items shipped).
- Working tree: clean.
- Last commit `4326095` shipped I8-12 (redeploy + devlog + backlog cleanup).
- Live build on itch.io: #1636747.
- Backlog: probe-cluster items live in two places — Ideas Surfaced (`Ship visibility around active probes is buggy` umbrella, `No blind hit on partially probed ships`, `Probe activation outside grid`) and Long-term/Exploratory (`Partial probe reveal on ships`).

### What Jason chose and why
A structural rework of probe reveal. Today's contract — "any probed cell of a ship reveals the whole ship via writer extrapolation" — has produced a class of fog-state bugs around moves and damage updates inside active probe areas, plus what Jason described as gameplay awkwardness ("too many variables, made the game awkward"). New contract: partial reveal — only cells literally inside the probe area are revealed; cells outside stay unknown.

### What the review pass surfaced
1. **#3 (probe activation outside grid) is already shipped.** `gameplay.gd:294-316` explicitly accepts off-grid clicks for probe targeting and clamps the probe center inside `_execute_targeting_action`. Stale row — drops in I9-3 cleanup.
2. **#1 umbrella (active-probe visibility bugs) collapses into the rework.** Tracing the bug class: the multi-fog-record-per-ship state created by the writer's extrapolation step is the source of the ambiguity. Removing extrapolation removes the bug class. No separate fix needed.
3. **#2 (no blind hit on partially probed ships) flips meaning, not deletion.** Today's phrasing is "blind hits on un-probed cells of a probed ship are noise." Under partial reveal, hitting an un-probed cell of a partially revealed ship gives genuinely new information ("the destroyer extends this way"). Code-wise, the blind-hit writer is already cell-local — it gates on whether THAT cell has an active probe, not whether any cell of the ship does. So the flip is a no-op in code; it just becomes a backlog row whose original phrasing no longer applies.

Net: items 1, 2, 6 collapse into a single mechanic-rework item. Item 3 is shipped already. Final iteration count: 3 items (rework + docs/screenshots + gated deploy).

### Scoping decisions
- **Bundle writer + renderer in I9-1.** Splitting them creates an intermediate state where the writer no longer extrapolates but the wreckage renderer still does — broken visuals between commits. Bundle is correct.
- **Visual contract — option (c).** Probed cells render as ship cells (ship-type colored), facing triangle ONLY on the front cell if it's itself probed. Stats panel still opens with full data on click of any probed cell. Confirmed with Jason.
- **Ghost markers — per-cell.** When a probe expires, only the cells that were probed AND contained ship at expire time become per-cell ghosts. Un-probed cells of the same ship leave nothing. Clicking a ghost cell does NOT open the Ship Panel (current behavior, confirmed unchanged).
- **Wreckage — per-cell.** Same rule: only probed wreckage cells render.
- **Screenshot runner — needs a touch in I9-2.** Shot 11's canned `make_ship_ghost` setup writes a full-ship ghost; under the new mechanic that's inaccurate. Adjust the runner setup to write per-cell ghosts on a subset of the destroyer's cells.

### Build mode
Autonomous per top-of-file preferences. Verification falls naturally after I9-1 (mechanic correctness — the heaviest item) and I9-2 (docs + screenshots). Final item I9-3 is gated like I4-5 / I7-7 / I8-12 with three explicit pauses (smoke test, butler push, devlog draft).

### Observation on the iteration pattern
Jason asked for the live backlog list, requested a numbered re-print, then steered the discussion to the underlying mechanic before scoping items. Two design questions surfaced in conversation: (1) what does a probed cell render as (answered (c) + full stats on click), (2) how do ghosts/wreckage behave under the new contract (answered: same per-cell rule). The /iterate review pass surfaced #3 as already-shipped and #1 as auto-fixed by the mechanic change — both findings reduced scope without losing intent. Same pattern as I7 and I8: when the design has been done substantively in the conversation, don't over-interview; confirm the corners and write the spec.

## /build — Iteration 9 (shipped)

Shipped 2026-04-25 in the same session that opened it. Three checklist items, two checkpoints (after I9-1, after I9-2 course correction), one gated three-pause redeploy.

### Commits landed during the iteration

In order:
- `35e6013` Complete step I9-1: Partial probe reveal — writer + renderer
- `f29bf59` Complete step I9-2: Docs + How to Play tutorial + screenshot regeneration
- `64fb9c7` Course correct I9-2: let the screenshot show partial reveal, drop the tutorial rewrite
- `f87baf7` Refine I9-2 partial-reveal screenshot

### Course correction at I9-2 checkpoint

The first I9-2 commit included a tutorial rewrite of "Probes Are Flashlights" (Gallows Deadpan voice, partial-reveal-aware) plus a partial-reveal note in the screenshot brief. Jason called it back at checkpoint: the mechanic is self-evident in play, and a screenshot beats a paragraph. Reverted the tutorial copy and brief edits verbatim. Spec docs (PRD §4.3, §5.2; spec ActionResolver / FogShipRecord / GridRenderer) stayed in — those are spec-of-record, not user copy.

The screenshot itself went through two iterations. First version: a 7×7 probe at (72, 8) catching 3 of 5 battleship cells plus the full cruiser. Jason wanted it tighter — single battleship cell, with that cell being the front so the facing triangle reads. Final version: probe relocated to (72, 16) catching only the battleship's bow at (70, 13), cruiser relocated to (74, 15) facing east so both its cells land in the same probe area. Crop shifted down to (394, 556).

Lesson: the partial-reveal screenshot is a sharper teacher than any paragraph. The "what you didn't probe is still in the dark" idea reads instantly when the picture shows one ship cell with a triangle and a void where the rest of the hull should be. Don't write what a picture can show.

### Devpost / Devlog deliverables landed

- **Build #1636903** pushed to itch.io via butler. 99.20% patch savings; 566 KiB patch over 618 KiB fresh data. Replaces previous live build #1636747.
- **Devlog brief** at `docs/claude-cowork/devlog-i9.md` — title "What you didn't probe is still in the dark", ~240 words, three bold lede phrases, Gallows-Deadpan voice. Jason posts it manually from itch.io's Devlog editor.
- **Backlog cleanup:** removed 4 rows from `docs/backlog.md` — Probe activation outside grid (already shipped), No blind hit on partially probed ships (semantics flipped), Ship visibility around active probes is buggy (umbrella collapsed), Partial probe reveal on ships (long-term row, now shipped).

### Outstanding state at I9-3 close

- **Build:** complete. All checklist items checked.
- **Branch:** `main`, all I9 commits about to be pushed to `origin/main`.
- **Live game:** itch.io build #1636903 processing → live shortly.
- **Next steps for Jason:** post the devlog brief manually. Devpost edit window closes 2026-04-29 (4 days out).

## /iterate — Iteration 10 (opening)

Started 2026-04-25, same session as I9. Devpost edit window closes 2026-04-29 (4 days out).

### Entry state
- All checklist items 1–12 + I1 through I9 complete (52 iteration items shipped).
- Working tree: clean. Last commit `991039d` shipped I9-3.
- Live build on itch.io: #1636903 (partial-reveal probe).
- Backlog after I9 cleanup: 22 rows in "Ideas Surfaced During Development" + 5 long-term/exploratory rows.

### What Jason chose and why
Bundled three backlog items into one iteration: #4 (ambient music drop-in), #6 (always-visible split left panel), #7 (Ship Panel as accordion ship list). #6 + #7 stack — the split layout creates the room for the accordion, and the accordion is the natural replacement for the single-ship dense view that currently fills the Ship Panel side. #4 is a drop-in alongside.

### What the review pass surfaced
1. **Half the "Ideas Surfaced" rows had already shipped.** The backlog had drifted — 13 rows still listed I5/I6 work that landed in those iterations (battle log polish, scroll/zoom rework, persist map view, click-to-pick-up, stay on Target Grid, extended victory stats, plus the I3-2 wreckage z-order fix). Pruned in this scoping pass before picking the iteration. New surface area: 9 open rows in "Ideas Surfaced."
2. **Audio is 6/7 done, not 0/7.** SFX (click, probe, laser, missile, hit, explosion) all exist in `assets/audio/sfx/`. Only `assets/audio/music/ambient_space.ogg` is missing. Reframed the backlog row to scope just the music file.
3. **Tabbed left panel is structurally simple to collapse.** `gameplay.tscn:65-89` has a TabButtons strip + two sibling panels (BattleLogPanel + ShipPanelContainer). `_show_left_tab` toggles visibility. Removing tabs and stacking with `size_flags_stretch_ratio` 2 / 1 is straightforward. Touchpoints: scene file, `gameplay.gd::_show_left_tab` (line 68 + 4 sites in `screenshot_runner.gd`), and the dense single-ship `ship_panel.gd` rebuild for the accordion.

### Scoping decisions
- **#4 collapsed-row content: option (a) — name only.** Jason picked. Option (c) — armor/shield bar — added to backlog as a future polish row. Locks the visual budget tight enough that 5 rows + Battle Log fit in the left panel without a scrollbar.
- **Default expanded state: all collapsed on scene load and on each turn start.** No assumed "first ship" focus — player picks. Reasonable assumption locked in autonomously, course-correct in /build if the empty initial state reads wrong.
- **Destroyed ships: stay in the list, dim the row, can't expand.** Players already see wreckage on the Command Grid; keeping the row maintains spatial consistency. Destroyed-row click does nothing. Auto-locked.
- **Selection coupling (per backlog #7 text):** clicking a row name expands it AND selects the ship on the Command Grid AND switches the active grid to Command Grid if currently on Target Grid. Clicking a friendly ship on the Command Grid expands its row in the panel. One expanded at a time.
- **Enemy ship view (Target Grid clicks):** clicking an enemy ship on Target Grid replaces the accordion with the existing stripped enemy panel (per I8-10). Returning to Command Grid (or clicking a friendly ship) restores the accordion. Preserves today's behavior — no regression.
- **Split ratio: 2/3 ship panel, 1/3 battle log via `size_flags_stretch_ratio`. No draggable splitter.** Per backlog text. Simpler to ship; can revisit if needed.
- **Music sourcing: Jason picks the track.** Suggested sources: incompetech.com (Kevin MacLeod), freesound.org, pixabay.com/music. The build step copies the chosen file to `assets/audio/music/ambient_space.ogg`.
- **Bundle #6 + #7 in one item.** Splitting them creates an awkward intermediate state where the split layout exists but the Ship Panel is still a single-ship dense view that dominates 2/3 of the panel. Bundle keeps the iteration coherent and matches the I9 pattern.

### Build mode
Autonomous per top-of-file preferences. Verification falls naturally after I10-1 (the heaviest item — visual UX rework). I10-2 is a file drop-in. I10-3 is gated like I4-5 / I7-7 / I8-12 / I9-3 with three explicit pauses (smoke test, butler push, devlog draft).

### Backlog deltas during scoping
- Removed 13 already-shipped rows from "Ideas Surfaced": Click-to-pick-up (I5-5), Stay on Target Grid (I5-6), Hide empty opponent probes (I6-2), Hide enemy ship type (I6-2), Persist battle log across turns (I6-1), Extended victory statistics (I6-4), Hide opponent misses unless near miss (I6-2), Rework scroll + zoom (I5-1), Zoom centered on mouse (I5-1), Persist map view between turns (I5-2), Hide ship destruction on blind hits (I6-3), Show shield breakdown on probed hits (I6-3), Bug: destroyed ships z-order on Target Grid (I3-2 already covered both grids).
- Reframed the audio row to scope just the missing `ambient_space.ogg`.
- Added a new row: "Accordion row visual: armor/shield bar in collapsed state" (option (c) deferred per Jason's call).

## /build — Iteration 10 (paused after I10-1, resume on new machine)

Started 2026-04-26. I10-1 shipped + two mid-iteration polish commits. Pausing before I10-2 because Jason needs to source the ambient music file himself; resume by running `/build` on the new machine after `git pull` (commits below are pushed to `origin/main` — see "Push state" below).

> **2026-04-26 follow-up — I10-2 cancelled.** After resuming on the new machine, Jason decided not to ship music this round. Music wiring (toggle button, `AudioManager.play_music`/`stop_music`/`set_music_enabled`, `_music_player`, `MUSIC_PATH`, `GameState.music_enabled`) was ripped out the same day. The audio row went back to `docs/backlog.md` as `Audio: ambient music` with full restoration steps. Checklist I10-2 marked `[~] CANCELLED 2026-04-26`. The next live item is **I10-3** (the gated three-pause redeploy). Cancellation commit follows the polish commits.

### Read this first when resuming

I10-1 is fully checked. I10-2 has been **cancelled** (see follow-up note above). Skip it and proceed directly to **I10-3 (gated three-pause redeploy — smoke test, butler push, devlog draft)**. Note that the smoke test and devlog no longer mention music; the backlog cleanup in I10-3 now removes only two rows (the audio row stays, reframed).

### Commits landed during the session

In order:
- `559549d` Complete step I10-1: Always-visible split left panel + accordion ship list
- `58750cc` Refine I10-1: divider under expanded row + Battle Log header (Jason's polish ask after I10-1 — bottom of expanded accordion row sat flush against the next collapsed header; Battle Log section had no visual marker)
- `48a48c8` Refine I10-1: pan Command Grid to selected ship from side menu (Jason's polish ask — clicking an accordion header now centers the Command Grid camera on the ship's middle cell, since side-menu selection often needs scrolling)

### What landed in I10-1 + the polish

- **`scenes/gameplay.tscn`** — TabButtons strip deleted. LeftPanel is now a permanent VBox: ShipPanelContainer (stretch ratio 2) + HSeparator + "Battle Log" Label (teal) + BattleLogPanel (stretch ratio 1). The two scene-level tab `pressed` signal connections at the old line 193-194 are gone.
- **`scripts/ui/ship_panel.gd`** — full rewrite as a 5-row accordion. New API surface: `expand_row_for_ship(ship)` (headless, doesn't emit), `collapse_all()`, `show_enemy_ship(fog)` (hides accordion, shows stripped enemy panel), `hide_enemy_panel()`, `refresh_for_turn()` (rebuilds rows for the current player's fleet), `refresh_expanded()` (re-renders the open row's stats after a state change). Header click emits `ship_selected(ship)` / `ship_deselected()`. Destroyed ships dim, append `" (destroyed)"`, and clicks are no-ops. Each row's detail panel ends with a separator (the polish commit).
- **`scripts/gameplay.gd`** — `_show_left_tab` and 5 call sites removed. `_select_ship` now calls `expand_row_for_ship`; `_deselect_ship` calls `collapse_all` + `hide_enemy_panel`; `_try_select_enemy_ship` collapses the accordion before calling `show_enemy_ship`. New handlers `_on_panel_ship_selected` / `_on_panel_ship_deselected` mirror Command Grid selection from header clicks (auto-switching to Command Grid if needed). Both handlers are guarded against MOVE_PREVIEW state — clicks during a preview revert the accordion rather than yanking the move's selection. Post-action paths use `refresh_expanded()` so the open row's stats stay live. New helper `_center_command_camera_on_ship(ship)` (the polish commit) is called from `_on_panel_ship_selected` only — Command Grid clicks already see the ship.
- **`scripts/debug/screenshot_runner.gd`** — `_show_left_tab` calls deleted (lines 634, 817 in old file). `show_ship` calls swapped for `expand_row_for_ship`. Shot 12 crop slid from `(0, 40, 200, 540)` to `(0, 360, 200, 540)` so the always-visible battle log lands inside the frame. Shot 12 also calls `hide_enemy_panel()` + `collapse_all()` before capture (shot 10/11 leaves the enemy panel up).

### Environment gotcha

`godot --headless --path . -- --screenshot` HANGS at "starting" on this Windows install (godot 4.6.1, NVIDIA driver). Use `godot --path . -- --screenshot` (no `--headless`) per CLAUDE.md. Shows a window briefly but completes in ~30s and exits clean. All 18 shots regenerated for the I10-1 commit; spot-checked 05, 07, 08, 08a, 10, 12.

### Push state

Three commits sitting on local `main` ahead of `origin/main` at pause time. **Push them before clearing the session** so the new machine sees them on `git pull`:

```
git push origin main
```

(I'll prompt Jason to do this if he hasn't already.)

### Outstanding state at pause time

- **Checklist:** I10-1 checked. I10-2 cancelled (see follow-up note at top of section). I10-3 unchecked.
- **Working tree:** Clean (after the process-notes pause commit this section is part of, plus the I10-2 cancellation commit landed 2026-04-26).
- **Branch:** `main`. After cancellation commit, push before clearing.
- **Build mode:** Autonomous, verification at checkpoints every 3 items per checklist header. Do not switch modes.
- **Tasks:** session-local; will be empty on resume. Not load-bearing — the checklist is the source of truth.

### Backlog deltas during this session

- I10-2 cancellation: the `Audio: source and add ambient music file` row was reframed in `docs/backlog.md` as `Audio: ambient music`, capturing that the AudioManager music API and the GameState flag were both removed (so picking it back up is a multi-file restoration, not a file drop).
- I10-3 final cleanup: pruned `Always-visible split left panel: ship panel + battle log` and `Ship Panel as accordion ship list` from the Ideas Surfaced table. The reframed `Audio: ambient music` row stays.

### I10 build summary

Iteration scope: kill the tab strip on the gameplay screen left panel and replace the single-ship Ship Panel with a 5-row accordion. Music drop-in was scoped in but cancelled mid-iteration — see I10-2 cancellation note above. Final commit sequence:

- `559549d` Complete step I10-1: Always-visible split left panel + accordion ship list
- `58750cc` Refine I10-1: divider under expanded row + Battle Log header
- `48a48c8` Refine I10-1: pan Command Grid to selected ship from side menu
- `9401961` Document I10 pause state for resume on new machine
- `48a8de1` Cancel I10-2: rip out music wiring, defer ambient music to backlog
- (this commit) Complete step I10-3: Redeploy + devlog draft + backlog cleanup
- Build pushed: `#1639077` (previous live: `#1636903`). Patch 6.08 MiB, 91.24% savings, butler re-used 91.16% of old data.
- Devlog draft at `docs/claude-cowork/devlog-i10.md` — Gallows-Deadpan voice, three bold ledes ("The tab strip nobody loved", "Ship Panel is now your fleet, not just one hull", "Music waits for another day"). Jason said "ship it" so the draft went in verbatim.
- Backlog rows pruned in this iteration: 2 (down from the 3 originally planned because the audio row stays in reframed form).
- No screenshot regen required — the existing 18-shot set captures the new accordion via `expand_row_for_ship` calls that the runner already uses (was updated in the I10-1 commit).
- Smoke test (Gate 1) passed in the local browser at `http://localhost:8000/index.html`. Butler push (Gate 2) ran clean. Devlog draft (Gate 3) approved by "ship it".

Next iteration entry point: read `docs/checklist.md` for I11 scoping, or take a `/scope` pass on `docs/backlog.md` to pick the next bundle.

## /iterate — Iteration 11 (opening)

Started 2026-04-26 (same day as I10 ship). All I10 items checked, working tree clean, build live on itch.io as `#1639077`.

### Going-in state
- Original checklist + I1–I10 all complete.
- Backlog "Ideas Surfaced During Development" candidates available: direct hits vs partial hits, ship naming, ambient music (deferred from I10-2), cell info tooltip on Target Grid hover, nebula extends beyond grid bounds, hit/miss color unification across grids, accordion row armor/shield bar in collapsed state.
- Long-term/exploratory items (non-linear ship shapes, half-block cells, crit hits, fleet builder) deliberately out of scope for an iteration — they need their own design pass first.

### Scoping pass — what Jason picked

- **Future items (stay in backlog):** #11 Direct hits vs partial hits, #12 Ship naming, #14 Audio: ambient music.
- **Removed from backlog:** #13 Ship list in left panel — already shipped as the I10 accordion. Pruned from `docs/backlog.md` Ideas table.
- **Picked for I11:** #15 Cell info tooltip on Target Grid hover, #16 Nebula extends beyond grid bounds, #17 Hit/miss color unification (option (a) — Command palette red for fresh, gray for persistent, applied to hit + miss + near-miss on both grids), #18 Accordion row armor/shield bar in collapsed state, plus a NEW item from Jason: gray the ship name in the side bar once that ship has taken its action for the turn. The accordion-row bar (#18) and the gray-when-acted item are bundled into one checklist item (I11-2) since both touch `_build_row` / `_refresh_header`.
- **Added to backlog:** "Audio: improve SFX" (replace placeholder-grade SFX with higher-quality sources — file-replacement job since `AudioManager.play_sfx(name)` is the single integration point) and "Use graphics for the interface" (replace default Godot Controls with custom panel art / themed widgets to match the nebula aesthetic — touches ship_panel.gd, main_menu.gd, handoff.gd, victory.gd, plus a project-wide Theme).

### Review pass observations surfaced before checklist

- Tooltip data for #15 is half-built: `CellRecord` already has `hit_turn` and `miss_turn` from I7-3. The boolean `was_probed` needs to be paired with a new `last_probe_turn: int` so the tooltip can show probe-event timing.
- The "unify hit/miss colors" item had three valid interpretations. Confirmed with Jason: option (a) — push the Command palette's bright red (`Color(1.0, 0.15, 0.15, 1.0)`) over to Target Grid for fresh markers, use gray (`Color(0.6, 0.6, 0.6, 0.4)`) for older/persistent markers, applied uniformly to hit + miss + near-miss on both grids. The orange near-miss color drops out entirely.
- Gray-when-acted is essentially free — `_row_header_text` and `_refresh_header` already handle the destroyed case via `modulate`. Adding an `action_taken` branch is a one-line change in each, plus a new `refresh_all_headers()` method to keep non-expanded rows in sync after damage / shield regen.
- Collapsed-row armor/shield bar (#18) is the most actual-new-widget work in the bundle: today the row header is a plain Button; restructuring to HBox{ Button, mini bars } adds a Control hierarchy but isn't risky.
- Nebula extension (#16) is a single-touchpoint change in `_draw_background`. Going with option (a): a fixed padded dest rect (`NEBULA_PAD = 1280` on all sides) that's guaranteed to cover the SubViewport at any zoom level. Source rect stays as-is.

### Items written

5 items total — 4 work items (I11-1 color unify, I11-2 accordion header polish bundle, I11-3 nebula extension, I11-4 cell tooltip) + I11-5 gated redeploy + devlog. All single- or two-file changes, no data-model rework beyond the new `CellRecord.last_probe_turn` field.

## /build — Iteration 11

Started and shipped 2026-04-26 (same day as scoping pass and as I10 ship). Autonomous mode, verification at one mid-bundle checkpoint, plus the standard three-gate redeploy. All five items landed.

### Commits landed

- `5b5affc` Complete step I11-1: Unify hit / miss / near-miss colors across both grids
- `3235c53` Complete step I11-2: Accordion header polish — collapsed-row armor/shield bar + gray-when-acted
- `5a8249d` Complete step I11-3: Nebula background extends beyond grid bounds
- `048b7e4` Refine I11-3: drop unused NEBULA_SRC_RECT in grid_renderer (dead-code cleanup the I11-3 subagent flagged)
- `67f90a5` Tick I11-1 / I11-2 / I11-3 in checklist
- `9d15a0c` Refine I11-1: bump COLOR_MARKER_PERSISTENT alpha to 1.0 for readability (verification checkpoint feedback — Jason said the 0.4-alpha gray was too faint to see)
- `5dcc3f4` Refine I11-1: align COLOR_HISTORICAL_PROBE with persistent marker gray (Jason's follow-up — wanted the persistent gray and the "you've looked here" border to read as one system)
- `33e4b80` Complete step I11-4: Cell info tooltip on Target Grid hover
- `5ae33df` Tick I11-4 in checklist
- (this commit) Complete step I11-5: Redeploy + devlog draft + backlog cleanup
- Build pushed: `#1639229` (previous live: `#1639077`). Patch 215.15 KiB, 99.70% savings, butler re-used 99.62% of old data.

### What landed in I11

- **`scripts/ui/grid_renderer.gd`** — eight marker color constants collapsed to two (`COLOR_MARKER_FRESH = Color(1.0, 0.15, 0.15, 1.0)`, `COLOR_MARKER_PERSISTENT = Color(0.6, 0.6, 0.6, 1.0)`). Bright red for fresh markers, mid-gray for one-turn-old markers, applied uniformly across hits, misses, and near-misses on both grids. Orange near-miss color removed entirely. `COLOR_HISTORICAL_PROBE` retuned to match the persistent gray. `_draw_background` extended NEBULA_PAD = 1280 on every side so the nebula fills the SubViewport at any zoom-out / pan; switched to the full source texture (5333×3555) since the old 4:1 crop would over-stretch on the new 1.6:1 dest. Dead constant `NEBULA_SRC_RECT` dropped (the fleet placement scene still defines its own).
- **`scripts/ui/ship_panel.gd`** — accordion row header restructured from a plain Button into HBox{ Button, mini VBox{ shield ProgressBar, armor ProgressBar } }. Both bars `MOUSE_FILTER_IGNORE` so clicks pass through to the button. New `refresh_all_headers()` method iterates every row's header. New row-dict keys: `header_box`, `header_shield_bar`, `header_armor_bar`. `_refresh_header` extended to a third state — alive + `action_taken` modulates the whole header HBox to `Color(0.6, 0.6, 0.6)`, distinct from the destroyed gray `Color(0.5, 0.5, 0.5)`. Modulate cascades cleanly to bars and label in 4.6.2.
- **`scripts/gameplay.gd`** — `refresh_all_headers()` called in three places: line 102 (after `_setup_ship_panel()` in `_ready` so each turn starts with bars at correct values), line 528 (after the action-resolution `refresh_expanded()`), line 716 (after the move-action `refresh_expanded()`). New `_setup_hover_tooltip()` builds a `PanelContainer + Label` in `_ready`, parented to the gameplay scene root with `top_level = true`, `z_index = 100`, both nodes `MOUSE_FILTER_IGNORE`. `_process(_delta)` calls `_update_hover_tooltip()` — chosen over signal-driven because the tooltip needs to react to grid switches and to in-place `cell_records` updates, not only to mouse motion. Position offset 16px down-right from cursor with a flip to up-left if it would clip; final `clampf` to viewport size catches the small-viewport edge. Tooltip hidden on grid switch (`_switch_grid`) and on `target_viewport.mouse_exited`.
- **`scripts/gameplay/cell_record.gd`** — added `last_probe_turn: int` field. `make_probe(...)` signature gained a `turn_number: int` arg.
- **`scripts/gameplay/action_resolver.gd`** — passes `player_data["turns_played"] + 1` as the new arg at both probe-cell write sites (line 70, 87). Probe-overlap reset path gets the fresh turn number for free since each cell is overwritten by a new `CellRecord.make_probe(...)`.
- **`scripts/debug/screenshot_runner.gd`** — both `make_probe(...)` call sites updated to pass `1` as the placeholder turn number.
- **`docs/color-scheme.md`** — Grid/probe/combat markers section updated for the I11-1 palette unification: two new rows replacing the old four-constant entries; persistent-gray row notes the historical-probe border now shares the same color. Other line numbers in the doc are still drifted by ~3 from the `NEBULA_SRC_RECT` removal but were left as-is; not in scope for I11-5 and a future cleanup pass can re-run the line-number sweep.

### Verification checkpoint observation

Single mid-bundle checkpoint after I11-1 / I11-2 / I11-3. Jason flagged the persistent-marker gray as too faint to see at the original `Color(0.6, 0.6, 0.6, 0.4)`. Bumped alpha to 1.0 (`9d15a0c`). Follow-up ask: align `COLOR_HISTORICAL_PROBE` to the same gray for visual consistency between the "old hit/miss" layer and the "you've looked here" layer (`5dcc3f4`). Both refinements landed before continuing to I11-4. No regressions observed on other items.

### Backlog deltas

- Removed four rows from the Ideas Surfaced table, all implemented in I11: `Cell info tooltip on Target Grid hover`, `Nebula extends beyond grid bounds`, `Hit/miss markers: unify Command Grid coloring with Target Grid`, `Accordion row visual: armor/shield bar in collapsed state`.
- The I10 leftover row (`Audio: ambient music`) and the two rows added during I11 scoping (`Audio: improve SFX`, `Use graphics for the interface`) all stay — none implemented this iteration.

### I11 build summary

Iteration scope: a five-item visual-polish bundle pulled directly from the backlog Ideas Surfaced table plus one new ask from Jason ("gray ship name when action taken"). No data-model rework beyond a single new `CellRecord.last_probe_turn: int`. No new scenes. Final commit sequence above.

- Smoke test (Gate 1) passed in the local browser at `http://localhost:8000/index.html`. Jason verified the unified red/gray palette on both grids, the accordion bars + gray-when-acted, the extended nebula, and the cell tooltip.
- Butler push (Gate 2) ran clean — 99.62% re-use, 215.15 KiB patch.
- Devlog draft (Gate 3) at `docs/claude-cowork/devlog-i11.md` — Gallows-Deadpan voice, three bold ledes ("One palette, two grids, no orange.", "The accordion learned to keep score.", "The Target Grid finally remembers.") with the nebula extension folded into the body before the close.
- No screenshot regen required — the I11 changes don't alter any of the 18-shot capture points (same accordion structure, same grid layout, same UI). Could be regenerated later if a marketing pass wants the new bars / bright-red markers / tooltip on display.

Next iteration entry point: read `docs/checklist.md` for the next bundle, or take a `/scope` pass on `docs/backlog.md`.

## /iterate — Iteration 12 (opening)

Started 2026-04-26 (same day as I10 + I11 ship). All I1–I11 items checked, build live on itch.io as `#1639229`.

### Going-in state
- Original checklist + I1–I11 all complete.
- Backlog "Ideas Surfaced During Development" remaining candidates: direct hits vs partial hits, ship naming, ambient music (deferred from I10-2), Audio: improve SFX, Use graphics for the interface.
- Long-term/exploratory items (non-linear ship shapes, half-block cells, crit hits, fleet builder) deliberately out of scope for an iteration.

### Scoping pass — what Jason picked

- **Picked:** "Use graphics for the interface" (#15 in the renumbered backlog list given to Jason during scoping).
- **Art source confirmed:** Kenney UI Pack Space Expansion at `C:/Users/jcmcc/OneDrive/Coding/kenney_ui-pack-space-expansion/`. CC0 license, complete widget pack — Blue/Green/Grey/Red/Yellow color sets each with Default + Double scale variants, plus an Extra/Default neutral set with `panel_glass`, `panel_rectangle`, `panel_square` (with/without screws), `button_rectangle`/`button_square` + `_depth` pressed states, drop-shadow bar backgrounds, and `Kenney Future` + `Kenney Future Narrow` TTF fonts. No ship portrait art in the pack.
- **Per-ship portrait art:** explicitly **out of scope this iteration**. Bumped to a follow-up backlog row that I12-5 will add when it removes the parent "Use graphics" row.
- **Color direction:** Grey base + Blue accents. Grey for neutral chrome (panels, secondary buttons, labels). Blue for primary CTAs (Start Game / Done / Next / Play Again), slider fills, progress-bar fills, header strips. Reds + teals stay reserved for in-game state semantics (damage / shields). Pure-Blue and pure-Grey alternatives presented to Jason; he picked Grey + Blue.

### Review pass observations surfaced before checklist

- **No project-wide Theme exists today.** Every UI script does scattered `add_theme_*_override` calls (`scripts/ui/ship_panel.gd`, `scripts/ui/battle_log.gd`, `scripts/gameplay.gd`, `scripts/fleet_placement.gd`, plus the smaller scene scripts). Once a Theme resource exists at `Main.tscn`, the cascade paints all 7 scenes for free — the per-script work becomes a *cleanup* pass (remove redundancies the theme now handles), not a *paint* pass.
- **`assets/sprites/ships/`, `assets/sprites/ui/`, `assets/sprites/backgrounds/` are empty.** No prior art assets to reuse or migrate.
- **Some overrides must stay** even after the theme exists — they're state-driven, not stylistic: the `action_taken` / destroyed `header.modulate` calls (I11-2), the per-ship tinted buttons in fleet placement, the battle-log RichTextLabel color tags, the move-info red/green error/success colors, the enemy-ship name + stats panel colors, the accordion mini shield/armor bars (I11-2 — kept flat because Kenney bar art targets larger bars). The cleanup spec for I12-3 / I12-4 is explicit about what stays and what goes.
- **The grids inside the gameplay SubViewport (grid_renderer.gd) are unaffected** by the theme — they draw outside the Control hierarchy. Confirmed by reviewing `_draw_*` methods. Theme work doesn't touch combat / probe / fog-of-war rendering.

### Items written

5 items total — I12-1 (asset import + Theme resource, single artifact), I12-2 (wire to Main.tscn + verification checkpoint, layout-break catalog), I12-3 (override cleanup in lighter UI scripts + apply HeaderButton variation), I12-4 (override cleanup + re-skin in `ship_panel.gd` / `battle_log.gd` / `gameplay.gd` hover tooltip), I12-5 (gated redeploy + devlog + backlog row swap). Single concern per item; final item gated like I11-5.



## /build — Iteration 12

Started 2026-04-26 on branch `iter-12-kenney-ui` (Jason asked the build run to live on its own branch — first iteration to do so). Autonomous mode, verification at the standard 3-item checkpoint plus the I12-2-embedded cascade walkthrough plus the I12-5 three-gate.

### I12-2 cascade observations

Subagent flagged a planning bug before the walkthrough: `scripts/main.gd` calls `get_tree().change_scene_to_file(...)`, which **replaces** the entire root scene. Setting theme on `Main.tscn`'s root would never reach the swapped-in splash/menu/etc. scenes. Switched the wire-up to `project.godot[gui] theme/custom = "res://assets/themes/main_theme.tres"` — Godot's project-wide theme setting that applies regardless of scene-swap. Updated the I12-2 "What to build" + Acceptance to record the corrected mechanism. Reverted the unused `theme = ExtResource(...)` line on `Main.tscn`'s root (no point keeping dead config).

Walkthrough: Jason ran the game, walked splash → main menu → fleet placement (P1) → handoff → fleet placement (P2) → handoff → gameplay (one turn) → victory. Theme cascaded cleanly across every screen — Kenney Future Narrow on labels, grey Kenney Buttons on default Buttons, themed Panels, themed sliders + progress bars in the expanded ship panel. Grids inside SubViewport rendered identically (regression-clear).

Three live issues Jason flagged during the walk; fixed in-flight rather than cataloging for I12-3/I12-4 since each was a one-touch fix and would have been weird to leave broken across the standard mid-iteration checkpoint:

1. **White button text on the light Kenney grey button background was washed out.** Patched `assets/themes/main_theme.tres` Button colors: `font_color = Color(0.1, 0.13, 0.18)`, `font_hover_color = Color(0, 0, 0)`, `font_pressed_color = Color(0.05, 0.07, 0.1)`, `font_disabled_color = Color(0.4, 0.43, 0.48)`. HeaderButton (blue background) kept its near-white font colors — light text reads fine on blue.
2. **Gameplay scene needed padding around the LeftPanel and the top-right End Turn button.** `scenes/gameplay.tscn`: TopBar got `offset_left = 8 / offset_right = -8 / offset_top = 8 / offset_bottom = 56` (8px breathing room on left/right/top while keeping bar height at 48). MainLayout got `offset_left = 8 / offset_top = 64 / offset_right = -8 / offset_bottom = -8` plus `theme_override_constants/separation = 8` (8px around the LeftPanel + 8px gap to the GridArea).
3. **Destroyed-ship `(destroyed)` suffix made the row button too long.** Tried U+0336 combining strikethrough first — rendered, but forced a font fallback that broke the Kenney typography. Reverted to plain text + a 2px ColorRect overlay anchored over the measured text width inside the header Button. Strikethrough is invisible by default; `_refresh_header` toggles it on for `ship.is_destroyed`. Existing `header_box.modulate` dim cascades to the line.

No remaining layout-break catalog items.

## /build — Iteration 12

Started 2026-04-26 on branch `iter-12-kenney-ui` (Jason asked the build run to live on its own branch — first iteration to do so). Autonomous mode, verification at the I12-2 cascade walkthrough + the standard 3-item checkpoint after I12-3 + the I12-5 three-gate. Beep notifications fired at every breakpoint (I12-2 walk, Gate 1 smoke test, Gate 2 butler push, Gate 3 devlog draft).

### Commits landed (chronological)

- `9185a2a` Complete step I12-1: Import Kenney assets + Theme resource
- `604eb76` Tick I12-1 in checklist
- `2e7eac2` Complete step I12-2: Wire main_theme.tres to Main.tscn root
- `cbdd8b2` Refine I12-2: switch theme cascade from Main.tscn root to project.godot[gui] (change_scene_to_file replaces the root)
- `54d7f6a` Complete step I12-2: Theme cascade live + walkthrough fixes (dark Button text, gameplay padding, strikethrough overlay)
- `e070b6b` Complete step I12-3: Cleanup lighter UI scripts + HeaderButton on primary CTAs
- `49e1c5a` Tick I12-3 in checklist
- `f644dbc` Fix I12-3 regressions: set_theme_type_variation API + log shadow warning
- `5d5f012` Refine I12-2 theme: dark text on HeaderButton too (Kenney blue button is light-blue, not navy)
- `809cd1c` Refine I12-2: enlarge How to Play overlay (Kenney font wraps taller; page 6 was overrunning the nav buttons)
- `176a626` Complete step I12-4: Cleanup heavier UI scripts + reskin hover tooltip
- `8a78e17` Tick I12-4 in checklist
- (this commit) Complete step I12-5: Redeploy + devlog draft + backlog cleanup
- Build pushed: `#1639451` (previous live: `#1639229`). Patch 306.36 KiB, 99.57% savings, butler re-used 99.47% of old data.

### What landed in I12

- **27 Kenney source assets** imported into `assets/fonts/kenney/`, `assets/ui/kenney/blue/`, `assets/ui/kenney/grey/`, `assets/ui/kenney/extra/` plus 26 Godot-generated `.import` sidecars. CC0 license; pack `License.txt` copied into `assets/fonts/kenney/`.
- **`assets/themes/main_theme.tres`** — hand-authored 6,595-byte Theme resource with defaults for Button, PanelContainer, Panel, HSlider, ProgressBar, Label, RichTextLabel, plus a `HeaderButton` type variation. Final font_color values are dark on both Button and HeaderButton (Kenney's blue button skin turned out to be light-blue, not navy — light text was unreadable on both).
- **`project.godot[gui] theme/custom`** — wired the theme as Godot's project-wide theme. Original plan was `Main.tscn` root, but `scripts/main.gd` calls `change_scene_to_file` which replaces the root viewport — so a Main-root theme would never reach swapped-in scenes. Subagent caught it before the cascade walk; corrective edit landed in `cbdd8b2`. Updated I12-2 spec in `docs/checklist.md` to reflect the actual mechanism.
- **`scenes/gameplay.tscn`** — 8px padding around TopBar (so the End Turn button has air on the right) and 8px padding + 8px separation around MainLayout (so the LeftPanel has air on the left/top/bottom + an 8px gap to the GridArea).
- **`scenes/main_menu.tscn`** — How to Play overlay panel grew from 960×700 to 1080×820 and ContentArea from 920×540 to 1040×660. Kenney Future Narrow has taller line metrics than the default Godot font, so page 6 was overrunning the nav buttons at the original size. Still leaves comfortable margin on the 1600×900 screen.
- **`scripts/ui/ship_panel.gd`** — destroyed-state strikethrough rewritten as a 2px ColorRect overlay anchored over the measured text width inside the header Button, replacing the `(destroyed)` suffix that was widening the row. First attempt used U+0336 combining-stroke characters, which forced Godot's font system to fall back from Kenney Future Narrow on the destroyed names — reverted. Also: `FONT_SIZE_STATS_LABEL: int = 11` const introduced as the single source of truth for the dense stat panel font size (powers 7 call sites: enemy_stats, stats_label, shield/laser labels + values, energy_remaining). Header Button font_size override removed (matched theme default). Mini bars stay flat StyleBoxFlat with their teal/red tints — Kenney bar art targets larger widgets and would distort at 60×6.
- **`scripts/ui/battle_log.gd`** — two redundant 13pt overrides removed (theme carries them); 12pt divider overrides kept with a clarifying comment.
- **`scripts/gameplay.gd`** — hover tooltip's hand-rolled StyleBoxFlat replaced with `StyleBoxTexture` using `assets/ui/kenney/extra/panel_glass.png`, 8px margins, `modulate_color = Color(1.0, 1.0, 1.0, 0.92)` to preserve the translucency. The 11pt off-white tooltip Label override kept (tooltip-specific).
- **`scripts/main_menu.gd` / `handoff.gd` / `victory.gd`** — `set_theme_type_variation(&"HeaderButton")` applied to Start Game, How to Play, Next, and Play Again at runtime. (Subagent originally used the wrong API name `set_type_variation` — fatal error on the first launch; fixed in `f644dbc`.)
- **`scripts/autoloads/game_state.gd`** — `var log` renamed to `var entries` to clear the SHADOWED_GLOBAL_IDENTIFIER warning Jason flagged during the I12-3 launch (`log` shadows GDScript's math function).

### Verification observations

- I12-2 cascade walk: cataloged separately in the `### I12-2 cascade observations` block above. Theme cascaded cleanly across every screen; three live issues caught and fixed in-flight (white text on light buttons, gameplay padding, destroyed-suffix → strikethrough).
- I12-3 standard 3-item checkpoint: two regressions surfaced from the subagent's HeaderButton wire-up — the wrong API method name (fatal) and the pre-existing `log` shadow warning Jason chose to fix at the same time. Both patched. After the patch, Jason flagged white text on the now-blue HeaderButton CTAs, then the page-6 overflow on the How to Play overlay. Both patched. Cumulative checkpoint passed.
- I12-5 Gate 1 smoke test: passed in the local browser at `http://localhost:8000/index.html`. Jason verified Kenney font everywhere, dark text on grey AND blue buttons, glass-panel hover tooltip, themed slider + progress bars in the expanded ship panel, mini bars unchanged, battle log color tags unchanged, strikethrough on destroyed ships, grids unchanged.
- I12-5 Gate 2 butler push: ran clean — 99.47% re-use, 306.36 KiB patch. Build #1639451. Spot-check on the live secret URL passed.
- I12-5 Gate 3 devlog draft: Jason said "ship it" — draft went in verbatim. Title "The chrome stopped looking generic", three bold ledes ("The default Godot button has retired.", "Grey is for chrome, blue is for forward.", "The painted-by-numbers got cleaned up.") plus a closing paragraph on the hover tooltip glass-panel reskin and the build number.

### Backlog deltas

- Removed `Use graphics for the interface` row (the parent item I12 implemented).
- Added `Per-ship portrait art` row in its place — the Kenney pack carved out the ship art piece on the way in (it has widgets, no ship sprites). Notes touch `scripts/ui/ship_panel.gd` (own + enemy cards), `scripts/fleet_placement.gd` (detail panel), and sourcing options (Kenney's space-shooter packs, Ansimuz, custom commission).

### I12 build summary

Iteration scope: project-wide UI overhaul. Single Theme resource painting all seven scenes via `project.godot[gui] theme/custom`. Two color sets carrying the load (grey for neutral chrome, blue for primary CTAs); reds and teals stay reserved for in-game state semantics. Asset import + Theme resource was a single artifact (I12-1), wire-up was a one-line config change once the right mechanism was identified (I12-2), cleanup spread across two passes by code density (I12-3 lighter scripts + HeaderButton variation, I12-4 heavier scripts + hover tooltip reskin), and the gated three-pause redeploy closed it out (I12-5). Iteration ran on its own branch `iter-12-kenney-ui` — first time this workflow has used a branch; merged into `main` at the end.

Mid-iteration walkthrough fixes were heavier than usual (six refinement commits on top of the five item commits): the planning bug on `Main.tscn` cascade, the wrong-color-default loop on Button + HeaderButton text colors (twice), the gameplay scene padding gap, the page-6 overlay overflow, the destroyed-ship suffix → strikethrough overlay, the `set_type_variation` API name, the `log` shadow warning. Each was a one-touch fix Jason flagged during walkthroughs; net iteration size still in the same range as I10 / I11.

No screenshot regen this iteration — the existing 18-shot set captures the new theme through the same scene tree paths the runner already walks. Could be regenerated later if a marketing pass wants the Kenney chrome on display.

Next iteration entry point: read `docs/checklist.md` for the next bundle, or take a `/scope` pass on `docs/backlog.md`.

## /iterate — Iteration 13 (opening)

Started 2026-04-26 (same day as I10 / I11 / I12 ship). All I1–I12 items checked, working tree clean, build live on itch.io as `#1639451`.

### Going-in state
- Original checklist + I1–I12 all complete.
- Backlog "Ideas Surfaced During Development" remaining candidates: direct hits vs partial hits, ship naming, ambient music (deferred from I10-2), Audio: improve SFX, per-ship portrait art (added during I12-5 when "Use graphics for the interface" was retired).
- Long-term/exploratory items (non-linear ship shapes, half-block cells, crit hits, fleet builder) deliberately out of scope for an iteration.
- Most recent iteration (I12) was the Kenney UI Pack themed overhaul: project-wide Theme resource via `project.godot[gui] theme/custom`, grey + blue palette, glass-panel hover tooltip, HeaderButton variation on primary CTAs.

### Scoping pass — what Jason picked

- **Picked:** none. The "more graphics for the rest of the playing interface" thread was deferred to backlog as `Kenney UI chrome — playing interface phase 2` (added to `docs/backlog.md` Ideas Surfaced table, just below the `Per-ship portrait art` row).
- The backlog row captures the remaining un-themed surfaces from the I13 review pass — TopBar / LeftPanel panel chrome, accordion mini bar reskin (I12-4 punt), targeting reticule using Kenney crosshairs, header chips for sub-section labels (Battle Log, Actions, accordion row variants), and a glass strip behind the move-mode floating UI — plus the Kenney art categories we haven't used yet (crosshairs, header button blade/notch/large variants, notched/screwed panel variants, large bar art, cursor variants).
- I13 closed without a build run. No checklist items written, no commits, no redeploy. Working tree clean, build live as `#1639451`.


### Re-scoping pass — Jason swapped the iteration target

After deferring the chrome-phase-2 work above, Jason pivoted to two structural changes: resize the grid 80×20 → 50×30, and swap in a new Midjourney nebula image.

**Grid sizing rationale:** Anchored on the playable area math. Project viewport 1600×900, minus TopBar / LeftPanel / margins, leaves a GridArea of ~1376×828 (1.66:1 aspect). The current 80×20 grid at 32px is 2560×640 (4:1) — much wider than the playable area, which is why the game requires horizontal panning at zoom 1.0. Walked Jason through five candidate grids (43×26, 40×24, 50×30, 64×40, 86×52). He picked **50×30 at 32px** — 1500 cells (close to the original 1600 so tactical density is preserved), 1.67:1 aspect (matches the playable area), 32px cells (no marker / facing-triangle proportions need re-tuning).

**Nebula source:** Midjourney v7 with `--ar 16:9`, file at `/c/Users/jcmcc/Downloads/aufdemrand_httpss.mj.run9Cju85kDvz8_Star_nebula_--ar_169_--v_7_2c782e84-0479-4f5f-98e4-eaf35a2c4128.png`. 2912×1632 PNG, 5.7MB. Aspect is 16:9 (1.78:1) — slightly wider than the new 1.67:1 grid, so a small vertical stretch on draw is expected. Acceptable on an abstract nebula; build subagent can switch to `draw_texture_rect_region` cropping if it reads badly.

### Items written

4 items — I13-1 (grid resize: constants + scenes + default zoom + screenshot runner waypoints + doc prose), I13-2 (nebula swap: drop new asset + update preloads + retune NEBULA_PAD), I13-3 (screenshot regeneration after both upstream items land), I13-4 (gated redeploy + devlog + commit/push, mirrors I12-5).

### Scope expanded mid-pass

Jason added four constraints after the initial 4-item checklist landed:

1. **Nebula is a static background, not drawn inside the SubViewport.** Replaces the I3-1 / I11-3 architecture (where `_draw_background()` rendered the nebula in world space, scaling and panning with Camera2D). New approach: `TextureRect` behind the `SubViewportContainer`, anchored to the GridArea bounds, mouse-filter ignore, with the SubViewport set to `transparent_bg = true`. Drops `NEBULA_TEXTURE` and `NEBULA_PAD` from `grid_renderer.gd` and `fleet_placement.gd`.
2. **All grid changes apply to all three grids.** Fleet Placement Grid has been overlooked in past iterations (Jason flagged this directly). I13-1 and I13-2 spec verification steps for the placement grid explicitly.
3. **Default zoom shows all cells on every grid.** 50×30 grid at 32px = 1600×960. Default zoom = 0.86 (= 1376/1600) shows all cells in the gameplay GridArea (1376×828). Same default applied to fleet placement (which gets the same zoom even though its GridArea is slightly different — the I13-3 panel removal widens placement GridArea, so 0.86 stays valid).
4. **Fleet placement: remove right panel, fold ship details into left panel.** Currently right panel holds `ShipName` + `ShipStats` Labels. Move them to the left panel between the ship list and the placement hint. Update `@onready` paths in `fleet_placement.gd:25-26`. Update PRD section 2.2 to reflect new layout.

### Items revised

5 items now (was 4). I13-1 expanded to cover all three grids + zoom defaults explicitly. I13-2 rewritten as the static-TextureRect approach (was draw-in-world-space with retuned NEBULA_PAD). New I13-3 handles the fleet placement layout rework. I13-4 (was I13-3) is screenshot regen. I13-5 (was I13-4) is the gated redeploy. Final item gated like I12-5.
