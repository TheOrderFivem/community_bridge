if GetResourceState('cd_dispatch') ~= 'started' then return end

Dispatch = {}

Dispatch.SendAlert = function(data)
    local playerData = exports['cd_dispatch']:GetPlayerInfo()
    local randomID = Bridge.helper.RandomString()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = data.job,
        coords = data.coords or playerData.coords,
        title = data.code or '10-80',
        message = data.message,
        flash = 0,
        unique_id = randomID,
        sound = 1,
        blip = { sprite = 431, scale = 1.2, colour = 3, flashes = false, text = data.message, time = 10000, radius = 0, }
    })
end