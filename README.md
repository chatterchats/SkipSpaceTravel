# Skip Space Travel

[GitHub repository](https://github.com/chatterchats/SkipSpaceTravel)

Development project for a UE4SS mod for **Star Wars: Zero Company** that skips
the repeated ship-travel cinematics before and after missions.

**Status:** repository setup only. Travel skipping is not implemented, no game
build has been tested, and no installable release has been published. There is
intentionally no `Scripts/main.lua` yet; packaging refuses an absent entry point.

## Intended scope

- Outbound: leaving the Den, hyperspace travel, and approaching the planet.
- Return: leaving the planet, hyperspace travel, and approaching the Den.
- Include the docked Kafrene and undocked Den variants.
- Preserve destination loading, mission results, rewards, and input restoration.
- Leave unrelated story scenes, conversations, and mission-specific cinematics alone.
- Actual loading time remains; the presentation may need a loading screen or fade.

## Layout

- `src/Skip Space Travel/` — mod-manager metadata and future installed mod files.
- `src/Skip Space Travel/Scripts/` — runtime Lua source directory.
- `src/Skip Space Travel/MXM/` — optional MXM settings directory.
- `scripts/` — packaging, version synchronization, and Nexus changelog utilities.
- `tests/` — future behavior tests; no runtime tests exist yet.
- `docs/development.md` — research evidence and runtime verification requirements.
- `docs/nexus/` — explicitly marked draft listing text, not a published listing.
- `.github/workflows/package.yml` — manually triggered package/artifact workflow.
- `Zero_Company_UE4SS_Lua_Guide.md` — the shared UE4SS development reference.

## Development commands

Run from this directory:

```sh
python3 scripts/bump_version.py patch
python3 scripts/nexus_changelog.py 0.1.0
python3 scripts/package.py
```

The version helper follows the other mods' `major`, `minor`, and `patch`
interface. It promotes non-empty `[Unreleased]` changelog notes and synchronizes
both metadata files, plus runtime and MXM version declarations when those files
exist. It does not create missing Lua files.

Packaging reads **source**, never a live game installation. A real
`Scripts/main.lua` declaring the matching `local VERSION` is required. The ZIP
contains one `Skip Space Travel/` directory, its MIT license, metadata, readme,
enablement marker, and Lua files. Directory markers and development files do
not ship. Output goes to `dist/` with a SHA-256 checksum.

The GitHub workflow packages only; it does not publish to Nexus. No Nexus mod
ID or tested-build claim has been invented.

## License

[MIT](LICENSE), copyright 2026 Chatter Chats.
