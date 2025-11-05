---@diagnostic disable: duplicate-set-field
if GetResourceState('esx_society') ~= 'started' then return end

BossMenu = BossMenu or {}

---@description This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "esx_society"
end

local registeredSocieties = {}

---@description This will open the boss menu for the specified job.
---@param src number
---@param jobName string
---@param jobType string
BossMenu.OpenBossMenu = function(src, jobName, jobType)
    if not registeredSocieties[jobName] then
        exports["esx_society"]:registerSociety(jobName, jobName, 'society_' .. jobName, 'society_' .. jobName, 'society_' .. jobName, {type = 'private'})
        registeredSocieties[jobName] = true
    end
    TriggerClientEvent("community_bridge:client:OpenBossMenu", src, jobName, jobType)
end

---@description This will open the gang menu for the specified gang.
---@param src number
---@param gangName string
BossMenu.OpenGangMenu = function(src, gangName)
    print("ESX Society does not support gangs natively. Please use a different boss menu module for gang support.")
end

return BossMenu