local Config = Require('lib/points/client/config')

---@class Point
---@field id string Unique identifier for the point
---@field target vector3|number Static coordinates or entity handle
---@field isEntity boolean Whether the point tracks an entity
---@field coords vector3 Current coordinates
---@field distance number Activation distance
---@field inside boolean Whether player is inside the point
---@field args table Custom data for the point
---@field cellKey string Current grid cell key
local Point = {}

-- Cache frequently used functions for performance
local floor = math.floor
local format = string.format
local insert = table.insert
local pairs = pairs
local type = type
local vector3 = vector3

-- Local state management
local ActivePoints = {}
local GridCells = {}
local LoopStarted = false
local insidePoints = {}
local data = {}

---Converts coordinates to vector3 format
---@param coords vector3|table Coordinates to convert
---@return vector3
local function vector3FromCoords(coords)
    return type(coords) == "vector3" and coords or vector3(coords.x, coords.y, coords.z)
end

---Calculates distance between two points
---@param coords1 vector3|table First coordinate
---@param coords2 vector3|table Second coordinate
---@return number distance
local function calculateDistance(coords1, coords2)
    return #(vector3FromCoords(coords1) - vector3FromCoords(coords2))
end

---Gets the grid cell key for given coordinates
---@param coords vector3 Coordinates to get cell for
---@return string cellKey Format: "x:y"
function Point.GetCellKey(coords)
    local cellX = floor(coords.x / Config.GRID_SIZE)
    local cellY = floor(coords.y / Config.GRID_SIZE)
    return format("%d:%d", cellX, cellY)
end

function Point.RegisterInGrid(point)
    if not point or not point.coords then return false end

    local cellKey = Point.GetCellKey(point.coords)
    GridCells[cellKey] = GridCells[cellKey] or {
        points = {},
        count = 0
    }

    GridCells[cellKey].points[point.id] = point
    GridCells[cellKey].count = GridCells[cellKey].count + 1
    point.cellKey = cellKey
    return true
end

function Point.UpdateInGrid(point, oldCellKey)
    if not point or not point.coords then return false end

    local newCellKey = Point.GetCellKey(point.coords)
    if oldCellKey and oldCellKey == newCellKey then return true end

    -- Remove from old cell
    if oldCellKey and GridCells[oldCellKey] then
        GridCells[oldCellKey].points[point.id] = nil
        GridCells[oldCellKey].count = GridCells[oldCellKey].count - 1

        if GridCells[oldCellKey].count <= 0 then
            GridCells[oldCellKey] = nil
        end
    end

    return Point.RegisterInGrid(point)
end

---Optimized function to get nearby cells using circular range check
---@param coords vector3 Center coordinates
---@param range? number Optional custom range
---@return table nearbyCells Array of cell keys
function Point.GetNearbyCells(coords, range)
    local cellX = floor(coords.x / Config.GRID_SIZE)
    local cellY = floor(coords.y / Config.GRID_SIZE)
    -- Use custom range or default buffer
    local buffer = range and floor(range / Config.GRID_SIZE + 0.5) or Config.CELL_BUFFER
    local nearbyCells = {}

    -- Pre-calculate buffer squared for performance
    local bufferSquared = buffer * buffer

    -- Optimized circular range check
    for x = cellX - buffer, cellX + buffer do
        local dx = x - cellX
        local dxSquared = dx * dx

        for y = cellY - buffer, cellY + buffer do
            -- Check if cell is within circular range using distance formula
            if (dxSquared + (y - cellY) ^ 2) <= bufferSquared then
                local key = format("%d:%d", x, y)
                if GridCells[key] then
                    insert(nearbyCells, key)
                end
            end
        end
    end

    return nearbyCells
end

-- Point management functions
---@class GridCell
---@field points table<string, Point> Points in this cell
---@field count number Number of points in cell

---Registers a point in the grid system
---@param id string Unique identifier
---@param target vector3|number Coordinates or entity handle
---@param distance number Activation distance
---@param args? table Custom data
---@param onEnter? fun(point: Point, data: table): table
---@param onExit? fun(point: Point, data: table): table
---@param onNearby? fun(points: table<string, Point>, waitTime: number)
---@return Point|nil
function Point.Register(id, target, distance, args, onEnter, onExit, onNearby)
    if not id or ActivePoints[id] then return nil end

    local isEntity = type(target) == "number"
    local coords = isEntity and GetEntityCoords(target) or target

    local self = {
        id = id,
        target = target,
        isEntity = isEntity,
        coords = vector3FromCoords(coords),
        distance = distance,
        onEnter = onEnter or function() end,
        onExit = onExit or function() end,
        onNearby = onNearby or function() end,
        inside = false,
        args = args or {}
    }

    ActivePoints[id] = self
    Point.RegisterInGrid(self)
    Point.StartLoop()
    return self
