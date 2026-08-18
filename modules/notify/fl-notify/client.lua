---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "FL-Notify"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end

Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    if _type == "error" or _type == "info" then
        _type = tostring(1)
    elseif _type == "success" then
        _type = tostring(2)
    elseif _type == "warning" or _type == "warn" then
        _type = tostring(3)
    else
        _type = tostring(2) -- Default to 2 if type is not recognized
    end
    return exports['FL-Notify']:Notify("Notification", "", message, 5000, tonumber(_type), 0)
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
    if _type == "error" or _type == "info" then
        _type = tostring(1)
    elseif _type == "success" then
        _type = tostring(2)
    elseif _type == "warning" or _type == "warn" then
        _type = tostring(3)
    else
        _type = tostring(2) -- Default to 2 if type is not recognized
    end
    return exports['FL-Notify']:Notify("Notification", "", message, 5000, tonumber(_type), 0)
end

return Notify