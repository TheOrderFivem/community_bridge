---@diagnostic disable: duplicate-set-field

local resourceName = "rcore_gangs"
if GetResourceState(resourceName) == 'missing' then return end

Gang = {}

function Gang.GetGang(src)
    local gangData = exports['rcore_gangs']:GetPlayerGang(src) or {}
    local data = {
        name = gangData.id,
        label = gangData.name,
        grade = {name = gangData.rank, label = gangData.rank, level = gangData.rank},
        isBoss = gangData.superaccess or false,
    }
    return data
end

function Gang.SetGang(src, gangName, gangGrade)
    exports['rcore_gangs']:AddMember(src, gangName)
    return exports['rcore_gangs']:SetMemberRank(src, gangGrade, gangName)
end
