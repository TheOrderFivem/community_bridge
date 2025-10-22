---@diagnostic disable: duplicate-set-field
if GetResourceState('fd_dispatch') == 'missing' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local metadata = {}
    if data.vehicle then
        table.insert(metadata, {
            type = 'vehicle',
            model = data.vehicle or locale('unknown_vehicle_model'),
            plate = data.plate or nil,
            color = data.colorHex or nil
        })
    end
    local coords = data.coords or GetEntityCoords(PlayerPedId())
    local alertData = {
        title = data.message or "No message provided",
        description = data.message or "",
        groups = data.jobs or data.job or "police",
        location = {coords = coords, street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))},
        code = data.code or '10-80',
        priority = data.priority or 2,
        metadata = metadata,
        blip = {
            radius = data.blipData and data.blipData.radius or 0,
            sprite = data.blipData and data.blipData.sprite or 161,
            color = data.blipData and data.blipData.color or 84,
            scale = data.blipData and data.blipData.scale or 1.0,
            time  = data.time and (data.time / 1000) or nil,
        },
    }
    exports["fd_dispatch"]:CustomAlert(alertData)
end

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'fd_dispatch'
end

return Dispatch