function start()
    Game.allowZooming = false
    camGame.zoom = 1.05
end

function update(elapsed)
    if curBeat < 48 then
        Game.allowZooming = false
    end
end

function beatHit(beat)
    if beat == 48 then
        Game.allowZooming = true
    end
end