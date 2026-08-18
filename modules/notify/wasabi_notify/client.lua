---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "wasabi_notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end

Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    _type = _type or "info"
    return exports.wasabi_notify:notify(_type, message, time, _type)
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type string
---@param time number
---@props table optional
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    if not title then title = lib.locale("Notifications.PlaceholderTitle") end
    _type = _type or "info"
    return exports.wasabi_notify:notify(_type, message, time, _type)
end

return Notify