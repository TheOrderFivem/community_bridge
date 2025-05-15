Skills = Skills or {}
local resourceName = "pickle_xp"
local configValue = BridgeSharedConfig.Skills
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

---@diagnostic disable-next-line: duplicate-set-field
Skills.GetResourceName = function()
    return resourceName
end

---@diagnostic disable-next-line: duplicate-set-field
Skills.GetSkillLevel = function(skillName)
    local skillData = exports.OT_skills:GetLevel(skillName)
    return skillData or 0
end

return Skills