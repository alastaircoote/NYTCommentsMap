define ["lib/leaflet","./coordinate","lib/jsbezier"], (L, Coordinate,jsBezier) ->
    class LineLayer
        lineWidth: 2
        constructor: (@fromLatlng,@toLatLng) ->
            
        onAdd: (map) ->
            @map = map
            @_el = $('<canvas/>')
            console.log @_el[0]
            @canvas = @_el[0].getContext("2d")
            map.getPanes().overlayPane.appendChild(@_el[0])
            map.on('viewreset', @onReset, this)
            @onReset()

        onRemove: () ->
            map.getPanes().overlayPane.removeChild(@_el[0])
            map.off('viewreset', @onReset, this)

        onReset: () =>
            @startPos = @map.latLngToLayerPoint(@fromLatlng)
            @endPos = @map.latLngToLayerPoint(@toLatLng)
            
            @calculateDimensions()
            @drawLine()

            
        calculateDimensions: () =>
            cssProps =
                position: "absolute"
                #background:"blue"
                #opacity:0.5

            @startPosPx = {}
            @endPosPx = {}
            @controlPoints = [0..3].map () -> return new Coordinate
            @size =
                height: Math.abs(@startPos.y - @endPos.y)
                width: Math.abs(@startPos.x - @endPos.x)

            if @startPos.y > @endPos.y
                cssProps.top = @endPos.y
                @controlPoints[0].y = @size.height
                @controlPoints[3].y = 0
            else
                cssProps.top = @startPos.y
                @controlPoints[0].y = 0
                @controlPoints[3].y = @size.height

            if @startPos.x > @endPos.x
                cssProps.left = @endPos.x
                @controlPoints[0].x = @size.width
                @controlPoints[1].x = @size.width - (@size.width/4)
                @controlPoints[2].x = (@size.width/4)
                @controlPoints[3].x = 0
            else
                cssProps.left = @startPos.x
                @controlPoints[0].x = 0
                @controlPoints[1].x = (@size.width/4)
                @controlPoints[2].x = @size.width - (@size.width/4)
                @controlPoints[3].x = @size.width

            @controlPoints[1].y = @controlPoints[0].y - (@size.width / 4)
            @controlPoints[2].y = @controlPoints[0].y - (@size.width / 4)

            @controlPoints.reverse()

            @calculatePoints()
            
            @size.height += @extraHeight + @lineWidth
            @size.width += @lineWidth
            cssProps.top -= @extraHeight
            @_el.css cssProps
            @_el.attr @size
            
        drawLine: () =>
            @canvas.strokeStyle = "white"
            #@canvas.fillStyle="#25426d"

            grd = @canvas.createLinearGradient(0, 0, @size.width, @size.height);
            grd.addColorStop(0, "#25426d");
            grd.addColorStop(0.3, "#25426d");
            grd.addColorStop(0.5,"#4e76b1")
            grd.addColorStop(0.7, "#25426d");
            grd.addColorStop(1, "#25426d");
           
            @canvas.fillStyle = grd

            @canvas.lineCap = "round"
            @canvas.lineWidth = @lineWidth
            percentDrawn = 0
            drawTimeout = () =>
                setTimeout () =>
                    @canvas.clearRect(0,0,@size.width,@size.height)
                    @doDraw(percentDrawn)
                    percentDrawn++
                    if percentDrawn <= 200 then drawTimeout()
                ,5
            drawTimeout()

        calculatePoints: () =>
            lowestY = 0
            
            @secondLinePoints = @controlPoints.map (p,i) =>
                if i == 1 or i == 2 then return new Coordinate p.x, p.y - 15
                else return new Coordinate p.x, p.y

            pointMap = (points) =>
                (p) ->
                    point = jsBezier.pointOnCurve(points, p/100)
                    if point.y < lowestY then lowestY = point.y
                    return point


            @points = [0..100].map pointMap(@controlPoints)
            @secondLinePoints = [0..100].map pointMap(@secondLinePoints)
            @extraHeight = 0 - lowestY

        doDraw: (percent) =>
            startFrom = 0
            if percent > 100
                startFrom = percent - 100 
                percent = 100
                @canvas.strokeStyle = "rgba(0, 0, 0, " + Math.round(10-startFrom / 10,2) / 10 + ")"
            startPoint = @points[startFrom]
            @canvas.moveTo startPoint.x, startPoint.y
            @canvas.beginPath()
            for x in [startFrom...percent]
                nextPoint = @points[x]
                try 
                    @canvas.lineTo nextPoint.x + (@lineWidth/2), nextPoint.y + @extraHeight + (@lineWidth/2)
                catch error
                    console.log @points.length,x
                
            for x in [percent...startFrom]
                nextPoint = @secondLinePoints[x]
                @canvas.lineTo nextPoint.x + (@lineWidth/2), nextPoint.y + @extraHeight + (@lineWidth/2)
            #console.log nextPoint
            #for x in [percent..startFrom+1]
            #    nextPoint = bezierOutTest.getBezierPoint(x/100)
               # ctx.lineTo nextPoint.x, nextPoint.y
            @canvas.fill()
            #@canvas.stroke()