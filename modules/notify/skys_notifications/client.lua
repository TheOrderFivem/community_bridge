---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "skys_notifications"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end

local Language = Language or Require("modules/locales/shared.lua")
local locale = Language.Locale
local placeHolderText = locale("Notifications.PlaceholderTitle")

Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    _type = _type or "info"
    return exports.skys_notifications:NewNotification(message, _type, time)
end

---This will send a notify message of the type and time passed
---@param title string
---@param message string
---@param _type stringlib
---@param time number
---@props table optional
---@return nil
Notify.SendNotification = function(title, message, _type, time, props)
    time = time or 3000
    if not title then title = placeHolderText end
    _type = _type or "info"
    return exports.skys_notifications:NewNotification(message, _type, time, props.icon, title)
end

return Notify