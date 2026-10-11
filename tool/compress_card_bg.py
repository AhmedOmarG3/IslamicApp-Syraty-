"""Report / recompress the home-screen card background JPGs.

Usage:
    python tool/compress_card_bg.py          # report only
    python tool/compress_card_bg.py --apply  # rewrite in place
"""
import os
import sys

try:
    from PIL import Image
except ImportError:
    sys.exit("Pillow is not installed: python -m pip install Pillow")

IMAGES = [
    "evening_card_bg.jpg",
    "favorites_card_bg.jpg",
    "hisn_card_bg.jpg",
    "morning_card_bg.jpg",
    "quran_card_bg.jpg",
    "zakat_card_bg.jpg",
]

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "images")
# Cards are ~400x148 logical px and sit under a 0.88-0.94 alpha gradient overlay,
# so the photo is only faintly visible. 1200px covers a 3x-density phone width.
MAX_EDGE = 1200
QUALITY = 85

apply = "--apply" in sys.argv
total_before = 0
total_after = 0

for name in IMAGES:
    path = os.path.normpath(os.path.join(ROOT, name))
    if not os.path.exists(path):
        print(f"MISSING {name}")
        continue

    before = os.path.getsize(path)
    total_before += before

    with Image.open(path) as im:
        width, height = im.size
        im = im.convert("RGB")

        scale = min(1.0, MAX_EDGE / max(width, height))
        new_size = (max(1, round(width * scale)), max(1, round(height * scale)))
        if new_size != (width, height):
            im = im.resize(new_size, Image.LANCZOS)

        if apply:
            im.save(path, "JPEG", quality=QUALITY, optimize=True, progressive=True)
            after = os.path.getsize(path)
        else:
            tmp = path + ".tmp"
            im.save(tmp, "JPEG", quality=QUALITY, optimize=True, progressive=True)
            after = os.path.getsize(tmp)
            os.remove(tmp)

    total_after += after
    total_after += after
    print(
        f"{name:26} {width}x{height} -> {new_size[0]}x{new_size[1]}  "
        f"{before/1024:8.1f} KB -> {after/1024:8.1f} KB  "
        f"({100 * (1 - after / before):5.1f}% smaller)"
    )

print("-" * 78)
print(
    f"{'TOTAL':26} {total_before/1024/1024:.2f} MB -> {total_after/1024/1024:.2f} MB  "
    f"saved {(total_before - total_after)/1024/1024:.2f} MB"
)
if not apply:
    print("(dry run - nothing was written; re-run with --apply to rewrite the files)")
