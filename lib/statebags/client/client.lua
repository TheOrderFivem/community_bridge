---@class ClientStateBag
local ClientStateBag = {}

---Gets an entity from a statebag name
---@param bagName string The statebag name
---@return number|nil entity The entity handle or nil if not found
local function getEntityFromBag(bagName)
    if not bagName then return nil end
    return GetEntityFromStateBagName(bagName)
end

---Gets a player from a statebag name
---@param bagName string The statebag name
---@return number|nil playerId The player ID or nil if not found
local function getPlayerFromBag(bagName)
    if not bagName then return nil end
    local prefix = "player:"
    if bagName:sub(1, #prefix) ~= prefix then return nil end
    return tonumber(bagName:sub(#prefix + 1))
end

---Adds a handler for entity statebag changes
---@param keyName string The statebag key to watch for changes
---@param entityId string|nil The specific entity ID to watch, or nil for all entities
---@param callback fun(entityId: number, key: string, value: any, lastValue: any, replicated: boolean)
---@return number handler The handler ID
function ClientStateBag.AddEntityChangeHandler(keyName, entityId, callback)
    if not keyName or type(callback) ~= "function" then return 0 end

    return AddStateBagChangeHandler(keyName, entityId, function(bagName, key, value, lastValue, replicated)
        local entity = getEntityFromBag(bagName)

        -- Ensure entity exists and is valid
        if not entity or not DoesEntityExist(entity) then
            return false
        end

        return callback(entity, key, value, lastValue, replicated)
    end)
end

---Adds a handler for player statebag changes
---@param keyName string The statebag key to watch for changes
---@param filterCurrentPlayer boolean|nil If true, only watch for changes from the current player
---@param callback fun(playerId: number, key: string, value: any, lastValue: any, replicated: boolean)
---@return number handler The handler ID
function ClientStateBag.AddPlayerChangeHandler(keyName, filterCurrentPlayer, callback)
    if not keyName or type(callback) ~= "function" then return 0 end

    local bagFilter = nil
    if filterCurrentPlayer then
        bagFilter = ("player:%s"):format(GetPlayerServerId(PlayerId()))
    end

    return AddStateBagChangeHandler(keyName, bagFilter, function(bagName, key, value, lastValue, replicated)
        local playerId = getPlayerFromBag(bagName)

        -- Validate player
        if not playerId or playerId == 0 then
            return false
        end

        -- Check if player exists and isn't the local player
        local playerPed = GetPlayerPed(playerId)
        if not DoesEntityExist(playerPed) or (playerPed == PlayerPedId()) then
            return false
        end

        return callback(playerId, key, value, lastValue, replicated)
    end)
end

return ClientStateBag
