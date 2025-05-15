Skills = Skills or {}

local function warnUser()
    print("Currently only a few skill systems are supported by Community Bridge, you are using a resource that requires the skills module to be used.")
end

---@diagnostic disable-next-line: duplicate-set-field
Skills.GetResourceName = function()
    return "none"
end

---@diagnostic disable-next-line: duplicate-set-field
Skills.GetSkillLevel = function(src, skillName)
    return 0, warnUser()
end

---@diagnostic disable-next-line: duplicate-set-field
Skills.AddXp = function(src, skillName, amount)
    return false, warnUser()
end

---@diagnostic disable-next-line: duplicate-set-field
Skills.RemoveXp = function(src, skillName, amount)
    return false, warnUser()
end

return Skills