---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "brutal_notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


Notify.GetResourceName = function()
    return resourceName
end

Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    return exports['brutal_notify']:SendAlert('Notification', message, time, _type or "success", false)
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
    return exports['brutal_notify']:SendAlert(title, message, time, _type or "success", false)
end

return Notify