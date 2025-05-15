local resourceName = "ox_lib"
local configValue = BridgeClientConfig.ProgressBarSystem
if (configValue == "auto" and GetResourceState(resourceName) ~= "started") or (configValue ~= "auto" and configValue ~= resourceName) then return end

ProgressBar = ProgressBar or {}

local function convertFromQB(options)
    if not options then return options end
    local prop1 = options.prop or {}
    local prop2 = options.propTwo or {}
    local props = {
        {
            model = prop1.model,
            bone = prop1.bone,
            pos = prop1.coords,
            rot = prop1.rotation,       
        },
        {
            model = prop2.model,
            bone = prop2.bone,
            pos = prop2.coords,
            rot = prop2.rotation,
        }
    }
    
    
    return {
        duration = options.duration,
        label = options.label,
        position = 'bottom',
        useWhileDead = options.useWhileDead,
        canCancel = options.canCancel,
        disable = {
            move = options.controlDisables?.disableMovement,
            car = options.controlDisables?.disableCarMovement,
            combat = options.controlDisables?.disableCombat,
            mouse = options.controlDisables?.disableMouse
        },
        anim = {
            dict = options.animation?.animDict,
            clip = options.animation?.anim
        },
        prop = props,
    }
end

---comment
---@param options table
---@param cb any
---@param isQBInput boolean
---@return nil
---@diagnostic disable-next-line: duplicate-set-field
function ProgressBar.Open(options, cb, isQBInput)
    if isQBInput then
        options = convertFromQB(options)
    end

    local style = options.style or 'bar'
    local success = style == 'circle' and exports.ox_lib:progressCircle(options) or exports.ox_lib:progressBar(options)

    if cb then cb(not success) end
    return success
end

return ProgressBar

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
        }
    }, function(cancelled)
        print(cancelled and "Cancelled" or "Complete")
    end)
end)
--]]
