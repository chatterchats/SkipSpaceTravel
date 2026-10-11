# Skip Space Travel

[GitHub repository](https://github.com/chatterchats/SkipSpaceTravel)

Development project for a UE4SS mod for **Star Wars: Zero Company** that skips
the repeated ship-travel cinematics before and after missions.

**Status:** working. Outbound/return round trips tested in-game from both the
undocked Den and Kafrene. Not yet published.

## Scope

- Outbound: leaving the Den, the hyperspace intro, and approaching the planet.
- Return: leaving the planet, the hyperspace intro, approaching the Den, and
  docking.
- Include the docked Kafrene and undocked Den variants.
- Preserve destination loading, mission results, rewards, and input restoration.
- Leave unrelated story scenes, conversations, and mission-specific cinematics alone.
- Actual loading time remains; the hyperspace loop plays until loading is done.

## Layout

- `src/Skip Space Travel/` — installable mod tree and mod-manager metadata.
- `src/Skip Space Travel/Scripts/` — runtime Lua source directory.
- `src/Skip Space Travel/MXM/` — optional MXM settings directory.
- `scripts/` — packaging, version synchronization, and Nexus changelog utilities.
- `docs/development.md` — how the runtime works and what to check in-game.
- `docs/nexus/` — explicitly marked draft listing text, not a published listing.
- `.github/workflows/package.yml` — manually triggered package/artifact workflow.
- `Zero_Company_UE4SS_Lua_Guide.md` — the shared UE4SS development reference.

## Development commands

Run from this directory:

```sh
python3 scripts/bump_version.py patch
python3 scripts/nexus_changelog.py 0.1.1
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

## Runtime and testing

The whole runtime is `Scripts/main.lua`. It matches exact LevelSequence object
paths and calls the choreography state's `NativeStop` (the in-game skip
callback). The hyperspace loop is left for the game to end once loading is
done. See
`docs/development.md` for details.

The optional Mixamoo Mod Config Manager switch defaults to enabled and applies
to subsequent scenes.

Install by extracting the ZIP's `Skip Space Travel/` folder into the game's
`SWZeroCompany/Binaries/Win64/ue4ss/Mods/` and restarting the game. UE4SS output
should then contain `[SkipSpaceTravel] v… loaded`. If it doesn't, check that the
path is `Mods/Skip Space Travel/Scripts/main.lua` and that `enabled.txt` exists.

## License

[MIT](LICENSE), copyright 2026 Chatter Chats.
