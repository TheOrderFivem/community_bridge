---@diagnostic disable: duplicate-set-field
BossMenu = BossMenu or {}

---This will get the name of the module being used.
---@return string
BossMenu.GetResourceName = function()
    return "default"
end

RegisterNetEvent('community_bridge:client:OpenBossMenu', function(jobName, jobType)
    -- these systems seem to do the verification for isboss themselves, so we don't need to check if the player is a boss.
    -- also this source check is to ensure that the event is only triggered by the server.
    if source ~= 65535 then return end
    if BossMenu.GetResourceName() == "esx_society" then
        local ESX = exports["es_extended"]:getSharedObject() -- better solution needed but fuck it for now.
        TriggerEvent('esx_society:openBossMenu', jobName, function(menu)
            ESX.CloseContext()
        end, {wash = false})
    elseif BossMenu.GetResourceName() == "qbx_management" then
        exports.qbx_management:OpenBossMenu(jobType)
    elseif BossMenu.GetResourceName() == "tk_bosstablet" then
        exports.tk_bosstablet:openBossMenu()
    elseif BossMenu.GetResourceName() == "zat-bossmenu" then
        exports['zat-bossmenu']:OpenBossMenu(jobType or 'job')
    end
end)

return BossMenu