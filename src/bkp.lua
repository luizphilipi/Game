HC = require 'hardoncollider'
local thispath = select('1', ...):match(".+%.") or ""
require(thispath .. 'shots')
require(thispath .. 'enemy')

function on_collide(dt, shape_a, shape_b)
    local shot
    local enemy
    if shape_a.name == 'enemy' then
        enemy = shape_a
        shot = shape_b
    else
        enemy = shape_b
        shot = shape_a
    end
    print('colisao')
    enemy.life = enemy.life - shot.damage
    Collider:remove(shot)
end

function love.load()
    Collider = HC(100, on_collide)

    bg = love.graphics.newImage("bg.png")
    heroSprite = love.graphics.newImage('invader.png')
    enemySprite = love.graphics.newImage('enemy.png')

    count = 0

    countNewEnemy = 0

    shotType = 0

    hero = Collider:addRectangle(300, 420, heroSprite:getWidth(), heroSprite:getHeight())
    Collider:setGhost(hero)
    hero.width = heroSprite:getWidth()
    hero.height = heroSprite:getHeight()
    hero.name = 'hero'
    hero.speed = 250
    hero.xp = 0
    hero.shots = {} -- holds our fired shots

    enemies = {}
end

function love.keypressed(key)
    if key == "return" then
        shotType = (shotType + 1) % 2
    end
end

function love.update(dt)
    countNewEnemy = countNewEnemy+1
    if(countNewEnemy == 50) then
        math.randomseed(os.time())
        local r = math.random(0,500)
        table.insert(enemies, createEnemy(r,0))
        countNewEnemy = 0
    end

    -- keyboard actions for our hero
    if love.keyboard.isDown("left") then
        hero:move(-(hero.speed*dt), 0)
    elseif love.keyboard.isDown("right") then
        hero:move((hero.speed*dt), 0)
    end

    if love.keyboard.isDown("up") then
        hero:move(0, -(hero.speed*dt))
    elseif love.keyboard.isDown("down") then
        hero:move(0, hero.speed*dt)
    end

    if love.keyboard.isDown(" ") then
        count = count + 1
        if(count == 5) then
            shoot()
            count = 0
        end
    end

    local remEnemy = {}
    local remShot = {}

    -- update the shots
    for i,shot in ipairs(hero.shots) do

        -- move them up up up
        shot:move(0, -dt*300)

        local x, y = shot:center()
    end

    -- remove the marked enemies
    --    for i,enemy in ipairs(remEnemy) do
    --        Collider:remove(enemy)
    --        table.remove(enemies, enemy)
    --    end

    --  for i,shot in ipairs(remShot) do
    --    if not shot then
    --      HC:remove(shot)
    --      table.remove(hero.shots, shot)
    --    end
    --  end

    -- update those evil enemies
    for i,enemy in ipairs(enemies) do
        -- let them fall down slowly
        enemy:move(0, dt*100)
    end

    Collider:update(dt)

    for i,enemy in ipairs(enemies) do
        if enemy.life <= 0 then
            table.remove(enemies, i)
            Collider:remove(enemy)
        end
    end
end

function love.draw()
    -- let's draw a background
--    love.graphics.setColor(255,255,255,255)
--    love.graphics.draw(bg)

    -- let's draw our hero
    love.graphics.setColor(255,255,0,255)
    --love.graphics.rectangle("fill", hero.x, hero.y, hero.width, hero.height)
    local x, y = hero:center()
    love.graphics.draw(heroSprite, x, y)

    -- let's draw our heros shots
--    love.graphics.setColor(255,255,255,255)
--    for i,shot in ipairs(hero.shots) do
--        local x, y = shot:center()
--        love.graphics.rectangle("fill", x, y, 4, 6)
--    end
    -- let's draw our enemies
    for i,enemy in ipairs(enemies) do
        local x, y = enemy:center()
        love.graphics.setColor(255,0,0,255)
        love.graphics.rectangle("fill", x, y - 5, enemy.width, 3)
        love.graphics.setColor(0,255,0,255)
        love.graphics.rectangle("fill", x, y - 5, enemy.width * (enemy.life / 100), 3)
        love.graphics.setColor(0,255,255,255)
        -- love.graphics.rectangle("fill", enemy.x, enemy.y, enemy.width, enemy.height)
        love.graphics.draw(enemySprite, x, y)
    end

    love.graphics.setColor(255,255,255,255)
    love.graphics.print("XP: " .. hero.xp)
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
end

function shoot()
    local x,y = hero:center()
    love.graphics.setColor(160,140,100,100)
    shot = createShot('single', x+hero.width/2, y)
    shot:draw('fill')
    table.insert(hero.shots, shot)
end