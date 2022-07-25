function start(song) -- do nothing

end

function update(elapsed)
    if difficulty == 2 and curStep > 400 then
        local currentBeat = (songPos / 1000)*(bpm/60)
		for i=0,7 do
            local receptor = _G['receptor_'..i]
			receptor.x = receptor.defaultX + 32 * math.sin((currentBeat + i*0.25) * math.pi)
			receptor.y = receptor.defaultY + 32 * math.cos((currentBeat + i*0.25) * math.pi)
		end
    end
end

function beatHit(beat) -- do nothing

end

function stepHit(step) -- do nothing

end

function playerTwoTurn()
    camGame:tweenZoom(1.3, (crochet * 4) / 1000)
end

function playerOneTurn()
    camGame:tweenZoom(1, (crochet * 4) / 1000)
end