# Devpost Submission — Battlestations: Nebula

Pasteable source for the Devpost submission form, organized by form page.

- **Page 1: Project overview** — name, pitch, images, links, story.
- **Page 2: Project details** — story (same), built with, try-it links, gallery, video.
- **Page 3: Additional info** — Learning Hackathon feedback form.

Fields you should personalize before pasting are tagged **[YOUR CALL]**.

---

# Project name

```
Battlestations: Nebula
```

# Elevator pitch

```
Hot-seat space combat tribute to my dad's 1980s Turbo Pascal game. Hide five ships in the nebula, fire probes to pull enemies out of fog, then shoot lasers and missiles before your intel goes stale.
```

198 characters, within Devpost's 200 limit.

# Tagline (itch.io reference — not a Devpost field)

```
Hunt blind. Probe twice. Fire once.
```

---

# Page 2 — Project details

## Project story

Paste the entire markdown block below into the Project Story field. Devpost's markdown editor supports H2, bullets, code spans, and bold — everything below renders correctly.

```markdown
## Inspiration

Forty-odd years ago, my dad wrote a hidden-fleet space combat game in Turbo Pascal on hardware that now props up somebody's garage table. Two players, one floppy disk, a green CRT, and enough quiet tension to remember decades after the floppy rotted. This hackathon gave me a reason to exhume it. Same bones, new century, new nebula.

## What it does

Battlestations: Nebula is a turn-based, hot-seat space combat game for two players sharing one browser. You each hide a fleet of five ships on an 80-by-20 grid, then take turns poking the dark with probes and firing lasers and missiles at coordinates you hope are still accurate.

- Five fixed ships per side: a Battleship, a Probe Ship, two Destroyers, and a Cruiser.
- One of four actions per ship per turn: Probe, Shoot Laser, Launch Missile, or Move.
- Energy allocation sliders per ship split your reactor between shield regen and laser power. Shields fill first when energy is tight.
- Probes illuminate a 4-by-4 box (6-by-6 from a Probe Ship) of the nebula and reveal any enemy ships inside. The lights go out after two of your turns. What stays is a ghost marker.
- Hidden-information integrity lives or dies on the handoff screen, which reports hit counts only. No ship names, no positions, no damage numbers.

## How I built it

One hundred percent spec-driven, start to finish. The workflow ran scope → PRD → spec → checklist → build → iterate, all captured in committed docs:

- `docs/scope.md` sets what's in, what's out, and why.
- `docs/prd.md` locks product behavior, screen flow, and combat math.
- `docs/spec.md` defines technical architecture, data models, and file layout.
- `docs/checklist.md` is twelve atomic build items, each referencing the spec section it implements, with explicit acceptance criteria. Two iterations layered on top for audio and submission polish.
- `process-notes.md` captured decisions, pushback, and trade-offs live through every phase.

Stack is Godot 4.6.2 with GDScript, statically typed throughout. HTML5 export runs in-browser via itch.io with no download. Each grid uses a SubViewport + Camera2D for native zoom and pan, and fog-of-war is a sparse Dictionary keyed on `Vector2i` to keep lookup O(1) across the 1,600-cell board.

## Challenges I ran into

- **Ghost-ship offset during fleet placement.** The placement scene's ghost ship tracked cursor motion wrong through four fix rounds. Root cause was hand-rolled container-to-viewport math that ignored Godot's internal SubViewportContainer transforms. The fix was replacing the math with `get_local_mouse_position()` on the renderer node. The engine already knew the answer. I was asking the wrong question.
- **Probe fade state machine.** Probe intel degrades over your subsequent turns and has to survive overlap, ship movement, and damage updates. Getting the sparse Dictionary to converge on correct state took three fixes: probe records not updating when a ship moved into or out of a probe, shield/armor values going stale after a hit, and overlap not resetting prior ghost markers cleanly.
- **Move cost counted rotation as displacement.** Rotating a ship shifted its origin cell, and the cost calculator treated that shift as movement. Fixed by anchoring cost to pivot points instead of origin.
- **Audio that sounds like space, not like a fan project.** First pass synthesized sounds with numpy. They sounded fake. Scrapped and pivoted to Kenney CC0 packs with ffmpeg fade-ins to smooth the onset. Better audio in an hour than numpy produced in four.

## Accomplishments I'm proud of

- The probe fade mechanic is load-bearing. Stale intel costs you. The ghost marker is worse than no intel because it feels like information.
- The nebula is a surface you read, not a backdrop you ignore. Probes illuminate the painted cloud instead of replacing it. Zoom out and the whole 80-by-20 battlefield reads like weather.
- Hidden-information integrity stayed honest end to end. You never see the opponent's grid. The handoff screen reports hit counts and nothing else.
- Every document in the project supports the next one. The PRD's combat math became the spec's `resolve_laser` became the checklist's item 9 became working code. No phase was busywork.

## What I learned

- **Front-loading specs is the payoff.** I came in with GitHub epic/story experience and thought I already specified work deeply. This process made the gap obvious. The spec's data model section survived untouched through the whole build because it got argued over before a line of code was written.
- **Voice locked early prevents rewrites later.** The Welcome tutorial page voice got approved before any marketing copy or itch.io description was drafted. Everything downstream cribbed from that anchor and stayed consistent.
- **The checklist is a living document, not a plan.** When items broke or surfaced gaps, the right move was to revise the checklist, not push through. Mid-iteration additions (the color scheme doc, the Cowork handoff brief) slotted in cleanly because the structure was built to adapt.

## What's next

`docs/backlog.md` holds the post-hackathon pile. Ranked roughly by impact: a randomize-fleet button for quick games, miss indicators on the Target Grid so you can see where you've already fired, instant-win on the killing shot, and a historical-probe overlay showing cells you've previously scanned. Bigger structural ideas (non-linear ship shapes, critical hit zones, partial probe reveal) each want their own design pass before any code lands.

## A note on the process

The plugin workflow was the best part of this hackathon for me. I'm going to keep using it to iterate on Battlestations: Nebula after submission. The backlog is long and the process makes planning each next pass easier than the last one. Thanks for running this.
```

