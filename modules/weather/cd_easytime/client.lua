if GetResourceState('cd_easytime') ~= 'started' then return end
Weather = Weather or {}

---comment
---@param toggle boolean
Weather.ToggleSync = function(toggle)
    TriggerEvent('cd_easytime:PauseSync', toggle)
end

return Weather