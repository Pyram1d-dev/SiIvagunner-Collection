local posY = 0

function start(song) -- HAACHAMA CHAMAAAAAAAAAA--
	print('HAACHAMA CHAMAAAAAAAAAA--')
end

function setDefault(id)
	_G['defaultStrum'..id..'X'] = getActorX(id)
end

function jebusSlideUpScroll()
	if curBeat % 8 == 0 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenPosYAngle(i, 150, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 2 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenPosYAngle(i, 50, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 4 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenPosYAngle(i, 150, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 6 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenPosYAngle(i, 50, getActorAngle(i), 0.285, done)
			end
		end
	else
		error("bro wtf are you doing with the beat????")
	end
end

function jebusSlideDownScroll()
	if curBeat % 8 == 0 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenPosYAngle(i, 455, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 2 then
		for i=0,7 do
			if i % 2 == 0 then
				tweenPosYAngle(i, 555, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 4 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenPosYAngle(i, 455, getActorAngle(i), 0.285, done)
			end
		end
	elseif curBeat % 8 == 6 then
		for i=0,7 do
			if i % 2 == 1 then
				tweenPosYAngle(i, 555, getActorAngle(i), 0.285, done)
			end
		end
	else
		error("bro wtf are you doing with the beat????")
	end
end

function jebusSlideXAxis()
    if curBeat % 4 == 0 then
        for i=0,7 do
            tweenPos(i, _G['defaultStrum'..i..'X'] - 50, getActorY(i), 0.1, done)
        end
    elseif curBeat % 4 == 1 then
        for i=0,7 do
            tweenPos(i, _G['defaultStrum'..i..'X'], getActorY(i), 0.1, done)
        end
    elseif curBeat % 4 == 2 then
        for i=0,7 do
            tweenPos(i, _G['defaultStrum'..i..'X'] + 50, getActorY(i), 0.1, done)
        end
    elseif curBeat % 4 == 3 then
        for i=0,7 do
            tweenPos(i, _G['defaultStrum'..i..'X'], getActorY(i), 0.1, done)
        end
    else
        error("bro wtf are you doing with the beat????")
    end
end

function update (elapsed)

	local currentBeatHalf = (songPos / 1000)*((bpm/2)/60)
	local currentBeat = (songPos / 1000)*(bpm/60)

	if swayCam then
		camHudAngle = 1 * math.sin(currentBeat / 1.5)
		cameraAngle = -1 * math.sin(currentBeat / 1.5)
	end
	
	if spookyArrows then
		for i=0,7 do
		setActorY(defaultStrum0Y + 10 * math.cos((currentBeat + i*0.25) * math.pi), i)
		end
	end
	
	if cosWave then
		for i=0,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 32 * math.cos((currentBeat + i) * math.pi), i)
		end
	end

	if curStep == 384 or curStep == 672 then -- reset position
		for i=0,7 do
			setActorY(posY, i)
		end
	end

	if (curStep >= 384 and curStep < 448) or (curStep >= 672 and curStep < 704) then -- starts doing the jebus
		if posY <= 100 then
			jebusSlideUpScroll()
		else
			jebusSlideDownScroll()
		end
	else
	end

	if swaySlow then --starts slow swaying
		for i=0,7 do  
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin(currentBeatHalf * math.pi), i)
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
				tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i) + 360, 0.11, done)
			end
		elseif beat % 8 == 4 then
			for i = 0, 7 do
				tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i) - 360, 0.11, done)
			end
		else
			error("bro wtf are you doing with the beat????")
		end
	end

    if jebusSlideXBegin then --jebus slide on x axis on beat
        jebusSlideXAxis()
    end

end

function stepHit(step) -- just read comments

	if step == 1 then -- sets position for Y for cases of up and down scroll
		posY = getActorY(0)
	end

	if step == 190 then -- spin strum forward
		for i = 0, 7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i) + 360, 0.15, done)
		end
	end

	if step == 254 then -- spin strum backward
		for i = 0, 7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'],getActorAngle(i) - 360, 0.15, done)
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
		setDefaultCamZoom(0.7)
		tweenCameraZoomOut(0.7,1)
	end

	if step == 256 then
		setDefaultCamZoom(1.05)
		tweenCameraZoomOut(1.05,1)
	end

	if step == 384 then
		setDefaultCamZoom(0.7)
		tweenCameraZoomOut(0.7,1)
	end

	if step == 448 then
		setDefaultCamZoom(1.05)
		tweenCameraZoomOut(1.05,1)
	end

	if step == 768 then
		setDefaultCamZoom(2)
		tweenCameraZoomOut(2,1)
	end
end