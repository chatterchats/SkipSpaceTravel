# Skip Space Travel

[![Nexus Mods](https://img.shields.io/badge/Nexus%20Mods-Skip%20Space%20Travel-d98f40)](https://www.nexusmods.com/starwarszerocompany/mods/335)
[![UE4SS](https://img.shields.io/badge/framework-UE4SS-6f42c1)](https://github.com/UE4SS-RE/RE-UE4SS)
[![License: MIT](https://img.shields.io/badge/license-MIT-2f7d4f)](LICENSE)

Skip Space Travel is a UE4SS Lua mod for **Star Wars: Zero Company** that skips
the ship-travel cutscenes before and after every mission. Hyperspace lasts only
as long as the game needs to load; story scenes and everything else still play.

## What gets skipped

| Trip | Skipped | Still plays |
| --- | --- | --- |
| Heading out | Leaving the Den, hyperspace intro, approaching the planet | Hyperspace loop, until the mission has loaded |
| Coming back | Leaving the planet, hyperspace intro, approaching the Den | Hyperspace loop, until the Den has loaded; docking at the Den |

Both the undocked Den and Kafrene versions are covered. Docking plays because
the Den needs that time to finish loading: without it, the Den could stay black
after certain story missions. Failed missions end
on the restart/load screen with no trip home; extraction ends a mission as a
win and uses the normal trip home.

## Configuration

One setting, **Skip Space Travel**, on by default. With
[Mixamoo Mod Config Manager (MXM)](https://www.nexusmods.com/starwarszerocompany/mods/149)
installed, open **MOD SETTINGS** from the main menu or press `F2`. The switch
applies immediately, including mid-mission. Without MXM the mod is always on.

## Requirements

- **Star Wars: Zero Company**
- **UE4SS** for Zero Company, with the delayed game-thread action API
- Optional: [Mixamoo Mod Config Manager](https://www.nexusmods.com/starwarszerocompany/mods/149)
  for the on/off switch

| Game build | Status |
| --- | --- |
| 24874058 | Tested |

Later builds may work but are unverified until tested.

## Installation

Download the release ZIP from
[Nexus Mods](https://www.nexusmods.com/starwarszerocompany/mods/335), not GitHub's source-code archive (unless you package
`src/Skip Space Travel` yourself). The ZIP keeps `Skip Space Travel` as its
top-level folder and includes metadata for both mod managers below.

### With a mod manager

- **[Zero Mod Manager](https://github.com/stellamarislabs/zero-mod-manager)**
  (formerly ZCOM Mod Manager): open **Install**, drop in the ZIP, then
  confirm Skip Space Travel is enabled under **Mods**.
- **[Zero Company Mod Command](https://github.com/EnvianMods/ZeroCompanyModCommand)**:
  drag the ZIP into the **Hangar Bay** and check that it's enabled.

### By hand

1. Install UE4SS for Star Wars: Zero Company.
2. Extract the `Skip Space Travel` folder into
   `SWZeroCompany/Binaries/Win64/ue4ss/Mods/`.
3. Check that `ue4ss/Mods/Skip Space Travel/Scripts/main.lua` exists.
4. If your UE4SS setup ignores the packaged `enabled.txt`, add
   `Skip Space Travel : 1` to `ue4ss/Mods/mods.txt`.

### Updating and uninstalling

Close the game, then install the new ZIP the same way (by hand, copy it over
the old folder). To uninstall, disable or remove it in your mod manager, or
delete the `Skip Space Travel` folder.

## Troubleshooting

Everything goes to `UE4SS.log` with the `[SkipSpaceTravel]` prefix:

- `v1.0.0 loaded | enabled` at startup, then `Hooked …` lines once the
  cinematic Blueprint loads;
- `SKIP | <scene> | <path>` for each skipped cutscene;
- `PLAY | not skipped | <path>` and `END | <path>` for any other travel
  cutscene, such as the hyperspace loop and docking. A `PLAY` line for a
  cutscene you expected to be skipped means it's missing from the list;
- `PLAY | scene | <path>` and `END` for every other cutscene, such as story
  scenes, and `PLAY | switched off | …` for a travel cutscene that played
  because the switch is off. These show what played around a skip, so include
  them in reports.

### Reporting a bug

Open an [issue](https://github.com/chatterchats/SkipSpaceTravel/issues) with
your game build, UE4SS version, other installed mods, which cutscene still
played or what went wrong, and `UE4SS.log`.

## How it works

The whole runtime is
[`src/Skip Space Travel/Scripts/main.lua`](src/Skip%20Space%20Travel/Scripts/main.lua).
It hooks the choreography state that plays cinematic sequences, matches the
playing sequence against a list of exact asset paths, and calls the state's
`NativeStop`, the same callback the in-game skip button reaches. The
hyperspace loop isn't on the list: the game ends it on its own once the
destination is ready. Neither is docking (see the changelog). See [`docs/development.md`](docs/development.md) for
details and test notes.

## Repository layout

```text
.
├── .github/workflows/package.yml         # manual package build
├── .github/workflows/release-nexus.yml   # manual Nexus release
├── CHANGELOG.md
├── README.md
├── docs/
│   ├── development.md                    # how it works, test notes
│   └── nexus/                            # mod page description and summary
├── scripts/
│   ├── bump_version.py                   # version bump + changelog promotion
│   ├── nexus_changelog.py                # a release's notes as Nexus text
│   └── package.py                        # build the release ZIP into dist/
└── src/Skip Space Travel/                # the distributable mod folder
    ├── MXM/settings.lua                  # MXM settings page
    ├── Scripts/main.lua                  # the runtime
    ├── Scripts/MXM.lua                   # unmodified MXM client library
    ├── enabled.txt
    ├── modinfo.json                      # Zero Company Mod Command
    └── zcom-mod.json                     # Zero Mod Manager
```

## Development

1. Link or copy `src/Skip Space Travel` into the game's `ue4ss/Mods` folder.
2. Restart the game after changes (the mod doesn't support UE4SS hot reload),
   then fly a mission there and back and check `UE4SS.log`.

## Releasing

```sh
python3 scripts/bump_version.py patch   # or minor / major
python3 scripts/package.py
python3 scripts/nexus_changelog.py 1.0.0
```

`bump_version.py` promotes the `[Unreleased]` changelog notes and syncs the
version in `modinfo.json`, `zcom-mod.json`, `MXM/settings.lua` and
`Scripts/main.lua`. `package.py` builds `dist/Skip Space Travel V<version>.zip`
plus a SHA-256 checksum from source, and refuses to overwrite an existing
version with different contents. `nexus_changelog.py` prints a release's notes
as plain text for the Nexus changelog.

After the first upload, later releases can go through the **Release to Nexus
Mods** workflow (run it manually from the Actions tab). It checks that the
versions match, builds the ZIP with `package.py`, and replaces the single
active file on the Nexus page with the release notes as its changelog. It needs
a `NEXUSMODS_API_KEY` repository secret.

## License

[MIT](LICENSE), copyright 2026 Chatter Chats.
