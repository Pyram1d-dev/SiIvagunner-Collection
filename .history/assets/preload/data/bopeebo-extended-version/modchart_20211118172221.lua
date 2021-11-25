function beatHit(beat)
    if difficulty == 3 then return end
    if beat % 8 == 7 and beat < 64 then
        playActorAnimation('boyfriend','hey',true)
    end
    if difficulty == 0 then return end
    if beat >= 96 and beat < 128 then
        setHudZoom(1.025)
        setCamZoom(0.925)
    elseif beat >= 64 then
        setHudZoom(1.04)
        setCamZoom(0.94)
    end
end

function update(elapsed)
    if difficulty == 2 then
        if curBeat >= 96 and curBeat < 128 then
            for i=0,7 do
                setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((curBeat) * math.pi), i)
                setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((curBeat + i*0.25) * math.pi), i)
            end
        elseif curBeat >= 128 then
            for i=0,7 do
                local offsetX = (_G['defaultStrum'..i..'X']-getActorX(i))/20
                local offsetY = (_G['defaultStrum'..i..'Y']-getActorY(i))/20
                setActorX(getActorX(i) + math.ceil(math.abs(offsetX))*(offsetX < 0 and -1 or 1), i)
                setActorY(getActorY(i) + math.ceil(math.abs(offsetY))*(offsetY < 0 and -1 or 1), i)
            end
        end
    end
end