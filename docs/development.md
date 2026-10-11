# Development notes

## Current state

Repository setup only. No runtime Lua entry point, installed mod, or gameplay
verification exists. Asset and reflection evidence identify candidate hooks;
they do not establish that any skip route is safe in the installed build.

## Exact content scope

The registry at `AI+/registry_assets.csv` in the parent workspace contains:

| Phase | Retained identifiers |
| --- | --- |
| Outbound departure | `EVT_HTM_DepartDenUndocked_L2R`, `EVT_HTM_DepartKafrene_L2R` |
| Outbound hyperspace | `EVT_HTM_HyperspaceInterior_Loop`, shared `CSM_HyperspaceLoop` |
| Outbound approach | `EVT_HTM_HyperspaceToPlanet_CurveLeft`, `EVT_HTM_HyperspaceToPlanet_L2R`, `EVT_HTM_HyperspaceToPlanet_L2R_Low` |
| Return departure | `EVT_MTH_DepartPlanet_L2R_Low`, `EVT_MTH_DepartPlanet_R2L`, `EVT_MTH_DepartPlanet_R2L_CurveFromRight` |
| Return hyperspace | Shared `CSM_HyperspaceLoop`, `EVT_MTH_Loop_Master_R2L` |
| Return approach | `EVT_MTH_HyperspaceToDenUndocked_R2L`, `EVT_MTH_HyperspaceToKafrene_R2L` |

Registry lines 32761–32867 group these under
`/Game/Game/Cinematics/Scenes/Shipping/GameEvents/Events/LevelTransitions/`.
Identifiers guide investigation; runtime instance identity must be established
before registering a targeted skip.

## Candidate controls and constraints

Evidence is in the parent workspace's `ZeroCompany_RE_Reference_v2/reference/`:

- `native_headers/current/BitReactorGame/Public/SeamlessLoadRequest.h`: a request
  has `bPreventTransitionCinematics` and separate departure, transition, and
  arrival payload references. The broad flag may affect more than the six
  repeated exterior scenes; do not enable it indiscriminately.
- `native_headers/current/BitReactorGame/Public/WorldOrchestrationSettings.h`:
  `bAutoSkipTransitionCinematicsWhenDestinationReady`. Captured defaults in
  `mappings/jmap/game_specific_cdo_values.jsonl` record this as false.
- `native_headers/current/BitReactorGame/Public/BRWorldOrchestrationSubsystem.h`:
  destination readiness, preload state, and seamless-load completion APIs.
- `native_headers/current/BitReactorGame/Public/BRG_CinematicSubsystem.h`:
  `ExecuteSkipCommand()` and `DoesActiveCinematicModeAllowSkipping()`.
- `types/all_lua_types/BP_Stage.lua`: stage-specific `Skip Stage` interface,
  payload identity, presentation completion, and cleanup declarations.
- `types/all_lua_types/L_WorldOrchestration_v2.lua`: separate loading, travel
  playback, arrival, and overlay-clearing states.

Prefer a targeted existing skip/completion path, leaving the game's loading and
state transitions in charge. Do not delete cinematics, force map loading, fake
destination readiness, broadcast completion prematurely, or skip all scenes
through a global cinematic hook. SDK declarations and generated Lua types are
not executable proof of the shipped implementation.

## Required runtime verification

A working implementation must exercise a complete outbound/return round trip:
all six repeated scenes skipped, actual destination loading completed, controls
restored, and mission results/rewards preserved. Include Kafrene/undocked Den
variants, multiple approach variants, successful missions, retreat/failure,
and consecutive missions. Verify that unrelated story, conversation, boarding,
and mission-specific arrival content remains unchanged. Check save/load and
mod disable/reload lifecycle behavior before claiming compatibility.

A source ZIP or metadata check does not establish any of those gameplay results.

## Repository tooling verification

Local smoke runs exercised the actual packaging and version commands:

- Packaging the current project refuses the absent runtime entry point and
  produces no archive.
- Disposable fixtures produce a single-root mod ZIP with the MIT license and
  matching checksum, excluding directory markers and logs.
- Repackaging identical source preserves the archive; changed source cannot
  overwrite a same-version archive.
- Version bumps synchronize metadata/changelog before runtime files exist,
  and synchronize main/MXM declarations once present. Mismatched declarations
  abort without changing metadata or the changelog.
- The Nexus changelog command produces category-prefixed plain-text entries.
- Workflow YAML parses locally. The GitHub workflow has not been executed.

The fixtures were removed. These checks prove repository tooling only, not
travel skipping or game compatibility.
