---@diagnostic disable: duplicate-set-field
if GetResourceState('wasabi_mdt') == 'missing' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local fallbackCoords = GetEntityCoords(PlayerPedId())
    local alertData = {
        type = data.code or '10-80',
        title = data.code or '10-80',
        description = data.message or "No message provided",
        location = {data.coords.x, data.coords.y, data.coords.z} or {fallbackCoords.x, fallbackCoords.y, fallbackCoords.z},
        coords = {data.coords.x, data.coords.y, data.coords.z} or {fallbackCoords.x, fallbackCoords.y, fallbackCoords.z},
    }
    exports.wasabi_mdt:CreateDispatch(alertData)
end

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'wasabi_mdt'
end

return Dispatch