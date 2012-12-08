define ["jslib/leaflet","./coordinate","jslib/heatmap", "./heatmaptile"], (L, Coordinate, HeatMap,HeatMapTile) ->
    
    class HeatMapLayer extends L.TileLayer.Canvas
        paused: false
        constructor: (options) ->
            @tiles = []
            @stopAnimation = false
        drawTile: (canvas, point) ->
            @tiles.push(new HeatMapTile(this,canvas,point))
            return
        resetTiles: (z1,z2) =>
            @tiles = []
        onAdd: (map) ->
            map.on "zoomstart", @resetTiles
            map.on "zoomend", @adjustTilesAfterZoom
            map.on "zoomanim", @pause
            map.on "movestart", @pause
            map.on "moveend", @adjustTilesAfterZoom
            @on "load", @assignPointsToTiles
            @setRadius(map)
            super(map)
            
        setRadius: (map) =>
            
            @radius = (map.getZoom() - 4) * 6 + 7
            console.log "new radius: #{@radius}"
        adjustTilesAfterZoom: () =>
            @setRadius(@_map)
            @projectAndRoundPoints()
            @setData(@currentData)
            @assignPointsToTiles()
            @redrawAllTiles()
            @resume()
       
        setPoints: (points) =>
            @geoPoints = points.map (p) ->
                latlng: new L.LatLng(p.geo[1],p.geo[0])
                areaMultiplier: if p.area > 10 then 10 else p.area
            @projectAndRoundPoints()
            @assignPointsToTiles()

        projectAndRoundPoints: () =>
            @roundedPoints = []
            existingIndex = {}
            @geoPoints.forEach (p) =>
                p.point = @_map.project(p.latlng)

                rounded = new L.Point((Math.round(p.point.x / @radius) * @radius),(Math.round(p.point.y / @radius) * @radius))
                
                existing = existingIndex[rounded.x + "/" + rounded.y]
                if existing
                    p.roundedPoint = existing
                    existing.areaMultiplier = (p.areaMultiplier + existing.areaMultiplier) /2
                else
                    existingIndex[rounded.x + "/" + rounded.y] = p.roundedPoint = {point:rounded, value:0, areaMultiplier: p.areaMultiplier}
                    @roundedPoints.push p.roundedPoint

        assignPointsToTiles: () =>
            if @tiles.length == 0 || !@geoPoints then return
            for tile in @tiles
                tile.calculateBounds(@radius)
            for point in @roundedPoints
                radius = (@radius + 30) * point.areaMultiplier
                p = point.point
                bounds = new L.Bounds p.clone().add([radius/2,0-(radius/2)]), p.clone().add([0-(radius/2),radius/2])
                for tile in @tiles
                    if tile.pixelBounds.intersects(bounds)
                        point.tile = tile
                        tile.points.push point
                        #break
                if !point.tile
                    console.log "Tile assign failed"


        setData: (data, donotset) =>
            if !donotset then @currentData = data
            @roundedPoints.forEach (point) ->
                point.value = 0
            for value,i in data
                @geoPoints[i].value = value
                if @geoPoints[i].roundedPoint
                    @geoPoints[i].roundedPoint.value += value

            @redrawAllTiles()

        animateData: (newdata, duration) =>
            completionTime = new Date().valueOf() + duration
            step = () =>
                diff = completionTime - new Date().valueOf()
                if @paused
                    @pausedData = newdata
                    @durationLeft =  diff
                    return
                if diff <= 0
                    @currentData = newdata
                    @fire "animationComplete"
                    return
                
                @setData @animationStep(@currentData,newdata,1-(diff / duration)), true
                window.webkitRequestAnimationFrame () ->
                    step()
            step()

        animationStep: (fromdata, todata, factor) ->
            retData = []
            for point, i in fromdata
                retData.push point + ((todata[i] - point) * factor)
            return retData

        redrawAllTiles: () ->
            @tiles.forEach (tile) ->
                tile.draw()

        pause: () =>
            @paused = true

        resume: () =>
            @paused = false
            if @pausedData
                @animateData @pausedData, @durationLeft
        

            