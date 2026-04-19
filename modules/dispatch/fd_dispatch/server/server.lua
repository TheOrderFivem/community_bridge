if GetResourceState('fd_dispatch') == 'missing' then return end
if GetResourceState('lb-tablet') == 'started' then return end
Dispatch = Dispatch or {}

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'fd_dispatch'
end

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
    if type(data.job) == "string" then
        data.job = {data.job}
    end
    local coords = data.coords or nil
    local alertData = {
        source = data.source,
        title = data.title or "No message provided",
        description = data.message or "",
        groups = data.jobs or data.job or {"police"},
        code = data.code or '10-80',
        priority = data.priority or 2,
        metadata = metadata,
        blip = {
            radius = data.blip and data.blip.radius or 0,
            sprite = data.blip and data.blip.sprite or 161,
            color = data.blip and data.blip.color or 84,
            scale = data.blip and data.blip.scale or 1.0,
            time  = data.time and (data.time / 1000) or nil,
        },
    }
    exports.fd_dispatch:addAlert(alertData)
end

return Dispatch
