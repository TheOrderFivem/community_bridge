---@class StringUtil
StringUtil = {}

-- Character sets for random string generation
local charset = {
    numeric = "0123456789",
    lower = "abcdefghijklmnopqrstuvwxyz",
    upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
}

--- Generates a random string based on a pattern
--- Pattern options: 'n' for numbers, 'l' for lowercase, 'u' for uppercase, 's' for special chars
---@param pattern string Pattern to follow (e.g., "llnnn" for 2 letters + 3 numbers)
---@return string Random string following the pattern
function StringUtil.RandomByPattern(pattern)
    local result = ""
    for i = 1, #pattern do
        local char = pattern:sub(i, i)
        local chars = char == 'n' and charset.numeric
            or char == 'l' and charset.lower
            or char == 'u' and charset.upper
            or char == 's' and charset.special
            or charset.lower
        result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars))
    end
    return result
end

--- Generates a random string of specified length
---@param length number Length of the string to generate
---@param includeNumbers boolean? Include numbers (default: true)
---@param includeSpecial boolean? Include special characters (default: false)
---@return string Random string
function StringUtil.Random(length, includeNumbers, includeSpecial)
    local chars = charset.lower .. charset.upper
    if includeNumbers ~= false then chars = chars .. charset.numeric end
    if includeSpecial then chars = chars .. charset.special end

    local result = ""
    for i = 1, length do
        local random = math.random(1, #chars)
        result = result .. chars:sub(random, random)
    end
    return result
end

--- Formats a number with commas as thousands separators
---@param number number The number to format
---@return string Formatted number string
function StringUtil.FormatNumber(number)
    local i, j, minus, int, fraction = tostring(number):find('([-]?)(%d+)([.]?%d*)')
    int = int:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return minus .. int .. fraction
end

--- Truncates a string to a maximum length with ellipsis
---@param str string String to truncate
---@param length number Maximum length
---@param ellipsis string? Custom ellipsis (default: "...")
---@return string Truncated string
function StringUtil.Truncate(str, length, ellipsis)
    ellipsis = ellipsis or "..."
    if #str <= length then return str end
    return str:sub(1, length - #ellipsis) .. ellipsis
end

--- Converts a string to title case
---@param str string String to convert
---@return string Title cased string
function StringUtil.ToTitleCase(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

--- Removes whitespace from both ends of a string
---@param str string String to trim
---@return string Trimmed string
function StringUtil.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

--- Splits a string by delimiter
---@param str string String to split
---@param delimiter string? Delimiter (default: " ")
---@return table Array of substrings
function StringUtil.Split(str, delimiter)
    delimiter = delimiter or " "
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

--- Checks if a string starts with a substring
---@param str string String to check
---@param start string Starting substring
---@return boolean True if string starts with substring
function StringUtil.StartsWith(str, start)
    return str:sub(1, #start) == start
end

--- Checks if a string ends with a substring
---@param str string String to check
---@param ending string Ending substring
---@return boolean True if string ends with substring
function StringUtil.EndsWith(str, ending)
    return ending == "" or str:sub(- #ending) == ending
end

exports("StringUtil", StringUtil)

return StringUtil
