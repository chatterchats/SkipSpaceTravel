#!/usr/bin/env python3
"""Package the source mod, refusing a missing runtime entry point."""

from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "src" / "Skip Space Travel"
PACKAGE_ROOT = "Skip Space Travel"


def main() -> None:
    modinfo = json.loads((SOURCE / "modinfo.json").read_text(encoding="utf-8"))
    manifest = json.loads((SOURCE / "zcom-mod.json").read_text(encoding="utf-8"))
    version = modinfo.get("version")
    if not isinstance(version, str) or not re.fullmatch(
        r"(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)", version
    ):
        raise SystemExit("modinfo.json must declare a semantic X.Y.Z version")
    if manifest.get("version") != version:
        raise SystemExit("Metadata versions do not match")

    entry_point = SOURCE / "Scripts" / "main.lua"
    if not entry_point.is_file():
        raise SystemExit("Cannot package: src/Skip Space Travel/Scripts/main.lua is missing.")
    declarations = re.findall(
        r'^local VERSION = "([^"]+)"$',
        entry_point.read_text(encoding="utf-8"),
        re.MULTILINE,
    )
    if declarations != [version]:
        raise SystemExit("main.lua VERSION must match package metadata")

    files = [SOURCE / name for name in (
        "enabled.txt", "modinfo.json", "zcom-mod.json", "README.md",
    )]
    files += sorted((SOURCE / "Scripts").glob("*.lua"))
    files.append(SOURCE / "MXM" / "settings.lua")  # not the player's values.lua
    entries = {
        f"{PACKAGE_ROOT}/{path.relative_to(SOURCE).as_posix()}": path
        for path in files
    }
    entries[f"{PACKAGE_ROOT}/LICENSE"] = ROOT / "LICENSE"
    for name, path in entries.items():
        if not path.is_file() or path.is_symlink():
            raise SystemExit(f"Missing or symlinked package file: {name}")

    output = ROOT / "dist" / f"Skip Space Travel V{version}.zip"
    output.parent.mkdir(exist_ok=True)
    if output.exists():
        with zipfile.ZipFile(output) as archive:
            same = set(archive.namelist()) == set(entries) and all(
                archive.read(name) == path.read_bytes()
                for name, path in entries.items()
            )
        if not same:
            raise SystemExit(f"{output.name} already differs; bump the version")
    else:
        with zipfile.ZipFile(output, "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for name, path in entries.items():
                archive.write(path, name)

    with zipfile.ZipFile(output) as archive:
        if archive.testzip() is not None or set(archive.namelist()) != set(entries):
            raise SystemExit("ZIP verification failed")
        for name, path in entries.items():
            if archive.read(name) != path.read_bytes():
                raise SystemExit(f"Packaged bytes differ: {name}")
    digest = hashlib.sha256(output.read_bytes()).hexdigest()
    output.with_suffix(".zip.sha256").write_text(
        f"{digest}  {output.name}\n", encoding="utf-8"
    )
    print(f"Verified {len(entries)} packaged files: {output}")
    print(f"SHA256: {digest}")


if __name__ == "__main__":
    main()
