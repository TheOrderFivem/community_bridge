if GetResourceState('cd_dispatch') ~= 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local plyrData = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = data.jobs,
        coords = data.coords,
        title = data.message,
        message = data.message,
        flash = 0,
        unique_id = plyrData.unique_id,
        sound = 1,
        blip = {
            sprite = data.blipData.sprite,
            scale = data.blipData.scale,
            colour = data.blipData.color,
            flashes = false,
            text = data.message,
            time = (data.time / 1000),
            radius = 0,
        }
    })
end

return Dispatch