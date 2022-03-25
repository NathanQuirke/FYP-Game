function love.load()
    love.window.setMode(1600, 920)

    anim8 = require "libraries/anim8/anim8"
    sti = require "libraries/STI/sti"
    cameraFile = require "libraries/hump/camera"

    Menu = require "menuScroll"
    state = "menu"
    testmenu = Menu.new()
    testmenu:addItem {
        name = "Start Game",
        action = function()
            state = "game"
        end
    }
    testmenu:addItem {
        name = "Options",
        action = function()
            --options screen
        end
    }
    testmenu:addItem {
        name = "Quit",
        action = function()
            love.event.quit()
        end
    }

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    sounds.music = love.audio.newSource("audio/Chasing-Villains.mp3", "stream")
    sounds.intro = love.audio.newSource("audio/intromusic.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.5)
    sounds.intro:setLooping(true)
    sounds.intro:setVolume(0.1)

    sprites = {}
    sprites.playerSheet = love.graphics.newImage("sprites/playerSheet.png")
    sprites.enemySheet = love.graphics.newImage("sprites/enemySheet.png")
    sprites.hills = love.graphics.newImage("sprites/world3.png")
    sprites.forest = love.graphics.newImage("sprites/world2.png")

    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid("1-15", 1), 0.08)
    animations.jump = anim8.newAnimation(grid("1-7", 2), 0.08)
    animations.run = anim8.newAnimation(grid("1-15", 3), 0.08)
    animations.enemy = anim8.newAnimation(enemyGrid("1-2", 1), 0.05)

    wf = require "libraries/windfield/windfield"
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("Platform")
    world:addCollisionClass("Player")
    world:addCollisionClass("DeathBounds")

    require("player")
    require("enemies")

    deathBounds = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "DeathBounds"})
    deathBounds:setType("static")

    platforms = {}

    flagX = 0
    flagY = 0
    currentLevel = "level1"
    require("levelText")
    loadMap(currentLevel)
end

function love.update(dt)
    testmenu:update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight() / 2)

    local colliders = world:queryCircleArea(flagX, flagY, 10, {"Player"})
    if #colliders > 0 then
        if currentLevel == "level1" then
            loadMap("level2")
        elseif currentLevel == "level2" then
            loadMap("level3")
        elseif currentLevel == "level3" then
            loadMap("level4")
        end
    end
end

function love.draw()
    if state == "menu" then
        testmenu:draw(10, 10)
        sounds.intro:play()
    elseif state == "game" then
        if (currentLevel == "level1" or currentLevel == "level2") then
            love.graphics.draw(sprites.hills, 0, 0, nil, 3.15, 3.6)
        end
        if (currentLevel == "level3" or currentLevel == "level4") then
            love.graphics.draw(sprites.forest, 0, 0, nil, 1.74, 1.2)
        end
        if (currentLevel == "level5" or currentLevel == "level6") then
            love.graphics.draw(sprites.forest, 0, 0, nil, 1.74, 1.2)
        end
        sounds.intro:stop()
        cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
        drawPlayer()
        --world:draw()
        drawEnemies()
        cam:detach()
    --insert hud
        levelText()
    end
end

function love.keypressed(key)
    testmenu:keypressed(key)
    if state == "game" then
        if key == "q" then
            love.event.quit()
        end
        sounds.music:play()
        if key == "up" then
            if player.grounded then
                player:applyLinearImpulse(0, -5000)
                sounds.jump:play()
            end
        end
    end
    if key == "r" then
        if currentLevel == "level1" then
            loadMap("level2")
        elseif currentLevel == "level2" then
            loadMap("level3")
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {"Platform", "DeathBounds"})
        for i, c in ipairs(colliders) do
            c:destroy()
        end
    end
end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType("static")
        table.insert(platforms, platform)
    end
end

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end

function loadMap(mapName)
    currentLevel = mapName
    destroyAll()
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Start"].objects) do
        playerStartX = obj.x
        playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)
    for i, obj in pairs(gameMap.layers["Platforms lvl"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end
