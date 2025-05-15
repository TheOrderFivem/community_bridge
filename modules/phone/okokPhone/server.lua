---@class NewEmail
---@field sender string
---@field recipients string[]
---@field subject string
---@field actions? EmailAction[]
---@field body string

---@class EmailAction
---@field id string
---@field label string
---@field event string?
---@field exports string?
---@field server boolean
---@field data any

local resourceName = "okokPhone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end
Phone = Phone or {}

---comment
---@param src number
---@return number| boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.GetPlayerPhone = function(src)
    return exports.okokPhone:getPhoneNumberFromSource(src) or false
end

---comment
---@param src number
---@param email string
---@param title string
---@param message string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(src, email, title, message)
    local senderAddress = exports.okokPhone:getEmailAddressFromSource(src) --[[ @as string? ]]
    if not senderAddress then return false end

    ---@type NewEmail
    local data = {
        sender = senderAddress,
        recipients = { email },
        subject = title,
        body = message,
    }

    local success = exports.okokPhone:sendEmail(data) --[[ @as boolean ]]
    return success
end

--<-- TODO swap to internal callback system
lib.callback.registry('community_bridge:Callback:okokPhone:sendEmail', function(src, email, title, message)
    return Phone.SendEmail(src, email, title, message)
end)

return Phone