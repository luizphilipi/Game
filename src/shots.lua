function createShot(shotType, x, y, xDestino, yDestino)
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
        Collider:addToGroup('shots', shot)
        shot.name = 'shot'
        shot.maxDistance = 500
        shot.initialpos = {}
        shot.initialpos.x = x
        shot.initialpos.y = y

        local angle = math.atan2((yDestino - y), (xDestino - x))

        shot.dx = 500 * math.cos(angle)
        shot.dy = 500 * math.sin(angle)

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
    self:move(self.dx * dt, self.dy * dt)
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

function shoot(x,y,xD,yD)
    if shotCount == 50 then
        shots = createShot('single', x, y, xD,yD)
        for i,shot in ipairs(shots) do
            table.insert(hero.shots, shot)
        end
        shotCount = 0
    end
    shotCount = shotCount + 1
end
