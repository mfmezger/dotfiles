#!/usr/bin/env python3
"""
Compare Brewfile with installed Homebrew packages
"""

import subprocess
import re
from pathlib import Path
from typing import Dict, List, Set, Tuple


def parse_brewfile(brewfile_path: Path) -> Tuple[Dict[str, str], Dict[str, str]]:
    """Parse Brewfile and return dictionaries for formulas and casks"""
    formulas = {}
    casks = {}

    with open(brewfile_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            match = re.match(r'brew\s+"([^"]+)"', line)
            if match:
                package = match.group(1)
                package_name = package.split("/")[-1]
                formulas[package_name] = line
                continue

            match = re.match(r'cask\s+"([^"]+)"', line)
            if match:
                casks[match.group(1)] = line

    return formulas, casks


def get_installed_packages() -> Tuple[Set[str], Set[str]]:
    """Get installed formulas and casks"""
    try:
        formulas = set(
            subprocess.check_output(
                ["brew", "list", "--formula"], text=True
            ).splitlines()
        )
        casks = set(
            subprocess.check_output(["brew", "list", "--cask"], text=True).splitlines()
        )
        return formulas, casks
    except subprocess.CalledProcessError:
        return set(), set()


def main():
    repo_root = Path.home() / "dotfiles"
    brewfile = repo_root / "Brewfile"
    brewfile_personal = repo_root / "Brewfile.personal"

    if not brewfile.exists():
        print(f"Error: Brewfile not found at {brewfile}")
        return 1

    formulas, casks = parse_brewfile(brewfile)

    if brewfile_personal.exists():
        personal_formulas, personal_casks = parse_brewfile(brewfile_personal)
        formulas.update(personal_formulas)
        casks.update(personal_casks)

    installed_formulas, installed_casks = get_installed_packages()

    known_aliases = {
        "kubectl": "kubernetes-cli",
    }

    resolved_formulas = {k: known_aliases.get(k, k) for k in formulas.keys()}
    missing_formulas = set(resolved_formulas.values()) - installed_formulas
    extra_formulas = installed_formulas - set(resolved_formulas.values())

    missing_casks = set(casks.keys()) - installed_casks
    extra_casks = installed_casks - set(casks.keys())

    print("FORMULAS")
    print("-" * 60)
    if missing_formulas:
        print("Missing (in Brewfile but not installed):")
        for f in sorted(missing_formulas):
            print(f"  ❌ {f}")
        print()

    if extra_formulas:
        print("Extra (installed but not in Brewfile):")
        for f in sorted(extra_formulas):
            print(f"  ➕ {f}")
        print()

    if not missing_formulas and not extra_formulas:
        print("✓ All formulas in sync")
        print()

    print("CASKS")
    print("-" * 60)
    if missing_casks:
        print("Missing (in Brewfile but not installed):")
        for c in sorted(missing_casks):
            print(f"  ❌ {c}")
        print()

    if extra_casks:
        print("Extra (installed but not in Brewfile):")
        for c in sorted(extra_casks):
            print(f"  ➕ {c}")
        print()

    if not missing_casks and not extra_casks:
        print("✓ All casks in sync")
        print()

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Formulas: {len(missing_formulas)} missing, {len(extra_formulas)} extra")
    print(f"Casks:    {len(missing_casks)} missing, {len(extra_casks)} extra")
    print("=" * 60)

    return 0


if __name__ == "__main__":
    exit(main())
