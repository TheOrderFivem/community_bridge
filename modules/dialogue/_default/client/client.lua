--[[This module is incomplete]]--


local promises = {}
local activeDialogue = nil
local pendingCameraDestroy = false
Dialogue = {}

local cam = nil
local npc = nil

function Dialogue.Close(name)
    -- Instead of destroying immediately, wait to see if new dialogue opens
    pendingCameraDestroy = true
    activeDialogue = nil

    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "close",
        name = name
    })

    -- Wait brief moment to see if new dialogue opens
    CreateThread(function()
        Wait(50) -- Small delay to allow new dialogue to open
        if pendingCameraDestroy and not activeDialogue then
            -- No new dialogue opened, safe to destroy camera
            RenderScriptCams(false, 1, 1000, 1, 0)
            SetCamActive(cam, false)
            DestroyCam(cam, false)
            cam = nil
        end
    end)

    promises[name] = nil
end

--- Open a dialogue with the player
--- @param name string
--- @param dialogue string
--- @param options table example = {{  id = string, label = string}}
function Dialogue.Open( name, dialogue, characterOptions, dialogueOptions, onSelected)
    assert(name, "Name is required")
    assert(dialogue, "Dialogue is required")
    assert(dialogueOptions, "Dialogue options are required")
    assert(characterOptions, "CharacterOptions must be a number or table containing an entity")
    local isCharacterATable = type(characterOptions) == "table"
    local entity = isCharacterATable and characterOptions.entity or tonumber(characterOptions)
    local offset = isCharacterATable and characterOptions.offset or vector3(0, 0, 0)
    local rotationOffset = isCharacterATable and characterOptions.rotationOffset or vector3(0, 0, 0)

    -- Cancel any pending camera destroy
    pendingCameraDestroy = false
    activeDialogue = name

    -- camera magic!
    if entity then
        local pedHeading = GetEntityHeading(entity)
        -- Convert heading to radians and calculate offset
        local angleRad = math.rad(pedHeading)
        local offsetX = math.sin(angleRad) * 1.5
        local offsetY = math.cos(angleRad) * 1.5

        -- Get position in front of ped based on their heading
        local endLocation = GetEntityCoords(entity) + vector3(offsetX * offset.x, offsetY * offset.y, 0.5)

        if not cam then cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1) end
        local camPos = GetCamCoord(cam)
        local dist = #(endLocation - camPos)
        local abs = cam and math.abs(dist)
        if not abs or abs > 0.5 then      
            local camAngle = (pedHeading + 180.0) % 360.0
            SetCamRot(cam, rotationOffset.x, rotationOffset.y, camAngle + rotationOffset.z, 2)
            SetCamCoord(cam, endLocation.x, endLocation.y, endLocation.z)
            RenderScriptCams(true, true, 1000, true, false)
            SetCamActive(cam, true)
        end
    end
    SendNUIMessage({
        type = "open",
        text =  dialogue,
        name = name,
        options = dialogueOptions
    })
    SetNuiFocus(true, true)


    local prom = promise.new()
    local wrappedFunction = function(selected)
        SetNuiFocus(false, false)
        Dialogue.Close(name)
        if onSelected then onSelected(selected) end
        prom:resolve(selected)
    end
    promises[name] = wrappedFunction
    return Citizen.Await(prom)
end


RegisterNuiCallback("dialogue:SelectOption", function(data)
    local promis = promises[data.name]
    if not promis then return end
    promis(data.id)
end)

-- Debug command
if BridgeSharedConfig.DebugLevel  >= 1 then
    RegisterCommand("dialogue", function()
        local pos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 2.0, 0)
        local timeout = 500 
        local model = `a_f_y_hipster_01`
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(0)
            timeout = timeout - 1
            if timeout == 0 then
                print("Failed to load model")
                return
            end
        end
        local ped = CreatePed(0, model, pos.x, pos.y, pos.z, 0.0, false, false)

        local characterData = {
            entity = ped,
            offset = vector3(0, 0, 0),
            rotationOffset = vector3(0, 0, 0)
        }
        Wait(750)
        Dialogue.Open("Akmed", "Hello how are you doing my friend?", characterData, {
            {
                label = "Trade with me",
                id = 'something',
            },
            {
                label = "Goodbye",
                id = 'someotherthing',
            },
        },
        function(selectedId)
            if selectedId == 'something' then
                Dialogue.Open( "Akmed" , "Thank you for wanting to purchase me lucky charms", characterData, {
                    {
                        label = "Fuck off",
                        id = 'something',
                    },
                    {
                        label = "Goodbye",
                        id = 'someotherthing',
                    },
                },
                function(selectedId)
                    DeleteEntity(ped)
                    if selectedId == "something" then
                        print("You hate lucky charms")
                    else
                        print("Thanks for keeping it civil")
                    end
                end)
            else
                DeleteEntity(ped)
            end
        end)
    end)
end

return Dialogue