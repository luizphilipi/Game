function createShot(shotType, x, y, sentido)
    local shots = {}
    if shotType == 'single' then
        local n = love.math.random()
        local shot
        if n < hero.critical then
            shot = Collider:addCircle(x,y, 6)
            shot.damage = 50 * 2
        else
            shot = Collider:addCircle(x,y, 3)
            shot.damage = 50
        end
        shot:setRotation(math.pi * sentido)
        Collider:addToGroup('shots', shot)
        shot.name = 'shot'
        shot.velocity = 400
        shot.sentido = sentido
        shot.maxDistance = 500
        shot.initialpos = {}
        shot.initialpos.x = x
        shot.initialpos.y = y
        table.insert(shots,shot)
        return shots
    elseif shotType == 'triple' then
        for i=-1, 1 do
            local shot
            if (sentido > 1/4 and sentido < 3/4) or (sentido > 5/4 and sentido < 7/4) then
                shot = Collider:addRectangle(x +i*5,y, 6,3)
            else
                shot = Collider:addRectangle(x,y + i*5, 6,3)
            end
            Collider:addToGroup('shots', shot)
            shot:setRotation(math.pi * sentido)
            shot.damage = 50
            shot.name = 'shot'
            shot.velocity = 400
            shot.sentido = sentido
            table.insert(shots,shot)
        end
        return shots
    end
end

function moveShot(self, dt)
    if self.sentido == 0 then
        self:move(dt*self.velocity, 0)
    elseif self.sentido == 1 then
        self:move(-dt*self.velocity, 0)
    elseif self.sentido == 1/2 then
        self:move(0, -dt*self.velocity)
    elseif self.sentido == 3/2 then
        self:move(0, dt*self.velocity)
    end
end

function validateShot(self, i)
    -- tiro saiu da tela...
    local x,y = self:center()
    local x1,y1 = self.initialpos.x, self.initialpos.y

    local distance = math.sqrt(math.pow(x-x1,2)+math.pow(y-y1,2))
    if distance > self.maxDistance then
        table.remove(hero.shots,i)
        Collider:remove(shot)
    end
end

local shotCount = 0

function shoot(sentido)
    if shotCount == 50 then
        local x,y = hero:center()
        shots = createShot('single', x, y, sentido)
        for i,shot in ipairs(shots) do
            table.insert(hero.shots, shot)
        end
        shotCount = 0
    end
    shotCount = shotCount + 1
end
