# Changelog

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
with [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Version 0.1.0 was the repository setup.

## [Unreleased]

## [0.2.0]

### Changed

- Rewrite the runtime as a single `Scripts/main.lua`; drop the hook registry,
  action groups, dedicated log file and hot-reload support. Diagnostics now go
  to UE4SS output only.
- Remove the mock-engine Lua test.
- Skip the hyperspace intro and leave the hyperspace loop for the game to end
  when loading finishes, instead of holding it for a destination-ready hook.
- Log unlisted travel scenes (`PLAY | not skipped` / `END`).

### Added

- Skip the Den docking scene after missions.
- Verified in-game: outbound/return round trips from the undocked Den and
  Kafrene.

## [0.1.1]

### Added

- Implement exact-identity travel skips for outbound/return departures and
  approaches, including Kafrene, undocked Den, and planet-camera variants.
- Complete hyperspace scenes only from the matching stage's destination-ready
  orchestration phase; leave streaming and mission/Den handoffs to the game.
- Add owned game-thread actions/hooks, state-end and reload cancellation,
  an MXM enable switch, and a dedicated `skip_space_travel.log`.
- Add Lua regression scenarios for unrelated content, loading/stage isolation,
  deferred assignment, disabling, state end, and reload.
- Enable source packaging with a real runtime entry point. No game build or
  six-scene round trip has been verified.

## [0.1.0]

### Added

- Establish the Skip Space Travel source layout, mod-manager metadata, MIT
  license, development notes, and draft Nexus listing text.
- Add source-only packaging, version synchronization, Nexus changelog conversion,
  and a manual GitHub package workflow.
- Keep release packaging blocked until a real runtime entry point exists;
  travel skipping is not implemented or game-tested.
