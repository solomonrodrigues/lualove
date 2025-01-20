-- main.lua

local gridSize = 5
local cellSize = 50
local grid = {}
local player = { x = 1, y = 1, drawX = 1, drawY = 1, speed = 5 }
local warningCells = {}
local attackCells = {}
local gameOver = false
local timer = 0
local warningDuration = 1.5
local attackDuration = 1.0
local phase = "idle" -- can be "warning" or "attack"
local minWarningCells = 12
local maxWarningCells = 16

-- Initialize grid
function love.load()
    love.window.setTitle("Grid Avoidance Game")
    love.window.setMode(gridSize * cellSize, gridSize * cellSize)
    for x = 1, gridSize do
        grid[x] = {}
        for y = 1, gridSize do
            grid[x][y] = false -- Grid cells start inactive
        end
    end
    pickWarningCells()
end

-- Pick random cells to light up
function pickWarningCells()
    warningCells = {}
    for i = 1, math.random(minWarningCells, maxWarningCells) do
        table.insert(warningCells, { x = math.random(1, gridSize), y = math.random(1, gridSize) })
    end
    phase = "warning"
    timer = 0
end

function pickAttackCells()
    attackCells = warningCells
    warningCells = {}
    phase = "attack"
    timer = 0
end

-- Update game logic
function love.update(dt)
    if gameOver then return end

    -- Update the timer and phases
    timer = timer + dt

    if phase == "warning" and timer > warningDuration then
        pickAttackCells()
    elseif phase == "attack" and timer > attackDuration then
        for _, cell in ipairs(attackCells) do
            if player.x == cell.x and player.y == cell.y then
                gameOver = true
            end
        end
        pickWarningCells()
    end

    -- Animate player movement
    local targetX = (player.x - 1) * cellSize
    local targetY = (player.y - 1) * cellSize
    player.drawX = player.drawX + (targetX - player.drawX) * math.min(dt * player.speed, 1)
    player.drawY = player.drawY + (targetY - player.drawY) * math.min(dt * player.speed, 1)
end

-- Draw the game grid
function love.draw()
    for x = 1, gridSize do
        for y = 1, gridSize do
            local cellX = (x - 1) * cellSize
            local cellY = (y - 1) * cellSize
            local color = { 0.8, 0.8, 0.8 }

            if isInList(warningCells, x, y) then
                color = { 1, 1, 0 }
            elseif isInList(attackCells, x, y) then
                color = { 1, 0, 0 }
            end

            love.graphics.setColor(color)
            love.graphics.rectangle("fill", cellX, cellY, cellSize, cellSize)
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", cellX, cellY, cellSize, cellSize)
        end
    end

    -- Draw the player as a smaller square
    local playerSize = cellSize * 0.6
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", player.drawX + (cellSize - playerSize) / 2, player.drawY + (cellSize - playerSize) / 2, playerSize, playerSize)

    if gameOver then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Game Over", 0, (gridSize * cellSize) / 2 - 10, gridSize * cellSize, "center")
    end
end

-- Handle player input
function love.keypressed(key)
    if gameOver then return end

    if key == "up" and player.y > 1 then
        player.y = player.y - 1
    elseif key == "down" and player.y < gridSize then
        player.y = player.y + 1
    elseif key == "left" and player.x > 1 then
        player.x = player.x - 1
    elseif key == "right" and player.x < gridSize then
        player.x = player.x + 1
    end
end

-- Helper function to check if a cell is in a list
function isInList(list, x, y)
    for _, cell in ipairs(list) do
        if cell.x == x and cell.y == y then
            return true
        end
    end
    return false
end
