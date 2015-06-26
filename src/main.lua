HC = require 'hardoncollider'
cron = require 'lib.cron.cron'
Camera = require "lib.hump.camera"

local thispath = select('1', ...):match(".+%.") or ""
require(thispath .. 'shots')
require(thispath .. 'enemy')
require(thispath .. 'collision')

function love.load()
    love.window.setMode(0, 0, {vsync=false, fullscreen=false})
    love.keyboard.setKeyRepeat(false)
    count = 0
    Collider = HC(100, on_collide, on_stop)

    width, height = love.graphics.getDimensions()
    hero        = Collider:addCircle(width/2, height/2, 10)

    Collider:setGhost(hero)

    hero.speed = 300
    hero.name = 'hero'
    hero.critical = 0.3
    hero.shots = {}

    enemies = {}
    portals = {}

    table.insert(portals,newPortal(10, height/2-50, 20,100,1,20))
    table.insert(portals,newPortal(width-30, height/2-50, 20,100,1,20))

    cam = Camera(hero:center())
end

function love.update(dt)
    if love.keyboard.isDown("a") then
        hero:move(-(hero.speed*dt), 0)
    elseif love.keyboard.isDown("d") then
        hero:move((hero.speed*dt), 0)
    end

    if love.keyboard.isDown("w") then
        hero:move(0, -(hero.speed*dt))
    elseif love.keyboard.isDown("s") then
        hero:move(0, hero.speed*dt)
    end

    local x,y = hero:center()
    if love.keyboard.isDown("left") then
        shoot(x,y,x-50,y)
    elseif love.keyboard.isDown("right") then
        shoot(x,y,x+50,y)
    elseif love.keyboard.isDown("up") then
        shoot(x,y,x,y-50)
    elseif love.keyboard.isDown("down") then
        shoot(x,y,x,y+50)
    end

    for i,shot in ipairs(hero.shots) do
        moveShot(shot, dt)
        validateShot(shot, i)
    end

    for i,enemy in ipairs(enemies) do
        moveEnemy(enemy,dt)
        if enemy.cron then
            enemy.cron:update(dt)
        end
    end

    for i,portal in ipairs(portals) do
        portal.cron:update(dt)
    end
    Collider:update(dt)
    cam:lookAt(hero:center())
end

function love.draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS()), 10, 10)
    cam:draw(draw_world)
end

function draw_world()
    love.graphics.setColor(0,255,255,255)
    hero:draw('fill', 16)
    --    leftPaddle:draw('fill')
    --    rightPaddle:draw('fill')
    for i,portal in ipairs(portals) do
        portal:draw('fill')
    end
    love.graphics.setColor(255,255,255,255)
    for i,shot in ipairs(hero.shots) do
        shot:draw('fill')
    end
    for i,enemy in ipairs(enemies) do
        local x, y = enemy:center()

        local life = ''
        local v = enemy.life
        if v <= 999 then
            life = v
        elseif v <= 999999 then
            life = v/1000 .. 'k'
        else
            life = v/1000000 .. 'kk'
        end

        love.graphics.print(life, x-15, y-35)
        love.graphics.setColor(255,0,0,255)
        love.graphics.rectangle("fill", x-15, y-20, enemy.width, 3)
        love.graphics.setColor(0,255,0,255)
        love.graphics.rectangle("fill", x-15, y-20, enemy.width * (enemy.life / enemy.maxLife), 3)
        love.graphics.setColor(0,255,255,255)
        enemy:draw('fill')
    end
end
