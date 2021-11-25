function beatHit(beat)
    if difficulty == 0 then return end
    if (beat >= 128 and beat < 160) or (beat >= 164 and beat < 192) then
        setHudZoom(1.025)
        setCamZoom(0.925)
    end
end