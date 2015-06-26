function on_collide(dt, shape_a, shape_b)
    -- determine which shape is the ball and which is not
    local shot
    local enemy
    if shape_a.name == 'shot' then
        enemy = shape_b
        shot = shape_a
    else
        enemy = shape_a
        shot = shape_b
    end
    
    enemy.life = enemy.life - shot.damage
    if enemy.life <= 0 then
        Collider:remove(enemy)
        table.remove(enemies, AnIndexOf(enemies,enemy))
    end

--    Collider:remove(shot)
--    table.remove(hero.shots, AnIndexOf(hero.shots,shot))
end

function AnIndexOf(t,val)
    for k,v in ipairs(t) do
        if v == val then return k end
    end
end
