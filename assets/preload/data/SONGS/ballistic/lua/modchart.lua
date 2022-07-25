function oomf(zoom,beat,mod)
    if mod and not (beat%(mod.mod) == mod.value) then return end
    local zoom = zoom
    if type(zoom) ~= "table" then
        zoom = {zoom,zoom}
    end
    if (beat % 4 == 0) then
        zoom[1] = zoom[1] - 0.015
        zoom[2] = zoom[2] - 0.03
    end
    camGame.zoom = camGame.zoom + zoom[1]
    camHUD.zoom = camHUD.zoom + zoom[2]
end

function inBetween(num1,num2)
    return (curBeat >= num1 and curBeat < num2)
end

function beatsToSeconds(num)
    return num * 4 * crochet / 1000
end

function beatHit(beat)
    if difficulty == 0 then return end
    if inBetween(72,128) or inBetween(200,376) then
        oomf(0.03,beat,{mod = 2,value = 0})
    end
    if inBetween(136,200) then
        oomf({0.04,0.03},beat,{mod = 2,value = 0})
    end
    if inBetween(392,454) then
        oomf(0.04,beat)
    end
    if beat == 454 then
        camGame:tweenZoom(0.7, (60/bpm)*2, false, "cubeOut")
    end
    if beat == 456 then
        funneEffect:tweenAlpha(1, beatsToSeconds(8))
    end
    if beat == 488 then
        funneEffect:tweenAlpha(0, beatsToSeconds(4))
    end
    if inBetween(456,488) then
        oomf(0.05,beat)
    end
end

function start()
    Stage:getSprite("funneEffect")
end