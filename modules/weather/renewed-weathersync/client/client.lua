if GetResourceState('Renewed-Weathersync') ~= 'started' then return end
Weather = Weather or {}

---comment
---@param toggle boolean
Weather.ToggleSync = function(toggle)
    LocalPlayer.state.syncWeather = toggle
end

return Weather