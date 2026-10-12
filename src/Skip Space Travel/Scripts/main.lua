-- Skip Space Travel v1.0.1
-- Skips the repeated ship-travel cinematics: leaving the Den, the hyperspace
-- intro, and approaching the planet before a mission; leaving the planet, the
-- hyperspace intro, and approaching the Den after it. The hyperspace loop and
-- docking are left alone: the loop covers loading and the game ends it once the
-- destination is ready, and docking gives the Den time to finish loading. Every
-- other choreographed scene is logged, with the switch on or off, so a report
-- shows what played around a skip.
local VERSION = "1.0.1"
local Config = require("MXM")

local ROOT = "/Game/Game/Cinematics/Scenes/Shipping/GameEvents/Events/LevelTransitions/"
local CHOREO = "/Game/Game/Cinematics/Blueprints/Stage/StateMachine/SMstate_PlayChoreographedSequence.SMstate_PlayChoreographedSequence_C"

-- Exact LevelSequence object path -> scene. Anything not listed is left alone.
local SCENES = {}
local function add(scene, folder, names)
    for _, name in ipairs(names) do
        SCENES[ROOT .. folder .. "/" .. name .. "." .. name] = scene
    end
end
add("leave Den", "HUB_to_Mission/SPACETRAVEL/DepartHub", {
    "EVT_HTM_DepartDenUndocked_L2R", "EVT_HTM_DepartKafrene_L2R",
})
add("hyperspace intro", "HUB_to_Mission/SPACETRAVEL", {
    "EVT_HTM_InterstitialHyperspaceInterior_Settle",
})
add("hyperspace intro", "HUB_to_Mission/HyperspaceAndLoop", {
    "EVT_MTH_IntoTheLoop_Master_R2L", "EVT_MTH_LightspeedTunnelFull_R2L",
})
add("approach planet", "HUB_to_Mission/SPACETRAVEL", {
    "EVT_HTM_HyperspaceToPlanet_CurveLeft", "EVT_HTM_HyperspaceToPlanet_L2R",
    "EVT_HTM_HyperspaceToPlanet_L2R_Low",
})
add("leave planet", "Mission_to_HUB/DepartPlanet", {
    "EVT_MTH_DepartPlanet_L2R_Low", "EVT_MTH_DepartPlanet_R2L",
    "EVT_MTH_DepartPlanet_R2L_CurveFromRight",
})
add("approach Den", "Mission_to_HUB/ExitHyperspace", {
    "EVT_MTH_HyperspaceToDenUndocked_R2L", "EVT_MTH_HyperspaceToKafrene_R2L",
})
-- Docking (Mission_to_HUB/HangarArrival) isn't skipped. After Unfinished
-- Business the game starts a story scene (CIN_5700_TheLift_A) when docking
-- ends; skipping docking, or playing it at 20x, started that scene before the
-- Den had finished loading, and the Den stayed black behind the HUD. With
-- docking's 9 s played normally the Den was fine.

local enabled = Config.Get("enabled", true) == true
local pending = {} -- choreography state full name -> record

local function log(fmt, ...)
    print(string.format("[SkipSpaceTravel] " .. fmt .. "\n", ...))
end

local function safe(label, fn)
    return function(...)
        local ok, err = pcall(fn, ...)
        if not ok then log("ERROR | %s | %s", label, tostring(err)) end
    end
end

local function later(ms, label, fn)
    ExecuteInGameThreadWithDelay(MakeActionHandle(), ms, safe(label, fn))
end

local function valid(obj)
    if not obj then return false end
    local ok, result = pcall(function() return obj:IsValid() end)
    return ok and result == true
end

local function full_name(obj)
    return valid(obj) and obj:GetFullName() or nil
end

-- "LevelSequence /Game/A/B.B" -> "/Game/A/B.B"
local function object_path(obj)
    local name = full_name(obj)
    return name and name:match("^%S+%s+(.+)$")
end

local function skip(record)
    local state = record.state
    if record.skipped or not enabled or pending[record.key] ~= record
        or not valid(state) or not state:IsActive()
        or object_path(state:GetPlayingLevelSequence()) ~= record.path then return end
    local actor = state.LevelSequenceActor
    local player = valid(actor) and actor:GetSequencePlayer()
    if not valid(player) or not player:IsPlaying() then return end
    record.skipped = true
    log("SKIP | %s | %s", record.scene, record.path)
    -- Same callback the in-game skip button reaches; the game handles the rest.
    state:NativeStop()
end

-- The hooks can fire before the sequence is assigned, so check a few times.
local ATTEMPTS = {0, 100, 250, 500, 1000}

local function observe(state)
    local key = full_name(state)
    if not key then return end
    local record = {key = key, state = state}
    pending[key] = record -- replaces any earlier record, retiring its attempts
    for i, delay in ipairs(ATTEMPTS) do
        later(delay, "scene", function()
            if pending[key] ~= record or record.skipped or record.watched
                or not valid(state) then return end
            local path = object_path(state:GetPlayingLevelSequence())
            record.scene, record.path = path and SCENES[path], path
            if record.scene and enabled then
                skip(record)
            elseif path then
                -- Log start and end of everything else to see what plays.
                record.watched = true
                if record.scene then
                    log("PLAY | switched off | %s | %s", record.scene, path)
                elseif path:sub(1, #ROOT) == ROOT then
                    log("PLAY | not skipped | %s", path)
                else
                    log("PLAY | scene | %s", path)
                end
            elseif i == #ATTEMPTS then
                pending[key] = nil
            end
        end)
    end
end

local function ended(state)
    local key = full_name(state)
    local record = key and pending[key]
    if not record then return end
    if record.watched then log("END | %s", record.path) end
    pending[key] = nil
end

local HOOKS = {
    [CHOREO .. ":Sequence Play"] = function(ctx) observe(ctx:get()) end,
    [CHOREO .. ":OnStateBegin"] = function(ctx) observe(ctx:get()) end,
    [CHOREO .. ":OnStateEnd"] = function(ctx) ended(ctx:get()) end,
}
local installed = {}

local function install_hooks()
    for path, callback in pairs(HOOKS) do
        if not installed[path] and valid(StaticFindObject(path)) then
            RegisterHook(path, safe(path, callback))
            installed[path] = true
            log("Hooked %s", path)
        end
    end
end

-- The cinematic Blueprint may load after this script; hook it when it does.
NotifyOnNewObject("/Script/CoreUObject.Class", function(class)
    if object_path(class) == CHOREO then
        for _, delay in ipairs({0, 500, 2000}) do later(delay, "install hooks", install_hooks) end
    end
end)

Config.OnChange(function()
    enabled = Config.Get("enabled", true) == true
    log("%s", enabled and "Enabled" or "Disabled")
end)

log("v%s loaded | %s", VERSION, enabled and "enabled" or "disabled")
later(0, "install hooks", install_hooks)
