Utility = {}
local blipIDs = {}
local spawnedPeds = {}
lib.locale()

Utility.CreateVehicle = function(model, coords, heading, networked)
    if networked == nil then networked = true end
    Utility.LoadModel(model)
    if not HasModelLoaded(model) then return Prints.error("Model Has Not Loaded") end
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, networked, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetModelAsNoLongerNeeded(model)
    SetVehRadioStation(vehicle, "OFF")
    return vehicle, { networkid = NetworkGetNetworkIdFromEntity(vehicle) or 0, coords = GetEntityCoords(vehicle), heading = GetEntityHeading(vehicle), }
end

Utility.StartBusySpinner = function(text)
    AddTextEntry(text, text)
    BeginTextCommandBusyString(text)
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandBusyString(0)
end

Utility.StopBusySpinner = function()
    if BusyspinnerIsOn() then BusyspinnerOff() end
end

Utility.CreateProp = function(model, coords, heading, networked)
    if networked == nil then networked = true end
    Utility.LoadModel(model)
    if not HasModelLoaded(model) then return Prints.error("Model Has Not Loaded") end
    local propEntity = CreateObject(model, coords.x, coords.y, coords.z, networked, false, false)
    SetEntityHeading(propEntity, heading)
    SetModelAsNoLongerNeeded(model)
    return propEntity
end

Utility.CreateBlip = function(coords, sprite, color, scale, label, shortRange)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite or 8)
    SetBlipColour(blip, color or 3)
    SetBlipScale(blip, scale or 0.8)
    SetBlipAsShortRange(blip, shortRange)
    AddTextEntry(label, label)
    BeginTextCommandSetBlipName(label)
    EndTextCommandSetBlipName(blip)
    table.insert(blipIDs, blip)
    return blip
end

Utility.RemoveBlip = function(blip)
    local success = false
    for i, storedBlip in ipairs(blipIDs) do
        if storedBlip == blip then
            RemoveBlip(blip)
            table.remove(blipIDs, i)
            success = true
            break
        end
    end
    return success
end

Utility.LoadModel = function(model)
    if type(model) ~= 'number' then model = joaat(model) end
    if not IsModelValid(model) and not IsModelInCdimage(model) then return false end
    RequestModel(model)
    local count = 0
    while not HasModelLoaded(model) and count < 30000 do
        Wait(0)
        count = count + 1
    end
    return HasModelLoaded(model)
end

Utility.CreatePed = function(model, coords, heading, networked, clothing)
    if networked == nil then networked = true end
    Utility.LoadModel(model)
    if not HasModelLoaded(model) then return Prints.error("Model Has Not Loaded") end
    local spawnedEntity = CreatePed(0, model, coords.x, coords.y, coords.z, heading, networked, false)
    if clothing then
        for componentID, v in pairs(clothing) do
            SetPedComponentVariation(spawnedEntity, componentID, v[1], v[2], 0)
        end
    end
    FreezeEntityPosition(spawnedEntity, true)
    SetEntityInvincible(spawnedEntity, true)
    SetBlockingOfNonTemporaryEvents(spawnedEntity, true)
    SetModelAsNoLongerNeeded(model)
    table.insert(spawnedPeds, spawnedEntity)
    return spawnedEntity
end

Utility.RemovePed = function(entity)
    local success = false
    DeleteEntity(entity)
    for i, storedEntity in ipairs(spawnedPeds) do
        if storedEntity == entity then
            table.remove(spawnedPeds, i)
            success = true
            break
        end
    end
    return success
end

Utility.NativeInputMenu = function(text, length)
    local maxLength = Math.Clamp(length, 1, 50)
    local menutText = text or 'enter text'
    AddTextEntry(menutText, menutText)
    DisplayOnscreenKeyboard(1, menutText, "", "", "", "", "", maxLength)
    while(UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if(GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
    return false
end

Utility.GetEntitySkinData = function(entity)
    local skinData = {}
    skinData.clothing = {}
    for i = 0, 11 do
        skinData.clothing[i] = {GetPedDrawableVariation(entity, i), GetPedTextureVariation(entity, i)}
    end
    return skinData
end

Utility.SetEntitySkinData = function(entity, skinData)
    for i = 0, 11 do
        SetPedComponentVariation(entity, i, skinData.clothing[i][1], skinData.clothing[i][2], 0)
    end
    return true
end

Utility.NativeAlert = function(data)
    local message = data.message or 'No message provided'
    local coords = data.coords or GetEntityCoords(cache.ped)
    local job = data.job
    local scale = data.scale or 0.8
    local sprite = data.sprite or 1
    TriggerServerEvent('community_bridge:server:alert', {message = message, coords = coords, job = job, scale = scale, sprite = sprite})
end

Utility.ReloadSkin = function()
    local skinData = Utility.GetEntitySkinData(cache.ped)
    Utility.SetEntitySkinData(cache.ped, skinData)
    for _, props in pairs(GetGamePool("CObject")) do
        if IsEntityAttachedToEntity(cache.ped, props) then
            SetEntityAsMissionEntity(props, true, true)
            DeleteObject(props)
            DeleteEntity(props)
        end
    end
    return true
end

Utility.RestoreAppearance = function(data)
    return Utility.SetEntitySkinData(cache.ped, data)
end

Utility.HelpText = function(text, duration)
    AddTextEntry(text, text)
    BeginTextCommandDisplayHelp(text)
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

Utility.NotifyText = function(text)
    AddTextEntry(text, text)
    SetNotificationTextEntry(text)
    DrawNotification(false, true)
end

Utility.TeleportPlayer = function(coords, conditionFunction, afterTeleportFunction)
    if conditionFunction ~= nil then
        if not conditionFunction() then
            return
        end
    end
    DoScreenFadeOut(2500)
    Wait(2500)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z, false, false, false, false)
    if coords.w then
        SetEntityHeading(cache.ped, coords.w)
    end
    FreezeEntityPosition(cache.ped, true)
    local count = 0
    while not HasCollisionLoadedAroundEntity(cache.ped) and count <= 30000 do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(0)
        count = count + 1
    end
    FreezeEntityPosition(cache.ped, false)
    DoScreenFadeIn(1000)
    if afterTeleportFunction ~= nil then
        afterTeleportFunction()
    end
end

Utility.GetEntityHashFromModel = function(model)
    if type(model) ~= 'number' then model = joaat(model) end
    return model
end

Utility.GetClosestPlayer = function(coords, distanceScope, includeMe)
    local players = GetActivePlayers()
    local closestPlayer = 0
    local selfPed = cache.ped
    local selfCoords = coords or GetEntityCoords(cache.ped)
    local closestDistance = distanceScope or 5

    for _, player in ipairs(players) do
        local playerPed = GetPlayerPed(player)
        if includeMe or playerPed ~= selfPed then
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(selfCoords - playerCoords)
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance, GetPlayerServerId(closestPlayer)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for _, blip in pairs(blipIDs) do
            if DoesBlipExist(blip.id) then
                RemoveBlip(blip.id)
            end
        end
        for _, ped in pairs(spawnedPeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)

RegisterNetEvent('community_bridge:client:alert', function(data)
    local blip = Utility.CreateBlip(data.coords, data.sprite, 3, data.scale, data.message, true)
    SetTimeout(40000, function()
        Utility.RemoveBlip(blip)
    end)
end)