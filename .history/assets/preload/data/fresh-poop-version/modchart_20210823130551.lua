function beatHit(beat)
    if difficulty == 0 then return end
    if difficulty == 2 and beat >= 164 and beat < 192 then
        for i=0,7 do
            local adder = (i%2 == 0 and 20 or -20) * ((beat%2 == 0 and 1 or -1))
            setActorY(_G['defaultStrum'..i..'Y']+adder, i)

        end
    end
    if (beat >= 128 and beat < 160) or (beat >= 164 and beat < 192) then
        setHudZoom(1.025)
        setCamZoom(0.925)
    end
    if beat == 192 then
        for i=0,7 do
            setActorY(_G['defaultStrum'..i..'Y'], i)
        end
    end
end

function update(elapsed)
    if difficulty == 2 then
        if curBeat >= 164 and curBeat < 192 then
            for i=0,7 do
                local offset = (_G['defaultStrum'..i..'Y']-getActorY(i))/20
                setActorY(getActorY(i) + math.ceil(math.abs(offset))*(offset < 0 and -1 or 1), i)
            end
        end
    end
end