function stepHit(step)
    if step == 66 then
        boyfriend:playAnim("pogstart", true)
    end
    if step == 72 then
        boyfriend:playAnim("poglook", true)
    end
    if step == 78 then
        boyfriend:playAnim("pogpoint", true)
    end
    if step == 120 then
        Game:setZoom(1.05, true)
        Game:setCamFollow(530, 380, true)
    end
    if step == 121 then
        Game:setZoom(1.1, true)
    end
    if step == 124 then
        Game:setZoom(1.15, true)
        Game:setCamFollow(925, 380, true)
    end
    if step == 125 then
        Game:setZoom(1.2, true)
    end
    if step == 128 then
        Game.camZoom = 1
        Game:setCamFollow(670, 430)
    end
    if step == 280 then
        Game.camZoom = 1.25
    end
    if step == 288 then
        Game.camZoom = 1
        da_bg.visible = false
    end
    if step == 416 then
        Game.camZoom = 1.1
    end
    if step == 464 then
        Game.camZoom = 1.25
    end
    if step == 480 then
        Game.camZoom = 1
    end
    if step == 610 then
        ratsAss.visible = true
        dad:playAnim("bruh", true);
        camHUD.visible = false
        Game:setCamFollow(530, 380)
        camGame:tweenZoom(2.8, 7.8, true, "sineInOut")
    end
end

function inBetween(num1,num2)
    return (curBeat >= num1 and curBeat < num2)
end

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

function beatHit(beat)
    if beat == 72 then
        Game:setZoomInterval(1, 0.04, 0.03);
    end
    if beat == 104 then
        Game:setZoomInterval();
    end
    if beat == 120 then
        Game:setZoomInterval(1, 0.03, 0.01);
    end
    if beat == 136 then
        Game:setZoomInterval(0);
    end
end

function start()
    Stage:getSprite("da_bg")
    Stage:getSprite("ratsAss")
end