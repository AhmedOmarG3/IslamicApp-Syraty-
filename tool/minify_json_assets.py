"""Minify whitespace from the bundled JSON assets (content is unchanged).

Usage:
    python tool/minify_json_assets.py          # report only
    python tool/minify_json_assets.py --apply  # rewrite in place

The JSON values are byte-for-byte identical after `json.loads`; only insignificant
whitespace between tokens is removed, so no Dart code needs to change.
"""
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "json")

apply = "--apply" in sys.argv
total_before = 0
total_after = 0

for name in sorted(os.listdir(ROOT)):
    if not name.endswith(".json"):
        continue

    path = os.path.join(ROOT, name)
    before = os.path.getsize(path)
    with open(path, "r", encoding="utf-8") as fh:
        raw = fh.read()

    try:
        data = json.loads(raw)
    except ValueError as exc:
        print(f"{name:22} SKIPPED (not valid JSON: {exc})")
        continue

    # ensure_ascii=False keeps the Arabic text readable; separators removes padding.
    minified = json.dumps(data, ensure_ascii=False, separators=(",", ":"))

    total_before += before
    if apply and len(minified.encode("utf-8")) < before:
        with open(path, "w", encoding="utf-8") as fh:
            fh.write(minified)
        after = os.path.getsize(path)
    else:
        after = len(minified.encode("utf-8"))
    total_after += after

    delta = before - after
    pct = 100 * delta / before if before else 0
    print(f"{name:22} {before/1024:9.1f} KB -> {after/1024:9.1f} KB  ({pct:5.1f}% smaller)")

print("-" * 62)
print(
    f"{'TOTAL':22} {total_before/1024/1024:9.2f} MB -> {total_after/1024/1024:9.2f} MB  "
    f"saved {(total_before - total_after)/1024/1024:.2f} MB"
)
if not apply:
    print("(dry run - nothing was written; re-run with --apply to rewrite the files)")
