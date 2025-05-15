HelpText = HelpText or {}

---This will show a help text message to the specified player at the screen position passed
---@param src number
---@param message string
---@param position string
---@diagnostic disable-next-line: duplicate-set-field
HelpText.ShowHelpText = function(src, message, position)
    TriggerClientEvent('community_bridge:Client:ShowHelpText', src, message, position)
end

---This will hide the help text message on the screen for the specified player
---@param src number
---@diagnostic disable-next-line: duplicate-set-field
HelpText.HideHelpText = function(src)
    TriggerClientEvent('community_bridge:Client:HideHelpText', src)
end

return HelpText