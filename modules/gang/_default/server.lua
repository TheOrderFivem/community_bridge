---@diagnostic disable: duplicate-set-field
Gang = {}

function Gang.GetGang(source)
    return Framework.GetPlayerGangData(source)
end

function Gang.SetGang(source, gangName, gangGrade)
    return Framework.SetPlayerGang(source, gangName, gangGrade)
end
