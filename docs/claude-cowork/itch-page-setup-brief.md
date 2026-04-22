# itch.io page setup brief for Claude Cowork

You're dressing the *Battlestations: Nebula* itch.io page. Three jobs: log into itch.io, apply a custom theme that matches the in-game nebula colors, and paste the long-form game Description from a file in the repo. This brief is the only context you have. Read it end to end before opening the browser. This is the second Cowork session for the project; the first was the screenshot capture pass documented in `docs/claude-cowork/screenshot-brief.md`. Same tone, same specificity, same expectations.

## 1. Access

- **Credentials:** Handled out of band. Jason logs into itch.io in the Cowork browser session before you start. Assume you arrive already signed in as user `zabuuq`. Don't prompt for a password, don't try to reset one, don't touch the login form.
- **Reach the edit page:**
  1. Open `https://itch.io/dashboard`.
  2. Find `Battlestations: Nebula` in the projects list.
  3. Click `Edit` on that row. The edit page loads with tabs across the top (`Edit game`, `Distribute`, `Metadata`, `Analytics`, etc.). You want the default `Edit game` tab.
- **Draft state:** The page is an unpublished draft and must stay a draft for this session. Don't touch the visibility toggle at the bottom of the edit page. Don't click `Publish`. Don't change `Draft` to `Public` or `Restricted`. If the visibility section is already set to `Draft`, leave it alone.
- **Secret verification URL (use this in Section 4):**

```
https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk
```

The public URL without the `?secret=...` query string returns 404 because the page is a draft. Don't strip the query string, don't share it, don't bookmark a clean version.

## 2. Theme update

The hex values below originate from `docs/color-scheme.md` (the project-wide palette reference). This section carries the itch.io-facing subset inline so you don't have to cross-reference. If anything ever looks off, treat `docs/color-scheme.md` as the source of truth.

Scroll down the `Edit game` page to the `Theme` section. itch.io gives you a simple preset picker by default. Click `Custom` to expose every color field. Set these exact hex values:

| Field | Hex | Source |
|---|---|---|
| Background color | `#0d0d26` | Main menu Background ColorRect (`scenes/main_menu.tscn:18`) and `COLOR_BG` in `scripts/ui/grid_renderer.gd:8`. Matches the in-game nebula backdrop. |
| Text color | `#9999cc` | Subtitle label `font_color` in `scenes/main_menu.tscn:43`. Soft blue-lavender, readable on the dark background. |
| Link color | `#66ccff` | Game title `font_color` in `scenes/main_menu.tscn:37`. Same bright cyan as the "NEBULA" title. |
| Link hover color | `#4db3ff` | `COLOR_PROBE_BORDER` in `scripts/ui/grid_renderer.gd:11`. Matches the probe halo ring in-game. |
| Button color | `#3366ff` | `SHIP_COLORS.battleship` in `scripts/ui/grid_renderer.gd:18`. The Battleship blue is the strongest fleet color and reads as a call-to-action. |
| Button text color | `#ffffff` | Pure white for contrast against `#3366ff`. |
| Button hover color | `#66ccff` | Same cyan as the title, shifts the button brighter on hover. |
| Border / embed frame | `#26264d` | `COLOR_GRID_LINE` in `scripts/ui/grid_renderer.gd:9`. Same indigo as the grid lines around the game canvas. |

Notes on the fields:
- itch.io's custom theme editor exposes `Background`, `Text`, `Link color`, `Button color`, and an `Embed` / border accent. Field labels sometimes vary by page version. Match by purpose, not by exact label; if a field doesn't exist in your editor, skip it and note the skip in your post-session report.
- **Font:** Leave the font selector alone. itch.io's default sans-serif is fine. Don't pick a decorative space font; the default keeps the Description legible.
- **Header image:** Do not upload a header image in this session. That's a separate task for a future iteration.
- **Save:** Scroll to the bottom of the edit page and click `Save`. itch.io's theme edits save with the full page, not a separate `Save Theme` button. If you see a standalone `Save theme` button near the Theme section, click it as well.

After saving, the edit page reloads or flashes a `Saved` toast. Confirm the save landed before moving on.

