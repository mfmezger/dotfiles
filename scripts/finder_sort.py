#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["ds-store"]
# ///
"""Keep Finder list-view sorting consistent: Downloads by Date Added, every other folder by Name.

Finder saves a sort order per folder (lsvp/lsvC records in the parent's .DS_Store) as soon as a
column header is clicked. Those overrides beat the global default from macos_defaults.sh. This
script finds them and, with --fix, resets them to Name through Finder itself (AppleScript), so no
.DS_Store file is written by hand.

Usage: scripts/finder_sort.py [--check | --fix]   (default: --check, exits 1 on drift)
"""

import plistlib
import subprocess
import sys
import time
from pathlib import Path

from ds_store import DSStore

HOME = Path.home()
DOWNLOADS = HOME / "Downloads"
# Hidden folders (.git, .venv, caches) are skipped too: rarely opened in Finder, slow to walk.
SKIP_DIRS = {"node_modules"}
# ~/Library is skipped as a whole, except the cloud drives (Google Drive, OneDrive, ...)
ROOTS = [HOME, HOME / "Library" / "CloudStorage"]

SET_NAME_SORT = """
on run argv
    tell application "Finder"
        set w to make new Finder window to (POSIX file (item 1 of argv) as alias)
        set current view of w to list view
        set opts to list view options of w
        set sort column of opts to column id name column of opts
        set sort direction of column id name column of opts to normal
        close w
    end tell
end run
"""


def ds_store_files():
    for root in ROOTS:
        if not root.is_dir():
            continue
        stack = [root]
        while stack:
            folder = stack.pop()
            try:
                entries = list(folder.iterdir())
            except OSError:
                continue
            for entry in entries:
                if entry.name == ".DS_Store":
                    yield entry
                elif entry.is_dir() and not entry.is_symlink():
                    if entry.name.startswith(".") or entry.name in SKIP_DIRS or entry == HOME / "Library":
                        continue
                    stack.append(entry)


def saved_sorts():
    """Yield (folder, sortColumn) for every folder with a saved list-view sort."""
    for ds_path in ds_store_files():
        try:
            with DSStore.open(str(ds_path), "r") as store:
                records = [(e.filename, e.code, e.value) for e in store if e.code in (b"lsvp", b"lsvC")]
        except Exception:
            continue
        sorts = {}
        for filename, code, value in records:
            try:
                plist = plistlib.loads(bytes(value)) if isinstance(value, (bytes, bytearray)) else value
            except Exception:
                continue
            # lsvC is the newer record and wins over lsvp when both exist
            if code == b"lsvC" or filename not in sorts:
                sorts[filename] = plist.get("sortColumn", "name")
        for filename, column in sorts.items():
            folder = ds_path.parent if filename == "." else ds_path.parent / filename
            yield folder, column


def drifted():
    """Return ({folder: column} sorted by something other than name, Downloads sort)."""
    wrong, downloads_sort = {}, None
    for folder, column in saved_sorts():
        if folder == DOWNLOADS:
            downloads_sort = column
        elif column != "name" and folder.is_dir():
            wrong[folder] = column
    return wrong, downloads_sort


def main():
    fix = "--fix" in sys.argv[1:]
    wrong, downloads_sort = drifted()
    if fix and wrong:
        for folder, column in wrong.items():
            subprocess.run(["osascript", "-", str(folder)], input=SET_NAME_SORT, text=True, check=False)
            print(f"FIXING {folder}: {column} -> name")
        # Finder flushes .DS_Store lazily; wait so the result below is real
        for _ in range(15):
            time.sleep(2)
            wrong, downloads_sort = drifted()
            if not wrong:
                break

    drift = len(wrong)
    for folder, column in wrong.items():
        print(f"DRIFT  {folder}: sorted by {column}, expected name")

    # Finder sorts Downloads by Date Added out of the box; AppleScript cannot set that column.
    if downloads_sort not in (None, "dateAdded"):
        drift += 1
        print(f"DRIFT  {DOWNLOADS}: sorted by {downloads_sort}, expected dateAdded")
        print("       Fix by hand: open Downloads, View > Sort By > Date Added")

    print(f"Finder sort drift: {drift}")
    return 1 if drift else 0


if __name__ == "__main__":
    sys.exit(main())
