---@diagnostic disable: duplicate-set-field
BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "default"
end

BossMenu.OpenBossMenu = function(src, jobName, jobType)
    print("You are using the community_bridge module for boss menus. Please ensure you have the correct dependencies installed.")
end

BossMenu.OpenGangMenu = function(src, gangName)
    print("You are using the community_bridge module for gang menus. Please ensure you have the correct dependencies installed.")
end

return BossMenu