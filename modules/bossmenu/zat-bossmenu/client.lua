---@diagnostic disable: duplicate-set-field
if GetResourceState('zat-bossmenu') ~= 'started' then return end

BossMenu = BossMenu or {}

---This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "zat-bossmenu"
end

return BossMenu
