# Less guesswork, more glanceability

**One palette, two grids, no orange.** Hit and miss markers used to live in two color schemes — desaturated red and gray on the Target Grid where you fired, bright red and orange on the Command Grid where you got fired on. Two systems, two reads, zero reason. Now there's one palette: bright red for the current turn, mid-gray for one turn old, applied to hits, misses, and near-misses on both grids. The orange is gone. The historical-probe border (the faint outline that says "you've already looked here") picked up the same gray, so the persistent layer reads as one quiet system instead of three colors competing.

**The accordion learned to keep score.** Every row of the Ship Panel now wears its shields and armor on its sleeve — two thin bars in the row header, teal over dim red, visible whether the row is collapsed or expanded. Take damage, the bars shrink. Regen, they grow. A ship that has already taken its action this turn dims to a uniform gray across its whole row — name, bars, the lot. At a glance you can see who's hurt and who's already moved without expanding anything.

**The Target Grid finally remembers.** Hover a cell that's been probed, hit, or missed and a small tooltip drops beside the cursor: "Probed turn 5 • Hit turn 7 • Missed turn 9." Cells with no history stay silent. The Command Grid stays silent. The renderer was always tracking turn numbers under the hood; the tooltip just gives them a place to live.

The nebula also used to stop at the edge of the playable grid — pan to a corner and you'd hit a flat black border. It now extends a generous margin in every direction, so zoom-out and corner-pans stay in space. Build #1639229 is live.

---

*(Post manually from the itch.io Devlog editor.)*
