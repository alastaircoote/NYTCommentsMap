define ["jslib/leaflet","./coordinate","jslib/heatmap"], (L, Coordinate, HeatMap) ->
    
    class HeatMapTile
        radius: 7
        constructor: (@layer,@canvas,point) ->
            @xy = point.multiplyBy(@layer.options.tileSize)

            sw = @xy.clone().subtract([(@radius*2),0]).add([0,(@radius*2)+@layer.options.tileSize])
            ne = @xy.clone().add([(@radius*2)+@layer.options.tileSize,0]).subtract([0,(@radius*2)])

            @pixelBounds = new L.Bounds(sw,ne)

            @tileBounds = new L.LatLngBounds(
                @layer._map.unproject(sw),
                @layer._map.unproject(ne)
            )
            @createHeatmap()
            #@drawData(@layer.data)
            @points = []

        createHeatmap: () =>
            @hm = heatmapFactory.create
                element: @canvas
                radius:@radius
                gradient: { 0.5: "rgb(0,0,255)", 0.6: "rgb(0,255,255)", 0.7: "rgb(0,255,0)", 0.85: "yellow", 0.9: "rgb(255,0,0)"}

        draw: () =>
            projected = @points.map (p) =>
                x: p.point.x - @xy.x
                y: p.point.y - @xy.y
                count: p.value

            @hm.store.setDataSet
                max:31.7
                data: projected

        roundData: (data) =>
            roundedPoints = {}
            toReturn = []
            data.forEach (p) =>
                newPoint =
                    x: (Math.round(p.x/@radius) * @radius)
                    y: (Math.round(p.y/@radius) * @radius)
                    count: p.count
                existing = roundedPoints[newPoint.x + "/" + newPoint.y]
                if existing #&& existing.count < newPoint.count
                    #existing.count = newPoint.count
                    existing.count += newPoint.count
                else
                    roundedPoints[newPoint.x + "/" + newPoint.y] = newPoint
                    toReturn.push newPoint

            return toReturn

        drawDataOld: (data) =>
            if !data then return
            @filteredPoints = data.filter (p) =>
                return @tileBounds.contains([p.lat,p.lng])

            convergedPoints = []
            @newMax = 0
            @filteredPoints.forEach (p)=>
                ll = @layer._map.project([p.lat,p.lng])

                newPoint =
                    x: (Math.round(ll.x/10) * 10) - @xy.x
                    y: (Math.round(ll.y/10) * 10) - @xy.y
                    count: p.val
                existing = convergedPoints.filter (p) ->
                    p.x == newPoint.x && p.y == newPoint.y
                ###
                if existing.length == 1 
                    existing[0].count += newPoint.count
                    if existing[0].count > @newMax then @newMax = existing[0].count
                else
                    convergedPoints.push newPoint
                    if newPoint.count > @newMax then @newMax = newPoint.count
                ###
                convergedPoints.push newPoint
            @filteredPoints = convergedPoints
            if @filteredPoints.length > 0
                @setData()
        setData: () =>
            start = new Date().valueOf()
            @hm.store.setDataSet
                max:31.7
                data: @filteredPoints
        clear: () =>
            @hm.clear()
            #console.log "draw", new Date().valueOf() - start