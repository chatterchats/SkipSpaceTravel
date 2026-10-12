# Development notes

Everything lives in `src/Skip Space Travel/Scripts/main.lua`. `MXM.lua` is the
unmodified Mixamoo Mod Config Manager client; `MXM/settings.lua` declares the
single `enabled` switch.

## How it works

- `SCENES` lists the exact LevelSequence object paths to skip: leaving the Den
  or planet, the hyperspace intro, and approaching the planet or Den (with
  Den-undocked and Kafrene variants). Docking isn't skipped (below). Paths come from
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
- Every other choreographed sequence is logged as `PLAY | scene` and `END`,
  and listed scenes that play because the switch is off as
  `PLAY | switched off`. Logging doesn't depend on the switch, so a run with it
  off records what a skip would have cut.

## Why docking plays (2026-10-12)

1.0.0 skipped docking (`Mission_to_HUB/HangarArrival/*`). Returning from
MM_05_030 ("Unfinished Business", end of chapter 5) then left the Den black
behind the HUD; menus and the station map still worked, and a save and reload
recovered. The scene logging showed the game starts a story scene,
`StoryContent/CIN_5700_TheLift/CIN_5700_TheLift_A`, the moment docking ends.
Runs on Instance 2, each a return from that mission:

| Return scenes | Den |
| --- | --- |
| all played normally (switch off) | fine |
| all skipped (1.0.0) | black |
| docking played at 20×, others skipped | black |
| all four played at 20× (every event runs) | black |
| docking played normally, others at 20× | fine |

So it isn't anything docking's tracks do but the time it takes: the Den needs
roughly docking's 9 s after the hyperspace loop ends before that scene starts.
Approaching the Den (5.6 s) wasn't needed. How long is enough probably depends
on the machine, so docking isn't shortened at all.

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

## Tested in-game (0.2.0)

- Round trips from the undocked Den and Kafrene: every listed scene skipped;
  docking variants seen were `HangarArrival_C03_Nebula` and `HangarArrival_C030`.
- The MXM switch applies immediately both ways, including mid-mission.
- A failed mission ends on the restart/load screen, so there is no return trip.
- Extraction ends the mission as a win and uses the same return trip.
