# Skip Space Travel

[![Nexus Mods](https://img.shields.io/badge/Nexus%20Mods-Skip%20Space%20Travel-d98f40)](https://www.nexusmods.com/starwarszerocompany/mods/335)
[![UE4SS](https://img.shields.io/badge/framework-UE4SS-6f42c1)](https://github.com/UE4SS-RE/RE-UE4SS)
[![License: MIT](https://img.shields.io/badge/license-MIT-2f7d4f)](LICENSE)

A UE4SS Lua mod for **Star Wars: Zero Company** that skips the ship-travel cutscenes before and
after every mission. Hyperspace lasts only as long as the game needs to load; story scenes and
everything else still play. Players should download the release ZIP from
[Nexus Mods](https://www.nexusmods.com/starwarszerocompany/mods/335) or the
[GitHub releases](https://github.com/chatterchats/SkipSpaceTravel/releases); the mod page text,
with install steps, is in [`docs/nexus/`](docs/nexus/).

| Trip | Skipped | Still plays |
| --- | --- | --- |
| Heading out | Leaving the Den, hyperspace intro, approaching the planet | Hyperspace loop, until the mission has loaded |
| Coming back | Leaving the planet, hyperspace intro, approaching the Den | Hyperspace loop, until the Den has loaded; docking at the Den |

Docking plays because the Den needs that time to finish loading: without it, the Den could stay
black after certain story missions (see [`docs/development.md`](docs/development.md)). One
setting, **Skip Space Travel**, on by default, through
[MXM Config Manager](https://www.nexusmods.com/starwarszerocompany/mods/149) when installed.

## Commands

`make help` lists everything. The usual loop: edit, `make test`, `make install`, restart the game.

| Target | Does |
| --- | --- |
| `make test` | the mocked-UE4SS test of `main.lua`, no game needed |
| `make install` / `make uninstall` | link `src/Skip Space Travel` into the main install, or remove the link |
| `make package` | `dist/SkipSpaceTravel-X.Y.Z.zip`, with `Skip Space Travel/` at its root |
| `make bump V=X.Y.Z` | set the version everywhere, date the changelog |
| `make release` | check, test, tag, push; CI publishes to GitHub and Nexus (mod 335) |
| `make check` / `make sync` | drift from the standard / fetch the latest shared files |

## Layout

The standard layout (see `../ModTemplate/STANDARD.md`). Specific to this repo:

- `src/Skip Space Travel/Scripts/main.lua` is the whole runtime. `Scripts/MXM.lua` is the
  unmodified MXM client; `MXM/settings.lua` declares the `enabled` switch.
- `tests/main_test.lua` loads `main.lua` with UE4SS and MXM stubbed out.
- `docs/nexus/media/` holds the Nexus banner and main image with their generation prompts.

## How it works

`main.lua` hooks the choreography state that plays cinematic sequences
(`SMstate_PlayChoreographedSequence_C`), matches the playing sequence against a list of exact
asset paths, and calls the state's `NativeStop`, the same callback the in-game skip button
reaches. The hyperspace loop isn't on the list: the game ends it once the destination is ready.
[`docs/development.md`](docs/development.md) has the details, why docking plays, and test notes.

## Testing in game

Restart the game after `make install` (UE4SS mod reload isn't supported). `UE4SS.log` lines
start with `[SkipSpaceTravel]`:

- `v… loaded | enabled`, then one `Hooked …` line per hook once the cinematic Blueprint loads;
- `SKIP | <scene> | <path>` for each skipped cutscene;
- `PLAY | not skipped | <path>` and `END` for other travel cutscenes (hyperspace loop, docking);
  a `PLAY` line for a cutscene that should be skipped means it's missing from the list;
- `PLAY | scene | <path>` for every other cutscene, and `PLAY | switched off | …` when the
  switch is off.

Fly a mission there and back from both the undocked Den and Kafrene.

## License

[MIT](LICENSE), copyright 2026 Chatter Chats.
