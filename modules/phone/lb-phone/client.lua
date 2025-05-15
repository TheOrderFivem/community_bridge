local resourceName = "lb-phone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Phone = Phone or {}

---comment
---@param email string
---@param title string
---@param message string
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(email, title, message)
    TriggerServerEvent('community_bridge:Server:genericEmail', {email = email, title = title, message = message})
end

return Phone