## 3. Description upload

The Description content lives at `docs/itch-io-description.md` in the repo. Open that file and read it end to end before pasting anything. Don't paraphrase, don't rewrite, don't rearrange sections. Paste what's there.

- **Where to paste:** The `Edit game` page has a `Description` section near the top with a rich-text / markdown editor. Click into it, clear anything already there, and paste the full content of `docs/itch-io-description.md`.
- **Markdown compatibility:** itch.io accepts a subset of markdown: headings (`#` through `###`), bold, italic, unordered lists, ordered lists, links, inline code, and images. The current description uses all of those. Every section will render.
- **Images in the description body:** `docs/itch-io-description.md` inlines four screenshot references:
  - `13_command_overview.png`
  - `11_probe_closeup.png`
  - `07_probe_revealed.png`
  - `09_move_preview.png`

  These files live in `assets/screenshots/` in the repo after the screenshot capture session. They're local paths, not URLs, so pasting the description as-is gives itch.io broken image references.
- **Image handling (the fragile part):** itch.io's gallery and inline body image uploads are separate. To land inline images, you need to:
  1. Scroll to the `Screenshots` section further down the edit page.
  2. Upload all eleven screenshots from `assets/screenshots/` (`01_welcome.png` through `11_probe_closeup.png`, plus `12_battle_log_detail.png` and `13_command_overview.png` if they exist). The Screenshots section accepts drag-and-drop or a file picker.
  3. After upload, itch.io generates a hosted URL for each image (something like `https://img.itch.zone/...`).
  4. Back in the Description, replace each inline `![](...)` reference with the itch.io-hosted URL for the matching filename.

  If step 4 is too fragile to automate reliably (the URL format varies, and itch.io doesn't expose the hosted URL directly in the editor), use the fallback: delete the four inline image lines from the pasted Description body entirely. The gallery screenshots from step 2 will still render at the top of the public page, so readers see the visuals without broken alt text in the body. Record the fallback in your post-session report so the build agent knows to wire inline images manually later.
- **Save the description:** Scroll to the bottom and click `Save`. Same `Save` button that saved the theme.

## 4. Save and verify

- **Final save:** Click `Save` at the bottom of the edit page one more time. Wait for the `Saved` toast or page reload.
- **Open the secret URL in a fresh tab:**

```
https://zabuuq.itch.io/battlestations-nebula?secret=B7MkfBht0kXO4Sw15lL0qIIGk
```

  Open it in a new tab, not by clicking `View page` on the edit screen (that sometimes strips the secret query string).
- **Theme check:** Confirm the page background is dark navy (`#0d0d26`), body text is the soft blue-lavender (`#9999cc`), the `Run game` button is battleship blue (`#3366ff`), and the frame around the game canvas is indigo (`#26264d`). If any color looks off, compare against the hex table in Section 2. Don't eyeball; open a color picker if the browser session has one.
- **Description check:** Confirm every section from `docs/itch-io-description.md` renders: the `Battlestations: Nebula` H1, the `A Pascal ghost, rebuilt for the browser` H2, the `How to play` ordered list, the `Features` bullet list, the `Controls` section, the `Credits` list, and the `Links` block at the bottom. Confirm ordered lists are numbered, bullets are bulleted, and bold text is bold.
- **Gallery check:** Scroll up to the top of the public page. The uploaded screenshots should render as a gallery either above or beside the game embed. Confirm at least `01_welcome.png`, `04_fleet_placement_full.png`, `05_command_grid.png`, `07_probe_revealed.png`, and `11_probe_closeup.png` are visible in the gallery.
- **Don't fix anything in-session.** If the theme, description, or gallery looks wrong, do not try a second pass in the same session. Write a short note listing what's broken (which section, which field, what you saw vs. what you expected) and close the session. The build agent will pick it up on the next iteration cycle.

When you're done, leave a one-line handoff in `docs/claude-cowork/itch-page-setup-delivered.txt` with the date, a pass/fail marker, and any notes on skipped fields or fallback decisions (especially the inline image fallback from Section 3). The build agent reads that file to know the Cowork session finished and what state the page is in.
