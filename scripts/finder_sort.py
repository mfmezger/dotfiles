#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["ds-store"]
# ///
"""Keep Finder list-view sorting consistent: Downloads by Date Added, every other folder by Name.

Finder saves a sort order per folder (lsvp/lsvC/lsvP records in the parent's .DS_Store). Those
overrides beat the global default from macos_defaults.sh. This script finds them and, with --fix,
resets them to Name through Finder itself (AppleScript), so no .DS_Store file is written by hand.

Usage: scripts/finder_sort.py [--check | --fix]   (default: --check)
Exit status: 0 = clean, 1 = drift, 2 = incomplete scan.
"""

import plistlib
import stat
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
CLOUD_STORAGE = HOME / "Library" / "CloudStorage"
ROOTS = [HOME, CLOUD_STORAGE]
# Preserve lsvC > lsvp; use lsvP only as a fallback.
SORT_PRIORITY = {b"lsvP": 0, b"lsvp": 1, b"lsvC": 2}

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


def is_directory(path, errors, *, follow_symlinks=True):
    try:
        return stat.S_ISDIR(path.stat(follow_symlinks=follow_symlinks).st_mode)
    except (FileNotFoundError, NotADirectoryError):
        # Finder can retain records for deleted folders.
        return False
    except OSError as exc:
        errors.append(f"{path}: {exc}")
        return False


def ds_store_files(errors):
    for root in ROOTS:
        stack = [root]
        while stack:
            folder = stack.pop()
            try:
                entries = list(folder.iterdir())
            except OSError as exc:
                if not (folder == CLOUD_STORAGE and isinstance(exc, FileNotFoundError)):
                    errors.append(f"{folder}: {exc}")
                continue
            for entry in entries:
                if entry.name == ".DS_Store":
                    yield entry
                elif entry.name.startswith(".") or entry.name in SKIP_DIRS or entry == HOME / "Library":
                    continue
                elif is_directory(entry, errors, follow_symlinks=False):
                    stack.append(entry)


def saved_sorts(errors):
    """Yield (folder, sortColumn) for every folder with a saved list-view sort."""
    for ds_path in ds_store_files(errors):
        try:
            with DSStore.open(str(ds_path), "r") as store:
                records = [(e.filename, e.code, e.value) for e in store if e.code in SORT_PRIORITY]
        except Exception as exc:
            errors.append(f"{ds_path}: cannot read records: {exc}")
            continue
        sorts = {}
        for filename, code, value in records:
            try:
                plist = plistlib.loads(bytes(value)) if isinstance(value, (bytes, bytearray)) else value
                column = plist.get("sortColumn")
                if column is None:
                    continue
                if not isinstance(column, str):
                    raise ValueError("sortColumn must be a string")
            except Exception as exc:
                errors.append(f"{ds_path}: invalid {code.decode()} record for {filename}: {exc}")
                continue
            priority = SORT_PRIORITY[code]
            if filename not in sorts or priority > sorts[filename][0]:
                sorts[filename] = priority, column
        for filename, (_, column) in sorts.items():
            folder = ds_path.parent if filename == "." else ds_path.parent / filename
            yield folder, column


def drifted():
    """Return folders with drift, the Downloads sort, and any scan errors."""
    wrong, downloads_sort, errors = {}, None, []
    for folder, column in saved_sorts(errors):
        if folder == DOWNLOADS:
            downloads_sort = column
        elif column != "name" and is_directory(folder, errors):
            wrong[folder] = column
    return wrong, downloads_sort, errors


def main():
    fix = "--fix" in sys.argv[1:]
    wrong, downloads_sort, errors = drifted()
    if fix and wrong:
        for folder, column in wrong.items():
            subprocess.run(["osascript", "-", str(folder)], input=SET_NAME_SORT, text=True, check=False)
            print(f"FIXING {folder}: {column} -> name")
        # Finder flushes .DS_Store lazily; wait so the result below is real
        for _ in range(15):
            time.sleep(2)
            wrong, downloads_sort, errors = drifted()
            if not wrong and not errors:
                break

    drift = len(wrong)
    for folder, column in wrong.items():
        print(f"DRIFT  {folder}: sorted by {column}, expected name")

    # Finder sorts Downloads by Date Added out of the box; AppleScript cannot set that column.
    if downloads_sort not in (None, "dateAdded"):
        drift += 1
        print(f"DRIFT  {DOWNLOADS}: sorted by {downloads_sort}, expected dateAdded")
        print("       Fix by hand: open Downloads, View > Sort By > Date Added")

    if errors:
        for error in errors:
            print(f"WARNING {error}", file=sys.stderr)
        print(f"Finder sort scan incomplete ({len(errors)} errors); detected drift: {drift}", file=sys.stderr)
        return 2

    print(f"Finder sort drift: {drift}")
    return 1 if drift else 0


if __name__ == "__main__":
    sys.exit(main())
