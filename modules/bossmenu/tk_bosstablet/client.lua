---@diagnostic disable: duplicate-set-field
if GetResourceState('tk_bosstablet') ~= 'started' then return end

BossMenu = BossMenu or {}

---This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "tk_bosstablet"
end

return BossMenu
