---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "msk_core"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end


---DEPRICATED: PLEASE SWITCH TO Notify.SendNotification
---@param message string
---@param _type string
---@param time number
---@return nil
Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    return exports.msk_core:Notify(nil, message, _type, time)
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type string
---@param time number
---@param props table optional
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    if not title then title = lib.locale("Notifications.PlaceholderTitle") end
    return exports.msk_core:Notify(title, message, _type or "success", time)
end

return Notify