end

function Point.Remove(id)
    local point = ActivePoints[id]
    if not point then return false end

    if GridCells[point.cellKey] then
        GridCells[point.cellKey].points[id] = nil
        GridCells[point.cellKey].count = GridCells[point.cellKey].count - 1

        if GridCells[point.cellKey].count <= 0 then
            GridCells[point.cellKey] = nil
        end
    end

    if insidePoints[id] then
        insidePoints[id] = nil
    end

    ActivePoints[id] = nil
    return true
end

---Updates point coordinates and grid position
---@param id string Point identifier
---@param coords vector3|table New coordinates
---@return boolean success
function Point.UpdateCoords(id, coords)
    local point = ActivePoints[id]
    if not point then return false end

    local oldCellKey = point.cellKey
    point.coords = vector3FromCoords(coords)
    point.cellKey = Point.GetCellKey(point.coords)
    return Point.UpdateInGrid(point, oldCellKey)
end

-- Main loop and processing
function Point.ProcessPoint(point, playerCoords, playerSpeed)
    if not point or not point.coords then return end

    local distance = calculateDistance(playerCoords, point.coords)

    -- Handle enter/exit events
    if distance < point.distance then
        if not point.inside then
            point.inside = true
            data[point.id] = data[point.id] or point.args or {}
            data[point.id] = point.onEnter(point, data[point.id])
            insidePoints[point.id] = point
        end
    elseif point.inside then
        point.inside = false
        data[point.id] = data[point.id] or point.args or {}
        local result = point.onExit(point, data[point.id])
        data[point.id] = result ~= nil and result or data[point.id]
        point.args = data[point.id]
        insidePoints[point.id] = nil
    end

    -- Handle nearby callback
    if point.onNearby then
        local waitTime = Config.ADAPTIVE_WAIT and
            math.max(Config.MIN_WEIGHT, Config.MAX_WEIGHT - playerSpeed * 50) or
            Config.MAX_WEIGHT
        point.onNearby(GridCells[point.cellKey]?.points, waitTime)
    end
end

function Point.StartLoop()
    if LoopStarted then return false end
    LoopStarted = true

    CreateThread(function()
        while LoopStarted do
            local playerPed = PlayerPedId()
            if playerPed == -1 then
                Wait(Config.UPDATE_RATE)
                goto continue
            end

            local playerCoords = GetEntityCoords(playerPed)
            local playerSpeed = GetEntitySpeed(playerPed)
            local nearbyCells = Point.GetNearbyCells(playerCoords)

            -- Process points in nearby cells
            for _, cellKey in ipairs(nearbyCells) do
                if GridCells[cellKey] then
                    for _, point in pairs(GridCells[cellKey].points) do
                        if point.isEntity then
                            local oldCellKey = point.cellKey
                            point.coords = GetEntityCoords(point.target)
                            point.cellKey = Point.GetCellKey(point.coords)
                            Point.UpdateInGrid(point, oldCellKey)
                        end
                        Point.ProcessPoint(point, playerCoords, playerSpeed)
                    end
                end
            end

            -- Process remaining inside points
            for id, point in pairs(insidePoints) do
                Point.ProcessPoint(point, playerCoords, playerSpeed)
            end

            local waitTime = Config.ADAPTIVE_WAIT and
                math.max(Config.MIN_WEIGHT, Config.MAX_WEIGHT - playerSpeed * 50) or
                Config.MAX_WEIGHT

            Wait(waitTime)
            ::continue::
        end
    end)
    return true
end

-- Utility functions
function Point.Get(id)
    return ActivePoints[id]
end

function Point.GetAll()
    return ActivePoints
end

function Point.CheckPointsInSameCell(point)
    if not point or not point.cellKey or not GridCells[point.cellKey] then
        return {}
    end

    local nearbyPoints = {}
    for id, otherPoint in pairs(GridCells[point.cellKey].points) do
        if id ~= point.id then
            local distance = calculateDistance(point.coords, otherPoint.coords)
            if distance < (point.distance + otherPoint.distance) then
                nearbyPoints[id] = otherPoint
            end
        end
    end

    return nearbyPoints
end

return Point
