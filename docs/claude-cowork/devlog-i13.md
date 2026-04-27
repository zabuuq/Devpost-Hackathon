# The grid stopped being a letterbox

**The grid stopped being a letterbox.** The old 80×20 was a 4:1 strip you could only see about a third of at default zoom, which meant every match opened with a horizontal pan to confirm where your own fleet was hiding. The new 50×30 is 1.67:1, matching the playable area aspect at the same 32px cell size. 1500 cells, barely fewer than the old 1600, and every one of them is on screen at scene entry on every grid — fleet placement, Command, Target.

**The nebula stopped following the camera.** A fresh Midjourney render replaces the old AveCalvar JPG, and instead of being drawn inside the SubViewport (where it scaled and panned with the Camera2D, sometimes turning into a teal smear at full zoom-out) it now sits as a static TextureRect behind the grid. Zoom in, zoom out — the cloud doesn't budge. It runs at 45% modulate so the grid lines (now a soft blue-tinted near-white instead of deep indigo) and the ship rectangles still read on top.

**Fleet placement lost a panel.** The right-hand ship-detail card got folded into the left panel below the fleet list, and the grid took the freed width. Ship name and stats still update when you click a ship, but you stopped having to track three columns of UI to place five ships. The old right panel is not coming back. Don't write to it.

The 13 canonical screenshots got regenerated against the new dimensions. Build #1639531 is live.

---

*(Post manually from the itch.io Devlog editor.)*
