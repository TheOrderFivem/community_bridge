---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_society') ~= 'started' then return end

BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "esx_society"
end

return BossMenu