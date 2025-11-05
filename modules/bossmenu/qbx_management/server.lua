---@diagnostic disable: duplicate-set-field
if GetResourceState('qbx_management') ~= 'started' then return end

BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "qbx_management"
end

---@description This will open the boss menu for the specified job.
---@param src number
---@param jobName string
---@param jobType string
BossMenu.OpenBossMenu = function(src, jobName, jobType)
    TriggerClientEvent("community_bridge:client:OpenBossMenu", src, jobName, jobType)
end

---@description This will open the gang menu for the specified gang.
---@param src number
---@param gangName string
BossMenu.OpenGangMenu = function(src, gangName)
    TriggerClientEvent("community_bridge:client:OpenGangMenu", src, gangName)
end

return BossMenu