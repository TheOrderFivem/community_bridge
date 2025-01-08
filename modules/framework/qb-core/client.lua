if GetResourceState('qb-core') ~= 'started' then return end
if GetResourceState('qbx_core') == 'started' then return end

QBCore = exports['qb-core']:GetCoreObject()

Framework = {}

Framework.GetPlayerData = function()
    return QBCore.Functions.GetPlayerData()
end

Framework.GetPlayerMetaData = function(metadata)
    return QBCore.Functions.GetPlayerData().metadata[metadata]
end

Framework.GetItemInfo = function(item)
    local itemData = QBCore.Shared.Items[item]
    if not itemData then return {} end
    local repackedTable = {
        name = itemData.name,
        label = itemData.label,
        stack = itemData.unique,
        weight = itemData.weight,
        description = itemData.description,
        image = itemData.image
    }
    return repackedTable
end

Framework.GetPlayerIdentifier = function()
    return QBCore.Functions.GetPlayerData().citizenid
end

Framework.GetPlayerName = function()
    local playerData = QBCore.Functions.GetPlayerData()
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

Framework.GetPlayerJob = function()
    local playerData = QBCore.Functions.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

Framework.GetPlayerInventory = function()
    return QBCore.Functions.GetPlayerData().items
end

Framework.GetIsPlayerDead = function()
    return QBCore.Functions.GetPlayerData().metadata["isdead"] or QBCore.GetPlayerData().metadata["inlaststand"]
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    Wait(1500)
    FillBridgeTables()
    TriggerEvent('community_bridge:Client:OnPlayerLoaded')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    ClearClientSideVariables()
	TriggerEvent('community_bridge:Client:OnPlayerUnload')
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(data)
    PlayerJobName = data.name
    PlayerJobLabel = data.label
    PlayerJobGradeName = data.grade.name
    PlayerJobGradeLevel = data.grade.level
    TriggerEvent('community_bridge:Client:OnPlayerJobUpdate',PlayerJobName, PlayerJobLabel, PlayerJobGradeName, PlayerJobGradeLevel)
end)