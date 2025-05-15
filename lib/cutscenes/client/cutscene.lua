-- Cutscene Manager for FiveM
-- Handles cutscene loading, playback, and character management

---@class Cutscene
Cutscenes = Cutscenes or {}
Cutscene = Cutscene or {}
Cutscene.done = true

-- Constants
local LOAD_TIMEOUT <const> = 10000
local FADE_DURATION <const> = 1000
local CUTSCENE_WAIT <const> = 1000

-- Character model definitions
local characterTags <const> = {
    { male = 'MP_1' },
    { male = 'MP_2' },
    { male = 'MP_3' },
    { male = 'MP_4' },
    { male = 'MP_Male_Character',   female = 'MP_Female_Character' },
    { male = 'MP_Male_Character_1', female = 'MP_Female_Character_1' },
    { male = 'MP_Male_Character_2', female = 'MP_Female_Character_2' },
    { male = 'MP_Male_Character_3', female = 'MP_Female_Character_3' },
    { male = 'MP_Male_Character_4', female = 'MP_Female_Character_4' },
    { male = 'MP_Plane_Passenger_1' },
    { male = 'MP_Plane_Passenger_2' },
    { male = 'MP_Plane_Passenger_3' },
    { male = 'MP_Plane_Passenger_4' },
    { male = 'MP_Plane_Passenger_5' },
    { male = 'MP_Plane_Passenger_6' },
    { male = 'MP_Plane_Passenger_7' },
    { male = 'MP_Plane_Passenger_8' },
    { male = 'MP_Plane_Passenger_9' },
}

-- Component definitions for character customization
local componentsToSave <const> = {
    -- Components
    { name = "head",        id = 0,  type = "drawable" },
    { name = "beard",       id = 1,  type = "drawable" },
    { name = "hair",        id = 2,  type = "drawable" },
    { name = "arms",        id = 3,  type = "drawable" },
    { name = "pants",       id = 4,  type = "drawable" },
    { name = "parachute",   id = 5,  type = "drawable" },
    { name = "feet",        id = 6,  type = "drawable" },
    { name = "accessories", id = 7,  type = "drawable" },
    { name = "undershirt",  id = 8,  type = "drawable" },
    { name = "vest",        id = 9,  type = "drawable" },
    { name = "decals",      id = 10, type = "drawable" },
    { name = "jacket",      id = 11, type = "drawable" },
    -- Props
    { name = "hat",         id = 0,  type = "prop" },
    { name = "glasses",     id = 1,  type = "prop" },
    { name = "ears",        id = 2,  type = "prop" },
    { name = "watch",       id = 3,  type = "prop" },
    { name = "bracelet",    id = 4,  type = "prop" },
    { name = "misc",        id = 5,  type = "prop" },
    { name = "left_wrist",  id = 6,  type = "prop" },
    { name = "right_wrist", id = 7,  type = "prop" },
    { name = "prop8",       id = 8,  type = "prop" },
    { name = "prop9",       id = 9,  type = "prop" },
}

-- Utility Functions

function table.shallow_copy(t)
    local t2 = {}
    for k, v in pairs(t) do
        t2[k] = v
    end
    return t2
end

local function WaitForModelLoad(modelHash)
    local timeout = GetGameTimer() + LOAD_TIMEOUT
    while not HasModelLoaded(modelHash) and GetGameTimer() < timeout do
        Wait(0)
    end
    return HasModelLoaded(modelHash)
end

local function CreatePedFromModel(modelName, coords)
    local model = GetHashKey(modelName)
    RequestModel(model)

    if not WaitForModelLoad(model) then
        print("Failed to load model: " .. modelName)
        return nil
    end

    local ped = CreatePed(0, model, coords.x, coords.y, coords.z, 0.0, true, false)
    if not DoesEntityExist(ped) then
        print("Failed to create ped from model: " .. modelName)
        return nil
    end

    return ped
end

-- Cutscene Core Functions
local function LoadCutscene(cutscene)
    assert(cutscene, "Cutscene.Load called without a cutscene name.")
    local playbackList = IsPedMale(PlayerPedId()) and 31 or 103
    RequestCutsceneWithPlaybackList(cutscene, playbackList, 8)

    local timeout = GetGameTimer() + LOAD_TIMEOUT
    while not HasCutsceneLoaded() and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasCutsceneLoaded() then
        print("Cutscene failed to load: ", cutscene)
        return false
    end

    return true
