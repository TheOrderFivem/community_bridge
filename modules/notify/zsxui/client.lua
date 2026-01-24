---@diagnostic disable: duplicate-set-field
Notify = Notify or {}
local resourceName = "ZSX_UIV2"
local configValue = BridgeSharedConfig.Notify
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Notify.GetResourceName = function()
    return resourceName
end

local Language = Language or Require("modules/locales/shared.lua")
local locale = Language.Locale
local placeHolderText = locale("Notifications.PlaceholderTitle")

local function getIconByType(_type)
    local icon = "info"
    if _type == "success" then
        icon = "check-circle"
    elseif _type == "error" then
        icon = "times-circle"
    elseif _type == "warning" then
        icon = "exclamation-triangle"
    end
    return icon
end

Notify.SendNotify = function(message, _type, time)
    time = time or 3000
    local icon = getIconByType(_type)
    local serial = exports['ZSX_UIV2']:Notification(placeHolderText, message, icon, time)
    return serial
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
    if not title then title = placeHolderText end
    local icon = getIconByType(_type)
    exports['ZSX_UIV2']:Notification(title, message, icon, time)
end

return Notify