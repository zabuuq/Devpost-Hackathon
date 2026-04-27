# The chrome stopped looking generic

**The default Godot button has retired.** Every Button, Panel, slider, and progress bar in the game now wears the Kenney UI Pack Space Expansion — Kenney Future Narrow on the labels, grey button skins for the everyday chrome, blue button skins for the four primary CTAs (Start Game, How to Play, Next, Play Again). One Theme resource, wired at the project level, paints all seven scenes for free. The grids inside the SubViewport stayed exactly the same: ships, fog, probes, hit and miss markers all draw outside the Control hierarchy and never noticed the change.

**Grey is for chrome, blue is for forward.** Two colors carry the whole interface load. Grey for the things that just sit there — panels, secondary buttons, sliders, labels. Blue for the four CTAs that move you through the flow. Reds and teals stayed where they were: reserved for in-game state. Damage is still red. Shields are still teal. The accordion's mini shield/armor bars stayed as flat color rectangles — Kenney's bar art targets larger widgets and the 60×6 versions in the row headers wouldn't have survived the resize. Some things are too small to be themed.

**The painted-by-numbers got cleaned up.** Across the codebase there were scattered `add_theme_*_override` calls handling things the new Theme now handles. Most of them got deleted. The state-driven ones stayed: ship-type tints in fleet placement, action-taken modulate dim, battle-log color tags, error-red and success-green on the move info label. The destroyed-ship `(destroyed)` suffix that was making the accordion rows too long got replaced with a 2px ColorRect strikethrough drawn over the ship name — Unicode combining-stroke was tried first and forced an immediate font fallback that broke the Kenney typography. Some lessons arrive promptly.

The hover tooltip on the Target Grid swapped its hand-rolled flat dark stylebox for Kenney's `panel_glass.png` at 92% opacity. Build #1639451 is live.

---

*(Post manually from the itch.io Devlog editor.)*