## Built with

Add these one tag at a time. Devpost autocompletes known tags — pick exact matches when offered. If any tag is rejected as unknown, drop it and move on.

```
godot
gdscript
html5
webassembly
itch.io
butler
github
git
claude
python
ffmpeg
grammarly
```

Optional adds if you want to lean harder into the AI-workflow angle (fair for a Learning Hackathon on Spec Driven Development):

```
claude-cowork
hackathon-in-a-plugin
kenney-assets
spec-driven-development
```

Skip unless you want them: `numpy` (only in scrapped audio-synth tooling), `markdown` (everything uses it, low signal).

## "Try it out" links

Add both. Devpost labels them however you type them.

| Label | URL |
|---|---|
| Play the game | `https://zabuuq.itch.io/battlestations-nebula` |
| Source code | `https://github.com/zabuuq/Devpost-Hackathon` |

## Image gallery

**Devpost minimum is 5 images.** All listed files are well under Devpost's 2 MB per-image limit. Upload in this order — first image becomes the thumbnail.

From `assets/screenshots/`:

1. `11_probe_closeup.png` — **hero shot**, probe illumination. Thumbnail.
2. `04_fleet_placement_full.png` — fleet placement with all five ships placed.
3. `07_probe_revealed.png` — enemy ship revealed through an active probe.
4. `08_ship_panel_sliders.png` — ship panel with energy sliders.
5. `12_battle_log_detail.png` — battle log entries at three detail tiers.
6. `13_command_overview.png` — zoomed-out command grid overview.

Optional 7th–8th if Devpost lets you keep going:

7. `14_destroyed_ships.png` — wreckage markers after a kill.
8. `06_probe_aiming.png` — probe targeting reticule.

**Skip:** `09_move_preview.png` is only 2.8 KB on disk — probably a degenerate capture. Worth re-running `godot --path . -- --screenshot` before using it, or just leaving it out.

## Video demo link

**[YOUR CALL]** — none exists. Options:

- **Leave blank.** Devpost doesn't require video for this hackathon based on the form layout.
- **Record one.** A 60-second walkthrough (splash → placement → probe → fire → win) in OBS or Loom would strengthen the submission, but not a blocker.

---

# Page 3 — Additional info (Learning Hackathon feedback)

These are the hackathon organizers' feedback fields. Answers drafted from `process-notes.md`. **Edit anything that doesn't match your actual take** — these are my reconstruction, not your voice.

## Upload a file

**Skip.** The submission is web-hosted via itch.io. No standalone executable to attach.

## How far through the process did you get?

**[YOUR CALL]** — pick the fullest option in the dropdown. Likely something like "Complete build and iteration" or "Shipped a playable submission." You went all the way through scope → PRD → spec → checklist → build → iterate × 2 → submit.

## How many hours did the full experience take?

**[YOUR CALL]** — I don't have ground truth on this. Rough estimate from scope of work: 40–60 hours across about three weeks (early April through April 23).

```
Approximately 50 hours across three weeks, spread across planning, build, two iterations, and submission prep.
```

Edit the number to match your actual time.

## Upload your files to the storage software and share them here (eg. Google Drive)

```
https://github.com/zabuuq/Devpost-Hackathon
```

The full project source, docs, and process notes are all in the GitHub repo. No separate Drive upload needed.

## How would you rate the overall experience?

**[YOUR CALL]** — pick the rating in the dropdown that matches your honest take. Based on tone of the process notes, you sound positive. Don't inflate to please the organizers; they want a real signal.

