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
    setCamZoom(cameraZoom+zoom[1])
    setHudZoom(hudZoom+zoom[2])
end

function inBetween(num1,num2)
    return (curBeat >= num1 and curBeat < num2)
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
        tweenCameraZoomOut(0.7,(60/bpm)*2)
    end
    if inBetween(456,488) then
        oomf(0.05,beat)
    end
end