---@diagnostic disable: duplicate-set-field
if GetResourceState('tk_dispatch') == 'missing' then return end
Dispatch = Dispatch or {}

Dispatch.SendAlert = function(data)
    local alertData = {
        title = data.message,
        code = data.code or '10-80',
        priority = 'Priority 3',
        coords = data.coords or GetEntityCoords(PlayerPedId()),
        showLocation = true,
        showGender = false,
        playSound = true,
        blip = {
            color = data.blipData.color or 3,
            sprite = data.blipData.sprite or 1,
            scale = data.blipData.scale or 0.8,
        },
        jobs = data.jobs or {'police'},
    }
    exports.tk_dispatch:addCall(alertData)
end

---This will get the name of the in use resource.
---@return string
Dispatch.GetResourceName = function()
    return 'tk_dispatch'
end

return Dispatch