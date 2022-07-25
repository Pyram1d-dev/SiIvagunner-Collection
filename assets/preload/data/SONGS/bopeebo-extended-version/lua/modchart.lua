function beatHit(beat)
    if difficulty == 0 or difficulty == 3 then return end
    if beat >= 96 and beat < 128 then
        camHUD.zoom = 1.015
        camGame.zoom = 0.925
    end
    if beat >= 64 and beat < 96 then
        camHUD.zoom = 1.02
        camGame.zoom = 0.93
    end
end