## Which parts of the process were most valuable to you?

```
The spec phase did the heaviest lifting. Specifically the per-cell fog-of-war architecture discussion: I started with a per-probe-area model, the agent pushed back, and working through a concrete overlap scenario surfaced that a sparse Dictionary keyed on grid coordinates was the correct model. That one decision survived every build item that touched fog logic, with zero rework. The wrong choice would have cost compounding interest at move, probe, and hit time.

Voice-locking before writing marketing copy was the second highest-value move. The iterate round for submission readiness asked me to approve the first tutorial page's voice before anything else got drafted. Every downstream piece — README, itch.io description, Devpost story, in-game pages 2 through 9 — cribbed from that anchor. Zero rewrites for tone consistency.

Third: the deepening rounds at the end of each planning command. The prompt "want another round of questions before we generate the document?" made me sharpen things I would have shipped thin otherwise. Rotation pivot points, slider priority rules, probe overlap behavior — all surfaced during deepening rounds, none would have been in the first-pass doc.
```

## Where did you get stuck or what felt like a waste of time?

```
Biggest stuck point was a coordinate-math bug in fleet placement. My ghost ship tracked the cursor with an offset I could not isolate. I went through four rounds of fixes using progressively more elaborate manual transforms between SubViewportContainer, Viewport, and Camera2D spaces. The fix was one line using Godot's built-in get_local_mouse_position(). The engine already solved it. I was asking the wrong question for a day.

Second: audio synthesis from scratch. I spent an iteration running numpy-generated waveforms through ffmpeg. The results sounded fake in a way I could not talk myself out of. Pivoted to Kenney CC0 packs and had usable audio in under an hour. Retrospectively, curated assets first, custom synthesis post-hackathon.

Nothing in the SDD workflow itself felt like waste. The closest was the first few interview questions during /scope — the answers were things I already had ready, so it felt slow. The deepening rounds more than paid that back by surfacing decisions I had not actually made yet.
```

## Did this experience change how you approach building with a coding agent?

```
Yes. Before this, my process was epic-and-story in GitHub, with AI-assisted ticket breakdown and iterative code. Reasonably structured, but the specs were thin. This workflow made me write down decisions I would have resolved ad hoc during the build: combat damage formulas, slider priority rules, probe expiration, rotation pivots. Each one, written once, held across every downstream artifact.

Concrete change I am taking forward: front-load the spec pass. Old habit was to start ticketing after a one-paragraph scope. New habit is to finish a spec.md before opening the checklist.
```

## How likely are you to use this kind of workflow in your day to day work?

**[YOUR CALL]** — pick the likelihood that matches. Free-text follow-up below:

```
I am already planning to use the plugin for the post-submission iteration on this game — the backlog is long and the structure pays for itself across iterations. For day-job work, the scope/PRD/spec chain fits cleanly into the existing GitHub epic workflow: scope.md feeds an epic, PRD sections feed stories, spec.md feeds implementation tickets. The structure does not fight existing tooling, it sharpens it.
```

## Would you recommend this to a colleague?

**[YOUR CALL]** — check the box if yes.

## What would you change about this experience?

```
Two suggestions.

First: document the Cowork handoff pattern. I used Claude Cowork for itch.io browser automation in parallel with the build agent (theme update, description upload, screenshot gallery), which worked well, but the workflow was not part of the plugin. I invented the pattern on the fly — brief files under docs/claude-cowork/, explicit PAUSE comments in the checklist, and a delivered-note handoff from Cowork back to the build agent. That pattern could be a first-class template in the plugin for submissions that involve external dashboard work.

Second: guided-with-gates as a first-class build mode. Autonomous mode worked for most of the build, but the final submission item needed human gates before every external action (butler push, public flip, Devpost submit). I annotated the checklist manually with a HOLD marker and a guided-with-gates note, and the build agent respected it. That pattern could be supported by default for items that touch live services rather than requiring the learner to invent the scaffolding.

Otherwise, strong workflow. Plan is to keep using it.
```

---

# Final submit checklist

Before you click **Submit**:

- [ ] Page 1 done: name, pitch, thumbnail, links
- [ ] Page 2 done: story pasted and rendered correctly, built-with tags added, try-it links added, ≥5 screenshots uploaded in order, video left blank or recorded
- [ ] Page 3 done: all feedback fields filled, your personal rating and hours picked
- [ ] Preview opened in a new tab — markdown rendered clean, screenshots in right order, links open to the right URLs
- [ ] itch.io page is **public** (not draft)
- [ ] GitHub repo is **public** and pushed through `e3f071b`

When all green, submit.

After submit: paste the Devpost submission URL back in chat (pattern is usually `https://devpost.com/software/battlestations-nebula`). I'll do a Playwright read-only pass to verify the public page renders correctly, then close out Gate 7.
