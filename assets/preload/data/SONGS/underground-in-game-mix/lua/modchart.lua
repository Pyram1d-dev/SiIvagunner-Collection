local coolGuys = {"julian-neon-joe", "bf-neon", "gf-whitty-neon"}
local normalGuys = {"julian-wacky-joe", "bf", "gf-whitty-new"}

function coolMode(on)
    local chars = on and coolGuys or normalGuys
    dad:changeCharacter(chars[1], dad.x, dad.y)
    boyfriend:changeCharacter(chars[2], boyfriend.x, boyfriend.y)
    gf:changeCharacter(chars[3], gf.x, gf.y)
    stagefront.visible = not on
    stageback.visible = not on
    if on then
        lawl:playAnim("stylechange", true)
        lawl.x = 1120 - 10
		lawl.y = 800 - 58/2
    else
        lawl:playAnim("idle", true)
        lawl.x = 1120
		lawl.y = 800
    end
end

local stepEvents = {
    [192] = function()
        dad:changeCharacter("julian-swag", dad.x, dad.y)
    end,
    [930] = function()
        Game.camZoom = 1.5
    end,
    [958] = function()
        jackettt.visible = true
        jackettt:tweenPos(2000, jackettt.y, 0.15)
    end,
    [960] = function()
        Game.camZoom = 0.8
        coolMode(true)
        dad.y = dad.y + 150
    end,
    [1216] = function()
        coolMode(false)
        Game.camZoom = 0.7
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

local toCache = {"julian-swag", "julian-wacky-joe", "julian-neon-joe", "gf-whitty-neon", "bf-neon"}

function start(song)
    for _, i in pairs(toCache) do
        Game:cacheCharacter(i)
    end
    Game:setZoomInterval(0);
    Stage:getSprite("jackettt");
    Stage:getSprite("stagefront");
    Stage:getSprite("stageback");
    Stage:getSprite("lawl");
end