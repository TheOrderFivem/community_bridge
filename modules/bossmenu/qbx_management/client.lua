---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_management') ~= 'started' then return end

BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "qbx_management"
end

return BossMenu