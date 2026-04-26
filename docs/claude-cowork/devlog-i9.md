# What you didn't probe is still in the dark

**Probes got honest.** A probe used to be generous. Catch any cell of an enemy ship and the writer extrapolated the rest of the hull onto your Target Grid for free. Cute, but it never matched the mental model of a flashlight. A flashlight doesn't reveal what's around the corner. Now neither does the probe.

**Only the cells inside the box.** Drop a probe over the front half of a battleship and you see the front half. The back half stays nebula. Click any lit cell and the Ship Panel still tells you it's a battleship with full shields and full armor. The universe gives you the diagnosis even when you only saw the elbow. The rest of the hull is still your problem to figure out.

**Hits outside the probe box are blind, even on a partially revealed ship.** Lasers and missiles have always written intel onto the cell they hit, gated by whether that one cell was probed. Under the new contract, that gate lines up with the new reveal rule for free. Fire at a probed cell and you get the full readout. Fire at the un-probed extension of the same ship and the battle log shrugs back "Hit." like every other blind shot. Memory of the probe doesn't carry over.

The umbrella bug class around active-probe visibility (ships entering, leaving, or moving inside an active probe area producing inconsistent fog state) collapses with the writer change. Less code, fewer edge cases, sharper intel discipline. Build #1636903 is live.

---

*(Post manually from the itch.io Devlog editor.)*
