# Battlestations: Nebula

Battlestations: Nebula is a turn-based, hot-seat space combat game where two commanders hunt each other's hidden fleet across an 80 by 20 nebula grid. You fire probes to pull enemy ships out of the dark, then burn lasers and missiles into coordinates your intel swears are still accurate. It's a tribute to a hidden-fleet game Jason's father wrote in Pascal about 35 years ago, rebuilt in Godot 4.6.2 and exported to HTML5 so it runs in a browser.

## Play it live

Draft build on itch.io: https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk

The page is a draft through Iteration 2 of the hackathon build, so the secret URL is the way in.

## Setup and run

You need Godot 4.6.2. No backend, no API keys, no package manager steps.

1. Clone the repo.
2. Open `project.godot` in Godot 4.6.2.
3. Press F5 to run.

The game starts on the splash screen. Press any key to load the main menu. Two-player hot-seat, so grab a friend and one keyboard.

## Build for web

The project ships an HTML5 export preset called `Web` in `export_presets.cfg`. Threading is disabled so itch.io serves the build without SharedArrayBuffer headers.

From the Godot editor: `File` > `Export` > select `Web` > `Export Project` and point the output at `export/web/index.html`.

From the command line:

```bash
godot --headless --path . --export-release "Web" export/web/index.html
```

Push the build to itch.io with [Butler](https://itch.io/docs/butler/):

```bash
butler push ./export/web zabuuq/battlestations-nebula:html5
```

Replace the channel with your own `<user>/<game>:html5` if you fork the project.

## File structure

- `scripts/`: GDScript sources (autoloads, scene controllers, gameplay systems, UI).
- `scenes/`: Godot `.tscn` scene files for splash, main menu, fleet placement, handoff, gameplay, and victory.
- `assets/`: art, audio SFX, fonts, and screenshots.
- `docs/`: design documents, scoping notes, and the pitch source of truth.
- `tools/`: build and asset helper scripts.
- `export/`: HTML5 export output (generated, not checked in).

## Design docs

Everything in `docs/` is written as a working record, not marketing.

- `docs/scope.md`: feature rationale and what got cut.
- `docs/prd.md`: product requirements and screen flow.
- `docs/spec.md`: technical architecture, data models, and combat math.
- `docs/pitch.md`: elevator pitch, tribute story, and feature hooks (source of truth for the itch.io page and Devpost story).
- `docs/backlog.md`: post-hackathon ideas.

## Credits

- **Engine:** Godot 4.6.2, GDScript with static typing throughout.
- **Audio:** [Kenney](https://kenney.nl) CC0 packs. Sci-fi Sounds, Impact Sounds, and Interface Sounds.
- **Deploy:** HTML5 export pushed to itch.io via Butler.
- **Built for:** Devpost Learning Hackathon: Spec Driven Development.
- **Design tribute:** Jason's father's original Pascal hidden-fleet combat game, circa 1990. The bones are his. The nebula is new.

## License

No license file yet. Treat the code as all rights reserved until one lands at the repo root.
