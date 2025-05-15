if GetResourceState('qs-dispatch') ~= 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local playerData = exports['qs-dispatch']:GetPlayerInfo()
    if not playerData then return print("Error getting player data") end

    local customData = {
        job = data.jobs or { 'police'},
        callLocation = data.coords or vec3(0.0, 0.0, 0.0),
        callCode = {
            code = data.code or '10-80',
            snippet = data.snippet or 'General Alert'
        },
        message = data.message,
        flashes = false,
        image = nil,
        blip = {
            sprite = data.blipData.sprite or 1,
            scale = data.blipData.scale or 1.0,
            colour = data.blipData.color or 1,
            flashes = false,
            text = data.message or "Alert",
            time = data.length and (data.time * 1000) or 20000
        },
        otherData = {
            {
                text = data.name or 'N/A',
                icon = data.icon or 'fas fa-question'
            }
        }
    }

    exports['qs-dispatch']:getSSURL(function(image)
        customData.image = image or customData.image
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', customData)
    end)
end

return Dispatch