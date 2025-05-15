
---@class Math
------@field public name string @add name field to class Car, you'll see it in code completion
Math = {}

--- If the value is less than the minimum, it will return the minimum.
--- If the value is greater than the maximum, it will return the maximum.
--- Otherwise, it will return the value.
---@param value number: The value to clamp.
---@param min number: The minimum value.
---@param max number: The maximum value.
---@return number: The clamped value.
function Math.Clamp(value, min, max)
    if value < min then
        return min
    elseif value > max then
        return max
    else
        return value
    end
end

--- Rounds a number to the nearest whole number.
---@param value number: The value to round.
---@return number: The rounded value.
function Math.Round(value)
    return math.floor(value + 0.5)
end

function Math.Truncate(value, decimals)
	local mul = decimals and (10 ^ decimals) or 1
	if value < 0 then
		return math.ceil(value * mul) / mul
	else
		return math.floor(value * mul) / mul
	end
end

--- Warps the number around from max to min and vice versa.
---@param value number: The value to wrap.
---@param min number: The minimum value.
---@param max number: The maximum value.
---@return number: The wrapped value.
function Math.Wrap(value, min, max)
    local range = max - min
    return (value - min) % range + min
end

--- Gets an interpolated value between two numbers.
---@see https://en.wikipedia.org/wiki/Smoothstep
---@param value number The interpolation value.
---@param min number : The minimum value.
---@param max number : The maximum value.
---@return number The interpolated value.
function Math.Smooth(value, min, max)
    value = Math.Clamp((value - min) / (max - min), 0, 1)
    return value * value * (3 - 2 * value)
end

--- Maps a value from one range to another.
---@param value number The value to map.
---@param inMin number The minimum value for the provided value.
---@param inMax number The maximum value for the provided value.
---@param outMin number The minimum value for the output.
---@param outMax number The maximum value for the output.
function Math.Map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) / (inMax - inMin) * (outMax - outMin) + outMin
end

return Math