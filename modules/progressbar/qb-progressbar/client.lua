local resourceName = "progressbar"
local configValue = BridgeClientConfig.ProgressBarSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

ProgressBar = ProgressBar or {}

local function convertFromOx(options)
    if not options then return options end
    local prop1 = options.prop?[1] or options.prop or {}
    local prop2 = options.prop?[2] or {}
    return {
        name = options.label,
        duration = options.duration,
        label = options.label,
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        controlDisables = {
            disableMovement = options.disable?.move,
            disableCarMovement = options.disable?.car,
            disableMouse = options.disable?.mouse,
            disableCombat = options.disable?.combat
        },
        animation = {
            animDict = options.anim?.dict,
            anim = options.anim?.clip,
            flags = 49
        },
        prop = {
            model = prop1.model,
            bone = prop1.bone,
            coords = prop1.pos, 
            rotation = prop1.rot
        },
        propTwo = {
            model = prop2.model,
            bone = prop2.bone,
            coords = prop2.pos, 
            rotation = prop2.rot
        }
    }
end

---comment
---@param options table
---@param cb any
---@param qbFormat boolean
---@return success boolean
---@diagnostic disable-next-line: duplicate-set-field
function ProgressBar.Open(options, cb, qbFormat)
    if not exports['progressbar'] then return false end

    if not qbFormat then
        options = convertFromOx(options)
    end
    local prom = promise.new()
    exports['progressbar']:Progress(options, function(cancelled)
        if cb then cb(not cancelled) end
        prom:resolve(not cancelled)
    end)
    return Citizen.Await(prom)
end

return ProgressBar


-- Example usage:
--[[
RegisterCommand("progressbar", function()
    ProgressBar.Open({
        duration = 5000,
        label = "Searching",
        disable = {
            move = true,
            combat = true
        },
        anim = {
            dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
            clip = "machinic_loop_mechandplayer"
        },
        prop = {
            model = "prop_ar_arrow_3",
            pos = vector3(0.0, 0.0, 0.0),
            rot = vector3(0.0, 0.0, 0.0)
        },
    }, function(cancelled)
        print(cancelled and "Cancelled" or "Complete")
    end)
end)
--]]
