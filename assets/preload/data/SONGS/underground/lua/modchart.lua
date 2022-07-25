local coolGuys = {"julian-neon", "bf-neon", "gf-whitty-neon"}
local normalGuys = {"julian-wacky", "bf", "gf-whitty-new"}

function coolMode(on)
    local chars = on and coolGuys or normalGuys
    dad:changeCharacter(chars[1], dad.x, dad.y)
    boyfriend:changeCharacter(chars[2], boyfriend.x, boyfriend.y)
    gf:changeCharacter(chars[3], gf.x, gf.y)
    stagefront.visible = not on
    stageback.visible = not on
end

local stepEvents = {
    [192] = function()
        dad:changeCharacter("julian-swag", dad.x, dad.y)
    end,
    [864] = function()
        Game.camZoom = 1.5
    end,
    [893] = function()
        jackettt.visible = true
        jackettt:tweenPos(2000, jackettt.y, 0.15)
    end,
    [895] = function()
        Game.camZoom = 0.8
        coolMode(true)
        dad.y = dad.y + 150
    end,
    [1266] = function()
        Game.camZoom = 0.6
    end,
    [1278] = function()
        camGame:tweenZoom(0.7, crochet * 2 / 1000, true, "cubeIn")
    end,
    [1280] = function()
        coolMode(false)
    end,
    [1394] = function()
        Game.camZoom = 0.6
    end,
    [1406] = function()
        camGame:tweenZoom(0.7, crochet * 2 / 1000, true, "cubeIn")
    end,
    [1408] = function()
        coolMode(true)
    end,
    [1600] = function()
        Game.camZoom = 0.65
        coolMode(false)
    end,
}

function stepHit(step)
    if stepEvents[step] ~= nil then
        stepEvents[step]()
    end
end

local bump = {
    [12] = {0.02, 0.03, 3};
    [15] = {0.04, 0.03};
    [32] = {0.04, 0.03, 3};
}

local zoomEvents = {
    [16] = {0.04, 0.03, 4};
    [16] = {0.04, 0.03, 4};
}

local loop = nil;
function beatHit(beat)
    if zoomEvents[beat] ~= nil then
        Game:setZoomInterval(zoomEvents[beat][3], zoomEvents[beat][1], zoomEvents[beat][2]);
    end
    if bump[beat] ~= nil then
        if bump[beat][3] ~= nil then
            loop = bump[beat];
        else
            camGame.zoom = camGame.zoom + bump[beat][1];
            camHUD.zoom = camHUD.zoom + bump[beat][2];
        end
    end
    if loop ~= nil then
        camGame.zoom = camGame.zoom + loop[1];
        camHUD.zoom = camHUD.zoom + loop[2];
        loop[3] = loop[3] - 1;
        if loop[3] == 0 then
            loop = nil;
        end
    end
end

local toCache = {"julian-swag", "julian-wacky", "julian-neon", "gf-whitty-neon", "bf-neon"}

function start(song)
    for _, i in pairs(toCache) do
        Game:cacheCharacter(i)
    end
    Game.allowZooming = true;
    Stage:getSprite("jackettt");
    Stage:getSprite("stagefront");
    Stage:getSprite("stageback");
end