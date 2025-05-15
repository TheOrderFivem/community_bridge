if GetResourceState('ps-dispatch') ~= 'started' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local alertData = {
        message = data.message,
        code = data.code or '10-80',
        icon = data.icon or 'fas fa-question',
        priority = 2,
        coords = data.coords,
        vehicle = data.vehicle,
        plate = data.plate,
        alertTime = (data.time or 10000) / 1000,
        alert = {
            radius = 0,
            recipientList = data.jobs,
            sprite = data.blipData.sprite,
            color = data.blipData.color,
            scale = data.blipData.scale,
            length = 2,
            sound = "Lose_1st",
            sound2 = "GTAO_FM_Events_Soundset",
            offset = false,
            flash = false
        },
        jobs = data.jobs
    }
    exports["ps-dispatch"]:CustomAlert(alertData)
end

return Dispatch