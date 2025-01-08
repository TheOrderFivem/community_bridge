if GetResourceState('qbx_core') ~= 'started' then return end

QBox = exports.qbx_core

Framework = {}

Framework.GetPlayerData = function()
    return QBox.GetPlayerData()
end

Framework.GetPlayerMetaData = function(metadata)
    local playerData = QBox.GetPlayerData()
    return playerData.metadata[metadata]
end

Framework.GetPlayerIdentifier = function()
    return QBox.GetPlayerData().citizenid
end

Framework.GetPlayerName = function()
    local playerData = QBox.GetPlayerData()
    return playerData.charinfo.firstname, playerData.charinfo.lastname
end

Framework.GetPlayerJob = function()
    local playerData = QBox.GetPlayerData()
    return playerData.job.name, playerData.job.label, playerData.job.grade.name, playerData.job.grade.level
end

Framework.GetPlayerInventory = function()
    return QBox.GetPlayerData().items
end

Framework.GetIsPlayerDead = function()
    return QBox.GetPlayerData().metadata["isdead"] or QBox.GetPlayerData().metadata["inlaststand"]
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