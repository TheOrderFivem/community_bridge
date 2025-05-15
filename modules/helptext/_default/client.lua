HelpText = HelpText or {}

---This will show a help text message at the screen position passed
---@param message string
---@param _position string
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
HelpText.ShowHelpText = function(message, _position)
    return Framework.ShowHelpText(message, _position)
end

---This will hide the help text message on the screen
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
HelpText.HideHelpText = function()
    return Framework.HideHelpText()
end

RegisterNetEvent('community_bridge:Client:ShowHelpText', function(message, position)
    HelpText.ShowHelpText(message, position)
end)

RegisterNetEvent('community_bridge:Client:HideHelpText', function()
    HelpText.HideHelpText()
end)

return HelpText