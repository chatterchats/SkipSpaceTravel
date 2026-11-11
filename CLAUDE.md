# SkipSpaceTravel

@docs/agent-rules.md

Read README.md first: what the mod skips, its layout and how it's tested.

## Rules for this repo

- Never skip or speed up docking (`Mission_to_HUB/HangarArrival`). The Den needs its ~9 s to
  finish loading; skipping it left the Den black after Unfinished Business (docs/development.md).
- Skip only exact LevelSequence paths in `SCENES`; anything unlisted must keep playing.
- Test a change on a mission round trip from both the undocked Den and Kafrene.
