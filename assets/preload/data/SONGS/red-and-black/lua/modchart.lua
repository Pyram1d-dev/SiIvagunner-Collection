local posY = 0

function start(song) -- HAACHAMA CHAMAAAAAAAAAA--
	print('HAACHAMA CHAMAAAAAAAAAA--')
end

function setDefault(id)
	local receptor = _G['receptor_'..id]
	receptor.defaultX = receptor.x
end

function tweenReceptorOffsetY(offset, i, ease)
	local receptor = _G['receptor_'..i]
	receptor:tweenPos(receptor.x, receptor.defaultY + offset, crochet * 8 / 1000, ease)
end

function jebusSlideUpScroll(beat)
	if beat % 8 == 0 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenReceptorOffsetY(100, i, "cubeOut")
			end
		end
	elseif beat % 8 == 2 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenReceptorOffsetY(0, i, "cubeIn")
			end
		end
	elseif beat % 8 == 4 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenReceptorOffsetY(100, i, "cubeOut")
			end
		end
	elseif beat % 8 == 6 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenReceptorOffsetY(0, i, "cubeIn")
			end
		end
	end
end

function jebusSlideDownScroll(beat)
	if beat % 8 == 0 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenReceptorOffsetY(-100, i, "cubeOut")
			end
		end
	elseif beat % 8 == 2 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenReceptorOffsetY(0, i, "cubeIn")
			end
		end
	elseif beat % 8 == 4 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenReceptorOffsetY(-100, i, "cubeOut")
			end
		end
	elseif beat % 8 == 6 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenReceptorOffsetY(0, i, "cubeIn")
			end
		end
	end
end

function tweenReceptorOffsetX(offset, i, ease)
	local receptor = _G['receptor_'..i]
	receptor:tweenPos(receptor.defaultX + offset, receptor.y, 0.1, ease)
end

function jebusSlideXAxis(beat)
    if beat % 4 == 0 then
        for i=0,7 do
			tweenReceptorOffsetX(-50, i, "cubeOut")
        end
    elseif beat % 4 == 1 then
        for i=0,7 do
			tweenReceptorOffsetX(0, i, "cubeIn")
        end
    elseif beat % 4 == 2 then
        for i=0,7 do
            tweenReceptorOffsetX(50, i, "cubeOut")
        end
    elseif beat % 4 == 3 then
        for i=0,7 do
			tweenReceptorOffsetX(0, i, "cubeIn")
        end
    end
end

function update(elapsed)

	local currentBeatHalf = (songPos / 1000)*((bpm/2)/60)
	local currentBeat = (songPos / 1000)*(bpm/60)

	if swayCam then
		camHUD.angle = 1 * math.sin(currentBeat / 1.5)
		camGame.angle = -1 * math.sin(currentBeat / 1.5)
	end
	
	if spookyArrows then
		for i=0,7 do
			local receptor = _G['receptor_'..i]
			receptor.y = receptor_0.defaultY + 10 * math.cos((currentBeat + i*0.25) * math.pi)
		end
	end
	
	if cosWave then
		for i=0,7 do
			local receptor = _G['receptor_'..i]
			receptor.y = receptor.defaultY + 32 * math.cos((currentBeat + i) * math.pi)
		end
	end

	if curStep == 384 or curStep == 672 then -- reset position
		for i=0,7 do
			local receptor = _G['receptor_'..i]
			receptor:tweenPos(receptor.x, posY, 0.25, "cubeOut");
		end
	end

	if swaySlow then --starts slow swaying
		for i=0,7 do
			local receptor = _G['receptor_'..i]
			receptor.x = receptor.defaultX + 32 * math.sin(currentBeatHalf * math.pi), i
		end
	end

	if HAACHAMACHAMA then -- HAACHAMA CHAMAAAAAAAAAAAAAAAAAAAAAAAAAA
		showOnlyStrums = true
		strumLine1Visible = false
		strumLine2Visible = false
	else
		showOnlyStrums = false
		strumLine1Visible = true
		strumLine2Visible = true
	end

end

function beatHit(beat) 
	if curStep >= 448 and curStep < 576 then -- spins arrows at this part
		if beat % 8 == 0 then
			for i = 0, 7 do
				local receptor = _G['receptor_'..i]
				receptor:tweenAngle(receptor.angle + 360, 0.11)
			end
		elseif beat % 8 == 4 then
			for i = 0, 7 do
				local receptor = _G['receptor_'..i]
				receptor:tweenAngle(receptor.angle - 360, 0.11)
			end
		end
	end

	if (curStep >= 384 and curStep < 448) or (curStep >= 672 and curStep < 704) then -- starts doing the jebus
		if posY <= 100 then
			jebusSlideUpScroll(beat)
		else
			jebusSlideDownScroll(beat)
		end
	end

    if jebusSlideXBegin then --jebus slide on x axis on beat
        jebusSlideXAxis(beat)
    end

end

function stepHit(step) -- just read comments

	if step == 1 then -- sets position for Y for cases of up and down scroll
		posY = receptor_0.y
	end

	if step == 190 then -- spin strum forward
		for i = 0, 7 do
			local receptor = _G['receptor_'..i]
			receptor:tweenAngle(receptor.angle + 360, 0.15)
		end
	end

	if step == 254 then -- spin strum backward
		for i = 0, 7 do
			local receptor = _G['receptor_'..i]
			receptor:tweenAngle(receptor.angle - 360, 0.15)
		end
	end

	if step == 256 then
		cosWave = true
	end

	if step == 384 then
		cosWave = false
	end
	
	if step == 448 then
		swayCam = true
		spookyArrows = true
	end  

	if step == 576 then
		swaySlow = true
	end

	if step == 672 then
		swaySlow = false
	end

    if step == 704 then
        jebusSlideXBegin = true
    end
	
	if step == 768 then
		jebusSlideXBegin = false
		HAACHAMACHAMA = true
	end

	if step == 792 then
		HAACHAMACHAMA = false
	end

	if step == 128 then
		camGame:tweenZoom(0.7, 1, true, "cubeOut")
	end

	if step == 256 then
		camGame:tweenZoom(1.05, 1, true, "cubeOut")
	end

	if step == 384 then
		camGame:tweenZoom(0.7, 1, true, "cubeOut")
	end

	if step == 448 then
		camGame:tweenZoom(1.05, 1, true, "cubeOut")
	end

	if step == 768 then
		camGame:tweenZoom(2, 1, true, "cubeOut")
	end
end