end

local function GetCutsceneTags(cutscene)
    if not LoadCutscene(cutscene) then return end

    StartCutscene(0)
    Wait(CUTSCENE_WAIT)

    local tags = {}
    for _, tag in pairs(characterTags) do
        if DoesCutsceneEntityExist(tag.male, 0) or DoesCutsceneEntityExist(tag.female, 0) then
            table.insert(tags, tag)
        end
    end

    StopCutsceneImmediately()
    Wait(CUTSCENE_WAIT * 2)
    return tags
end

-- Character Outfit Management
local function SavePedOutfit(ped)
    local outfitData = {}

    for _, component in ipairs(componentsToSave) do
        if component.type == "drawable" then
            outfitData[component.name] = {
                id = component.id,
                type = component.type,
                drawable = GetPedDrawableVariation(ped, component.id),
                texture = GetPedTextureVariation(ped, component.id),
                palette = GetPedPaletteVariation(ped, component.id),
            }
        elseif component.type == "prop" then
            outfitData[component.name] = {
                id = component.id,
                type = component.type,
                propIndex = GetPedPropIndex(ped, component.id),
                propTexture = GetPedPropTextureIndex(ped, component.id),
            }
        end
    end

    return outfitData
end

local function ApplyPedOutfit(ped, outfitData)
    if not outfitData or type(outfitData) ~= "table" then
        print("ApplyPedOutfit: Invalid outfitData provided.")
        return
    end

    for componentName, data in pairs(outfitData) do
        if data.type == "drawable" then
            SetPedComponentVariation(ped, data.id, data.drawable or 0, data.texture or 0, data.palette or 0)
        elseif data.type == "prop" then
            if data.propIndex == -1 or data.propIndex == nil then
                ClearPedProp(ped, data.id)
            else
                SetPedPropIndex(ped, data.id, data.propIndex, data.propTexture or 0, true)
            end
        end
    end
end

-- Public Interface
function Cutscene.GetTags(cutscene)
    return GetCutsceneTags(cutscene)
end

function Cutscene.Load(cutscene)
    return LoadCutscene(cutscene)
end

function Cutscene.SavePedOutfit(ped)
    return SavePedOutfit(ped)
end

function Cutscene.ApplyPedOutfit(ped, outfitData)
    return ApplyPedOutfit(ped, outfitData)
end

function Cutscene.Create(cutscene, coords, srcs)
    local lastCoords = coords or GetEntityCoords(PlayerPedId())
    DoScreenFadeOut(0)

    local tagsFromCutscene = GetCutsceneTags(cutscene)
    if not LoadCutscene(cutscene) then
        print("Cutscene.Create: Failed to load cutscene", cutscene)
        DoScreenFadeIn(0)
        return false
    end

    srcs = srcs or {}
    local clothes = {}
    local localped = PlayerPedId()

    -- Process players and create necessary peds
    local playersToProcess = { { ped = localped, identifier = "localplayer", coords = lastCoords } }

    for _, src_raw in ipairs(srcs) do
        if type(src_raw) == 'number' then
            if src_raw and not DoesEntityExist(src_raw) then
                local playerPed = GetPlayerPed(GetPlayerFromServerId(src_raw))
                if DoesEntityExist(playerPed) then
                    local ped = ClonePed(playerPed, false, false, true)
                    table.insert(playersToProcess, { ped = ped, identifier = "player" })
                end
            else
                table.insert(playersToProcess, { ped = src_raw, identifier = "user" })
            end
        elseif type(src_raw) == 'string' then
            local ped = CreatePedFromModel(src_raw, GetEntityCoords(localped))
            if ped then
                table.insert(playersToProcess, { ped = ped, identifier = 'script' })
            end
        end
    end

    -- Process available tags and assign to players
    local availableTags = table.shallow_copy(tagsFromCutscene or {})
    local usedTags = {}
    local cleanupTags = {}

    for _, playerData in ipairs(playersToProcess) do
        local currentPed = playerData.ped
        if not currentPed or not DoesEntityExist(currentPed) then goto continue end

        local tagTable = table.remove(availableTags, 1)
        if not tagTable then
            print("Cutscene.Create: No available tags for player", playerData.identifier)
            break
        end

        local isPedMale = IsPedMale(currentPed)
        local tag = isPedMale and tagTable.male or tagTable.female
        local unusedTag = not isPedMale and tagTable.male or tagTable.female -- needs to be this way as default has to be null for missing female

        SetCutsceneEntityStreamingFlags(tag, 0, 1)
        RegisterEntityForCutscene(currentPed, tag, 0, GetEntityModel(currentPed), 64)
        SetCutscenePedComponentVariationFromPed(tag, currentPed, 0)

        clothes[tag] = {
            clothing = SavePedOutfit(currentPed),
            ped = currentPed
        }

        table.insert(usedTags, tag)
        if unusedTag then table.insert(cleanupTags, unusedTag) end

        ::continue::
    end

    -- Clean up unused tags
    for _, tag in ipairs(cleanupTags) do
        local ped = RegisterEntityForCutscene(0, tag, 3, 0, 64)
        if ped then
            SetEntityVisible(ped, false, false)
        end
    end

    -- Handle remaining unused tags
    for _, tag in ipairs(availableTags) do
        for _, tagType in pairs({ tag.male, tag.female }) do
            if tagType then
                local ped = RegisterEntityForCutscene(0, tagType, 3, 0, 64)
                if ped then
                    SetEntityVisible(ped, false, false)
                end
            end
        end
    end

    return {
        cutscene = cutscene,
        coords = coords,
        tags = usedTags,
        srcs = srcs,
        peds = playersToProcess,
        clothes = clothes,
    }
