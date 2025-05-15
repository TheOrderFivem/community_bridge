local resourceName = "lb-phone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Phone = Phone or {}

---@diagnostic disable-next-line: duplicate-set-field
Phone.GetPlayerPhone = function(src)
    return exports["lb-phone"]:GetEquippedPhoneNumber(src) or false
end

---comment
---@param src number
---@param email string
---@param title string
---@param message string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(src, email, title, message)
    local numberNumber = exports["lb-phone"]:GetEquippedPhoneNumber(src)
    if not numberNumber then return false, Prints.Error("Could not Find Phone number") end
    local playerEmail = exports["lb-phone"]:GetEmailAddress(numberNumber)
    if not playerEmail then return false, Prints.Error("Could not Find email")  end
    local success, id = exports["lb-phone"]:SendMail({
        to = playerEmail,
        sender = email,
        subject = title,
        message = message,
    })
    return success
end

RegisterNetEvent('community_bridge:Server:genericEmail', function(data)
    local src = source
    Prints.Debug('community_bridge:Server:genericEmail Hit')
    return Phone.SendEmail(src, data.email, data.title, data.message)
end)

return Phone