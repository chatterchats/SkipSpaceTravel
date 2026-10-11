# Development notes

Everything lives in `src/Skip Space Travel/Scripts/main.lua`. `MXM.lua` is the
unmodified Mixamoo Mod Config Manager client; `MXM/settings.lua` declares the
single `enabled` switch.

## How it works

- `SCENES` lists the exact LevelSequence object paths to skip: leaving the Den
  or planet, the hyperspace intro, approaching the planet or Den, and docking
  at the Den (with Den-undocked and Kafrene variants). Paths come from
  `AI+/registry_assets.csv` in the parent workspace. Anything not listed,
  including `_Lighting` tracks and boarding, is left alone.
- Hooks on `SMstate_PlayChoreographedSequence_C` (`Sequence Play`,
  `OnStateBegin`, `OnStateEnd`) see each sequence as it starts. The Blueprint
  class may load late, so hooks are installed when `NotifyOnNewObject` sees it.
- Listed scenes are skipped with `state:NativeStop()`, the same callback the
  in-game skip button reaches (per the retained Blueprint bytecode).
- The hyperspace loop (`EVT_MTH_Loop_Master_R2L`,
  `EVT_HTM_HyperspaceInterior_Loop`) is not skipped: it covers loading, and
  the game ends it on its own once the destination is ready (observed in-game).
- Any other sequence under `LevelTransitions/` is logged as
  `PLAY | not skipped` and `END`, so unknown travel scenes show up in the log.

## Alternative worth knowing about

`UWorldOrchestrationSettings.bAutoSkipTransitionCinematicsWhenDestinationReady`
(`Config=Game`, default false) is the game's own switch for this. It may skip
more transition scenes than the ones listed above; untested.

## Testing

Restart the game after installing (UE4SS mod reload is not supported). UE4SS
output should show `[SkipSpaceTravel] v… loaded` and one `Hooked` line per hook,
then `SKIP | <scene>` for each skipped scene. Things to check on a round trip:

- every travel scene logs `SKIP`, for both Den variants and several approach
  variants; check `PLAY | not skipped` lines for anything missed;
- hyperspace lasts only as long as loading;
- controls come back, mission results and rewards are intact;
- story scenes, conversations and boarding still play.