end

function Cutscene.Start(cutsceneData)
    if not cutsceneData then
        print("Cutscene.Start: Cutscene data is nil.")
        return
    end

    DoScreenFadeIn(FADE_DURATION)
    Cutscene.done = false

    local clothes = cutsceneData.clothes
    local coords = cutsceneData.coords

    -- Start cutscene
    if coords then
        if type(coords) == 'boolean' then
            coords = GetEntityCoords(PlayerPedId())
        end
        StartCutsceneAtCoords(coords.x, coords.y, coords.z, 0)
    else
        StartCutscene(0)
    end

    Wait(100)

    -- Apply clothing to cutscene characters
    for k, datam in pairs(clothes) do
        local ped = datam.ped
        if DoesEntityExist(ped) then
            SetCutscenePedComponentVariationFromPed(k, ped, 0)
            ApplyPedOutfit(ped, datam.clothing)
        end
    end

    -- Scene loading thread
    CreateThread(function()
        local lastCoords
        while not Cutscene.done do
            local coords = GetWorldCoordFromScreenCoord(0.5, 0.5)
            if not lastCoords or #(lastCoords - coords) > 100 then
                NewLoadSceneStartSphere(coords.x, coords.y, coords.z, 2000, 0)
                lastCoords = coords
            end
            Wait(500)
        end
    end)

    -- Control blocking thread
    CreateThread(function()
        while not Cutscene.done do
            DisableAllControlActions(0)
            DisableFrontendThisFrame()
            Wait(3)
        end
    end)

    -- Main cutscene loop
    while not HasCutsceneFinished() and not Cutscene.done do
        Wait(0)
        if IsDisabledControlJustPressed(0, 200) then
            DoScreenFadeOut(FADE_DURATION)
            Wait(FADE_DURATION)
            StopCutsceneImmediately()
            Wait(500)
            Cutscene.done = true
            break
        end
    end

    -- Cleanup
    DoScreenFadeIn(FADE_DURATION)
    for _, playerData in ipairs(cutsceneData.peds) do
        local ped = playerData.ped
        if not ped or not DoesEntityExist(ped) then goto continue end

        if playerData.identifier == 'script' then
            DeleteEntity(ped)
        elseif playerData.identifier == 'localplayer' then
            SetEntityCoords(ped, playerData.coords.x, playerData.coords.y, playerData.coords.z, false, false, false, false)
        end
        ::continue::
    end
    Cutscene.done = true
end


-- RegisterCommand('cutscene', function(source, args, rawCommand)
--     local cutscene = args[1]
--     if cutscene then
--         local cutsceneData = Cutscene.Create(cutscene, false, { 1,1,1 })
--         Cutscene.Start(cutsceneData)
 
--     end
-- end, false)

return Cutscene
