# Devlog post brief — Iteration 6 (battle log overhaul + victory stats)

Post this as a new devlog on the itch.io page for **Battlestations: Nebula** (`zabuuq/battlestations-nebula`). Corresponds to build **#1635102**, pushed 2026-04-24.

## Where to post

itch.io dashboard → Battlestations: Nebula → **Edit game** → **More** → **Devlog** → **Create new post**.

Set visibility to public. Attach to the html5 release channel if itch offers that option; otherwise leave unlinked.

## Title

```
The log remembers. Carefully.
```

## Body (paste as-is)

The battle log used to forget. Every turn it cleared out, replayed the opponent's last turn, then sat there pretending the rest of the game hadn't happened. That was a choice. It was also wrong.

It remembers now. Per player, capped at 200 entries, newest first. Turn dividers cap each turn from above so scrolling down reads like walking back through the match.

Other changes:

**The enemy isn't giving you their name.** When the opponent takes a turn, their actions replay into your log tagged as Enemy. Ship type stays hidden. Empty probes don't show. Misses only show when they were adjacent to one of your ships, and then the log names which one, plural if you had two of the same type in range. "Enemy laser fired at (14, 6). Miss. Near miss to your Destroyers."

**The defender gets told what got hit.** You already know your own fleet. The log says so. When an enemy connects, you see which of your ships took the shot and whether it survived.

**Blind kills stay blind.** Fire without probe coverage, destroy something, and the log says Hit. No ship name. No destroy color. No explosion sound. You can guess. The game won't confirm.

**Shields down!** is a new line. Probed hit that drops shields to exactly zero, the log says so. Overflow into armor, it says how much.

The victory screen also gained four rows: laser shots, missile shots, total damage, total misses.

Live now. Build #1635102.

## Voice / formatting notes (for Cowork verification)

- Voice: Gallows Deadpan. Dry, second person, understated.
- No em dashes anywhere. Use en dashes, commas, or periods instead.
- No LLM clichés ("dive into", "delve", "it's worth noting", "in conclusion", etc.).
- ~265 words. Don't pad.
- Markdown bolds on the four lede phrases are intentional — keep them.
- Don't add a "what's next" section. The post ends on "Build #1635102."

## Context you may need

- Build **#1635102** on the `html5` channel, pushed via `butler push ./export/web zabuuq/battlestations-nebula:html5`. Replaces the prior live build **#1634061** (Iteration 4 viewport + bug sweep).
- Persistent battle log lives in `GameState.players[n].battle_log` (Array, capped at 200 including dividers), with helpers `append_battle_log` and `append_battle_log_divider` on `GameState`.
- Opponent-side filters live in `scripts/gameplay.gd::_filter_opponent_entry` (enemy-subject rewrite, empty-probe suppression, near-miss Chebyshev gate with per-instance ship collection for plural naming).
- Shooter-side polish lives in `scripts/ui/battle_log.gd::_format_fire` (hide destruction suffix + color on blind hits, "Shields down!" on probed shield-depletion) and `scripts/autoloads/audio_manager.gd::play_action_sfx` (explosion SFX gated on `has_probe`).
- Defender-side "Your X was hit/destroyed" text is in the owner==1 branch of `_format_fire`, using `target_ship_type` from the resolver result.
- Turn divider now pushes at turn END (in `turn_manager.gd::turn_end`) and after the opponent replay loop (in `gameplay.gd::_ready`), so dividers always sit above the actions they cap. Enemy divider fires whenever the opponent's `turns_played > 0`, with a "Nothing to report." fallback when no entries survive filtering.
- Victory-screen extension is a 2-column `GridContainer` per player in `scenes/victory.tscn` with six key/value rows. New counters live in `GameState.players[n].turn_stats` and increment inside `ActionResolver.resolve_laser` / `resolve_missile`.
- No changes to the itch.io Viewport dimensions field this round. That remains 1600 × 900 from Iteration 4.

## After posting

- Verify the post renders correctly (bolds, paragraph breaks, no stray em dashes).
- Grab the devlog URL and drop it back to Jason so it can be linked from Devpost if useful.
