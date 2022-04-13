function love.load()
    love.window.setMode(1200, 600)

    anim8 = require "libraries/anim8/anim8"
    sti = require "libraries/STI/sti"
    cameraFile = require "libraries/hump/camera"

    InMenu = true
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
    sounds.music:setVolume(0.3)
    sounds.intro:setLooping(true)
    sounds.intro:setVolume(0.2)

    sprites = {}
    sprites.playerSheet = love.graphics.newImage("sprites/playerSheet2.png")
    sprites.enemySheet = love.graphics.newImage("sprites/enemy.png")
    sprites.hills = love.graphics.newImage("sprites/world3.png")
    sprites.forest = love.graphics.newImage("sprites/world2.png")
    sprites.menu = love.graphics.newImage("sprites/menu.png")
    sprites.controls = love.graphics.newImage("sprites/controls.png")
    sprites.jungle = love.graphics.newImage("sprites/jungle.png")
    sprites.city = love.graphics.newImage("sprites/city.png")
    sprites.spooky = love.graphics.newImage("sprites/spooky.png")
    sprites.logo = love.graphics.newImage("sprites/logo.png")
    sprites.endScreen = love.graphics.newImage("sprites/hills.png")
    sprites.title = love.graphics.newImage("sprites/title.png")
    sprites.level11 = love.graphics.newImage("sprites/level11.png")


    local grid = anim8.newGrid(100, 200, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(1500, 1500, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid("1-1", 1), 0.08)
    animations.run = anim8.newAnimation(grid("1-15", 2), 0.08)
    animations.jump = anim8.newAnimation(grid("1-9", 3), 0.08)
    animations.enemy = anim8.newAnimation(enemyGrid("1-1", 1), 0.05)

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
        elseif currentLevel == "level4" then
            loadMap("level5")
        elseif currentLevel == "level5" then
            loadMap("level6")
        elseif currentLevel == "level6" then
            loadMap("level7")
        elseif currentLevel == "level7" then
            loadMap("level8")
        elseif currentLevel == "level8" then
            loadMap("level9")
        elseif currentLevel == "level9" then
            loadMap("level10")
        else state = "endScreen"
        end
    end
end

function love.draw()
    if state == "menu" then
        love.graphics.draw(sprites.menu, 0, 0, nil, 1.27, 1.28)
        love.graphics.draw(sprites.controls, 1203, 541, nil, 0.4, 0.4)
        title = love.graphics.newFont(110)
        love.graphics.draw(sprites.title, 30, 20, nil, 0.7, 1)
        if InMenu == true then
        testmenu:draw(10, 10)
        end
        sounds.intro:play()
    elseif state == "game" then
        if (currentLevel == "level1") then
            love.graphics.draw(sprites.hills, 0, 0, nil, 2.4, 2.35)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level2") then
            love.graphics.draw(sprites.hills, 0, 0, nil, 2.4, 2.35)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level3") then
            love.graphics.draw(sprites.forest, 0, 0, nil, 1.5, 0.76)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level4") then
            love.graphics.draw(sprites.forest, 0, 0, nil, 1.5, 0.76)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level5") then
            love.graphics.draw(sprites.jungle, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level6") then
            love.graphics.draw(sprites.jungle, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level7") then
            love.graphics.draw(sprites.city, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level8") then
            love.graphics.draw(sprites.city, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level9") then
            love.graphics.draw(sprites.spooky, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        if (currentLevel == "level10") then
            love.graphics.draw(sprites.spooky, 0, 0, nil, 1.5, 1)
            love.graphics.draw(sprites.level11, 20, 20, nil, 0.4, 0.4)
        end
        
        InMenu = false
        sounds.intro:stop()
        cam:attach()
        gameMap:drawLayer(gameMap.layers["Tile Layer 2"])
        drawPlayer()
        --world:draw()
        drawEnemies()
        cam:detach()
        --insert hud
    end
    if state == "endScreen" then
        love.graphics.draw(sprites.endScreen, 0, 0, nil, 1.5, 1)
        title = love.graphics.newFont(150)
        title2 = love.graphics.newFont(80)
        title3 = love.graphics.newFont(50)
        love.graphics.print("Grass Runner", title, 100, 70)
        love.graphics.print("created by Nathan Quirke", title2, 90, 300)
        love.graphics.draw(sprites.logo, 800, 400, nil, 1.5, 1.3)
        love.graphics.print("Made with LÖVE2D", title3, 300, 440)
        
        sounds.music:stop()

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
                player:applyLinearImpulse(0, -4500)
                sounds.jump:play()
            end
        end
    end
    if key == "r" then
        if currentLevel == "level1" then
            loadMap("level2")
        elseif currentLevel == "level2" then
            loadMap("level3")
        elseif currentLevel == "level3" then
            loadMap("level4")
        elseif currentLevel == "level4" then
            loadMap("level5")
        elseif currentLevel == "level5" then
            loadMap("level6")
        elseif currentLevel == "level6" then
            loadMap("level7")
        elseif currentLevel == "level7" then
            loadMap("level8")
        elseif currentLevel == "level8" then
            loadMap("level9")
        elseif currentLevel == "level9" then
            loadMap("level10")
        else state = "endScreen"
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
