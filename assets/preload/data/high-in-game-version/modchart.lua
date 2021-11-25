function start()
    setCamZooming(false)
    setCamZoom(1.05)
end

function update(elapsed)
    if curBeat < 48 then
        setCamZooming(false)
    end
end

function beatHit(beat)
    if beat == 48 then
        setCamZooming(true)
    end
end