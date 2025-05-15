local resourceName = "okokPhone"
local configValue = BridgeSharedConfig.Phone
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

Phone = Phone or {}

---comment
---@param email string
---@param title string
---@param message string
---@return boolean
---@diagnostic disable-next-line: duplicate-set-field
Phone.SendEmail = function(email, title, message)
    --<-- TODO swap to internal callback system
    local success = lib.callback.await('community_bridge:Callback:okokPhone:sendEmail', false, email, title, message) --[[ @as boolean ]]
    return success
end

return Phone