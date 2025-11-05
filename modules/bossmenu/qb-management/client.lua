---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-management') ~= 'started' then return end
if GetResourceState('qbx_management') == 'started' then return end

BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "qb-management"
end

return BossMenu