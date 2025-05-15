Dispatch = Dispatch or {}

---This will send an alert to currently supported dispatch systems.
---@param data table The data to send to the dispatch system.
---@return nil
Dispatch.SendAlert = function(data)
    TriggerServerEvent('community_bridge:Server:DispatchAlert', {
        sprite = data.blipData.sprite or 161,
        color = data.blipData.color or 1,
        scale = data.blipData.scale or 0.8,
        vehicle = data.vehicle or nil,
        plate = data.vehicle and GetVehicleNumberPlateText(data.vehicle) or nil,
        ped = data.ped or cache.ped,
        pedCoords = data.pedCoords or GetEntityCoords(cache.ped),
        coords = data.coords or GetEntityCoords(cache.ped),
        message = data.message or "An Alert Has Been Made",
        code = data.code or '10-80',
        icon = data.icon or 'fas fa-question',
        jobs = data.jobs or {'police'},
        time = data.time or 100000
    })
end

RegisterNetEvent('community_bridge:Client:DispatchAlert', function(alert)
    Notify.SendNotify(alert.message, "success", 15000)
    local blip = Bridge.Utility.CreateBlip(alert.coords, alert.sprite, alert.color, alert.scale, alert.code, true)
	Wait(alert.time)
    Bridge.Utility.RemoveBlip(blip)
end)

return Dispatch