-- main.lua against a mocked UE4SS: listed travel scenes are skipped, docking and other
-- scenes play, and the MXM switch turns skipping off. Run from the repo root (make test).
package.path = "src/Skip Space Travel/Scripts/?.lua;" .. package.path

local CHOREO = "/Game/Game/Cinematics/Blueprints/Stage/StateMachine/SMstate_PlayChoreographedSequence.SMstate_PlayChoreographedSequence_C"
local TRAVEL = "/Game/Game/Cinematics/Scenes/Shipping/GameEvents/Events/LevelTransitions/"

-- MXM config stub
local settings, on_change = {enabled = true}, nil
package.preload["MXM"] = function()
    return {
        Get = function(key, default)
            if settings[key] == nil then return default end
            return settings[key]
        end,
        OnChange = function(fn) on_change = fn end,
    }
end

-- UE4SS stubs
local queue, hooks, logs = {}, {}, {}
function print(text) logs[#logs + 1] = text end
function MakeActionHandle() return {} end
function ExecuteInGameThreadWithDelay(_, _, fn) queue[#queue + 1] = fn end
function StaticFindObject() return {IsValid = function() return true end} end
function RegisterHook(path, fn) hooks[path] = fn end
function NotifyOnNewObject() end

local function flush()
    while #queue > 0 do table.remove(queue, 1)() end
end

local function valid(t)
    t.IsValid = function() return true end
    return t
end

local count = 0
local function play(path)
    count = count + 1
    local state = valid({stopped = false})
    local player = valid({IsPlaying = function() return true end})
    state.LevelSequenceActor = valid({GetSequencePlayer = function() return player end})
    state.GetFullName = function() return "SMstate_PlayChoreographedSequence_C /Game/state_" .. count end
    state.IsActive = function() return true end
    state.GetPlayingLevelSequence = function()
        return valid({GetFullName = function() return "LevelSequence " .. path end})
    end
    state.NativeStop = function(self) self.stopped = true end
    hooks[CHOREO .. ":OnStateBegin"]({get = function() return state end})
    flush()
    return state
end

local function logged(pattern)
    for _, line in ipairs(logs) do
        if line:find(pattern, 1, true) then return true end
    end
    return false
end

local function scene(folder, name)
    return TRAVEL .. folder .. "/" .. name .. "." .. name
end

dofile("src/Skip Space Travel/Scripts/main.lua")
flush()
assert(hooks[CHOREO .. ":OnStateBegin"] and hooks[CHOREO .. ":Sequence Play"]
    and hooks[CHOREO .. ":OnStateEnd"], "all three hooks install")
assert(logged("v1.") and logged("loaded | enabled"), "load line")

local depart = scene("HUB_to_Mission/SPACETRAVEL/DepartHub", "EVT_HTM_DepartDenUndocked_L2R")
assert(play(depart).stopped, "leaving the Den is skipped")
assert(logged("SKIP | leave Den | " .. depart))

local approach = scene("Mission_to_HUB/ExitHyperspace", "EVT_MTH_HyperspaceToKafrene_R2L")
assert(play(approach).stopped, "approaching Kafrene is skipped")

local docking = scene("Mission_to_HUB/HangarArrival", "EVT_MTH_HangarArrival_C030")
assert(not play(docking).stopped, "docking plays: the Den needs that time to load")
assert(logged("PLAY | not skipped | " .. docking))

local story = "/Game/StoryContent/CIN_5700_TheLift/CIN_5700_TheLift_A.CIN_5700_TheLift_A"
assert(not play(story).stopped, "story scenes play")
assert(logged("PLAY | scene | " .. story))

settings.enabled = false
on_change()
assert(not play(depart).stopped, "switched off: nothing is skipped")
assert(logged("PLAY | switched off | leave Den"))

print = io.write
io.write("main_test: ok\n")
