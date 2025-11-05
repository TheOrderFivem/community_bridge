---@diagnostic disable: duplicate-set-field
if GetResourceState('qb-management') ~= 'started' then return end
if GetResourceState('qbx_management') == 'started' then return end

BossMenu = BossMenu or {}

---This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "qb-management"
end

BossMenu.OpenBossMenu = function(src, jobName, jobType)
    TriggerClientEvent("qb-bossmenu:client:OpenMenu", src)
end

BossMenu.OpenGangMenu = function(src, gangName)
    TriggerClientEvent("qb-gangmenu:client:OpenMenu", src)
end

return BossMenu