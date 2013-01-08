define ["jslib/leaflet","./coordinate","jslib/heatmap"], (L, Coordinate, HeatMap) ->
    
    class HeatMapTile
        constructor: (@layer,@canvas,point, @radius) ->
            @xy = point.multiplyBy(@layer.options.tileSize)
            @calculateBounds(@radius)
        calculateBounds:(@radius) =>
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
                #gradient: { 0.5: "rgb(0,0,255)", 0.6: "rgb(0,255,255)", 0.7: "rgb(0,255,0)", 0.85: "yellow", 0.9: "rgb(255,0,0)"}

        draw: () =>
            
            projected = @points.map (p) =>
                x: p.x - @xy.x
                y: p.y - @xy.y
                count: p.count

            @hm.store.setDataSet
                max:50
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

        setData: () =>
            start = new Date().valueOf()
            @hm.store.setDataSet
                max:31.7
                data: @filteredPoints
        clear: () =>
            @hm.clear()
            #console.log "draw", new Date().valueOf() - start