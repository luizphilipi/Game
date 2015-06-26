local Enemy = {}

function createEnemy(x, y)
    local enemy = Collider:addRectangle(x, y, 30, 30)
    Collider:addToGroup('enemies', enemy)
    enemy.width = 30
    enemy.height = 30
    enemy.maxLife = 5000
    enemy.life = 5000
    enemy.name = 'enemy'
    enemy.xp = 50
    enemy.speed = 100
    return enemy
end

function createRangedEnemy(x,y)
    local enemy = Collider:addPolygon(x,y-15,x+15,y, x-15,y)
    Collider:addToGroup('enemies', enemy)
    enemy.width = 30
    enemy.height = 15
    enemy.maxLife = 5000
    enemy.life = 5000
    enemy.name = 'enemy'
    enemy.xp = 50
    enemy.speed = 100
    enemy.cron = cron.every(1,enemyShot,enemy)
    return enemy
end

function enemyShot(enemy)
    local x,y = enemy:center()
    local xH,yH = hero:center()

    local dx = x - xH
    local dy = y - yH
    if math.sqrt ( dx * dx + dy * dy ) < 500 then
        local shot = Collider:addCircle(x,y, 3)
        Collider:addToGroup('shots', shot)
        Collider:addToGroup('enemies', shot)
        shot.name = 'shot'
        shot.velocity = 400
        shot.maxDistance = 500
        shot.initialpos = {}
        shot.initialpos.x = x
        shot.initialpos.y = y
        shot.damage = 50

        local angle = math.atan2((yH - y), (xH - x))

        shot.dx = 400 * math.cos(angle)
        shot.dy = 400 * math.sin(angle)

        table.insert(hero.shots,shot)
    end
end

function moveEnemy(self, dt)
    local x,y = self:center()
    local xH,yH = hero:center()
    local dx = xH - x
    local dy = yH - y
    local distance = math.sqrt(dx*dx+dy*dy)
    self:move(((dx / distance * self.speed) * dt), ((dy / distance * self.speed) * dt))
end

function generateEnemy(portal)
    local x, y = portal:center()
    table.insert(enemies, createRangedEnemy(x,y))
    portal.gen = portal.gen + 1
    if portal.gen <= portal.max then
        portal.cron = cron.after(portal.interval, generateEnemy, portal)
    end
end

function newPortal(x,y,w,h,interval, maxGen)
    local portal = Collider:addRectangle(x,y,w,h)
    Collider:setGhost(portal)
    portal.interval = interval
    portal.max = maxGen
    portal.gen = 0
    portal.cron = cron.after(interval, generateEnemy, portal)
    return portal
end
