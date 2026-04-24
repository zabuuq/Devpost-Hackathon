"""Sample dominant colors from assets/backgrounds/nebula.jpg for I3-6 palette work."""
from PIL import Image
import collections

img = Image.open("assets/backgrounds/nebula.jpg").convert("RGB")
print(f"Source size: {img.size}")

img_small = img.resize((200, 134))
w, h = img_small.size

regions = {
    "center_cloud":    (int(w*0.3),  int(h*0.3),  int(w*0.7),  int(h*0.7)),
    "center_core":     (int(w*0.4),  int(h*0.4),  int(w*0.6),  int(h*0.6)),
    "coral_rim_top":   (int(w*0.4),  int(h*0.15), int(w*0.85), int(h*0.45)),
    "coral_rim_left":  (int(w*0.15), int(h*0.3),  int(w*0.35), int(h*0.7)),
    "navy_edge_tl":    (0,           0,           int(w*0.2),  int(h*0.3)),
    "navy_edge_tr":    (int(w*0.8),  0,           w,           int(h*0.3)),
    "navy_edge_bl":    (0,           int(h*0.7),  int(w*0.2),  h),
    "warm_highlight":  (int(w*0.7),  int(h*0.6),  w,           h),
    "star_white":      (0,           int(h*0.5),  int(w*0.2),  int(h*0.7)),
    "mid_teal":        (int(w*0.25), int(h*0.45), int(w*0.45), int(h*0.6)),
    "mid_coral":       (int(w*0.55), int(h*0.2),  int(w*0.75), int(h*0.4)),
}

print("\n=== Regional averages ===")
for name, box in regions.items():
    crop = img_small.crop(box)
    pixels = list(crop.getdata())
    avg = tuple(sum(c) // len(pixels) for c in zip(*pixels))
    hexstr = f"#{avg[0]:02x}{avg[1]:02x}{avg[2]:02x}"
    print(f"  {name:18s} rgb{avg} {hexstr}")

print("\n=== Top 15 quantized palette ===")
quant = img.resize((400, 268)).quantize(colors=16)
palette = quant.getpalette()
counts = collections.Counter(quant.getdata())
for idx, count in counts.most_common(15):
    r, g, b = palette[idx*3:idx*3+3]
    pct = 100.0 * count / (400 * 268)
    hexstr = f"#{r:02x}{g:02x}{b:02x}"
    print(f"  {hexstr}  rgb({r:3d},{g:3d},{b:3d})  {pct:5.2f}%")

print("\n=== Brightest spots (star / highlight scan) ===")
# Find brightest pixels - stars and warm-highlight star
px = list(img_small.getdata())
brightest = sorted(enumerate(px), key=lambda t: -sum(t[1]))[:10]
for i, (r, g, b) in brightest:
    y, x = divmod(i, w)
    print(f"  ({x:3d},{y:3d}) rgb({r:3d},{g:3d},{b:3d}) #{r:02x}{g:02x}{b:02x}")
