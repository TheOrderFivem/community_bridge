---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "lation_ui"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end


Notify.GetResourceName = function()
    return resourceName
end



Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    return exports.lation_ui:notify({ message = message, type = _type or "success", duration = time, position = 'top-right' })
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
    return exports.lation_ui:notify({ title = title, message = message, type = _type or "success", duration = time, position = 'top-right' })
end

return Notify