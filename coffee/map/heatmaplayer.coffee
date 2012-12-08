define ["jslib/leaflet","./coordinate","jslib/heatmap", "./heatmaptile"], (L, Coordinate, HeatMap,HeatMapTile) ->
    
    class HeatMapLayer extends L.TileLayer.Canvas
        radius:7
        constructor: (options) ->
            @tiles = []
            @stopAnimation = false
        drawTile: (canvas, point) ->
            @tiles.push(new HeatMapTile(this,canvas,point))
            return
        resetTiles: () =>
            console.log "Resetting tiles"
            @tiles = []
        onAdd: (map) ->
            map.on "zoomend", @resetTiles
            map.on "zoomanim", @pauseDuringZoom
            @on "load", @assignPointsToTiles
            super(map)
        pauseDuringZoom: () =>
            stopAnimation = true
            #restart = () ->
            #     map.on "zoomend"

        setPoints: (points) =>
            @geoPoints = points.map (p) ->
                latlng: new L.LatLng(p[1],p[0])
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
                else
                    existingIndex[rounded.x + "/" + rounded.y] = p.roundedPoint = {point:rounded, value:0}
                    @roundedPoints.push p.roundedPoint

        assignPointsToTiles: () =>
            if @tiles.length == 0 || !@geoPoints then return
            for point in @roundedPoints
                for tile in @tiles
                    if tile.pixelBounds.contains(point.point)
                        point.tile = tile
                        tile.points.push point
                        #break
                if !point.tile
                    console.log "Tile assign failed"


        setData: (data) ->
            @roundedPoints.forEach (point) ->
                point.value = 0
            for value,i in data
                @geoPoints[i].value = value
                if @geoPoints[i].roundedPoint
                    @geoPoints[i].roundedPoint.value += value

            @redrawAllTiles()

        redrawAllTiles: () ->
            @tiles.forEach (tile) ->
                tile.draw()


        setDataOld: (newdata,animationDuration) =>
            if !animationDuration then animationDuration = -1
            setDataFinal = () =>
                @data = newdata
                for tile in @tiles
                   tile.drawData(newdata)
                   tile.clear()
                this.fire("animationComplete")
                return

            targetTime = new Date().valueOf() + animationDuration
            numAnims = 0
            mapBounds = @_map.getBounds()
            doAnim = () =>
                if stopAnimation
                    stopAnimation = false
                    return
                diff = targetTime - new Date().valueOf()
                if diff <= 0
                    setDataFinal()
                    console.log numAnims / 4 + " fps"
                    return
                else
                    numAnims++
                    adjusted = @adjustData(@data,newdata,1 - (diff / animationDuration))
                    for tile in @tiles
                        if mapBounds.intersects(tile.tileBounds)
                            tile.drawData(adjusted)  
                    window.webkitRequestAnimationFrame () ->
                        doAnim()           

            doAnim()
          

        adjustData: (from,to, factor) ->
            ret = []
            for point,i in from
                #console.log i, to[i]#, point.count + ((to[i].count - point.count) * factor)
                ret.push
                    lat: point.lat
                    lng: point.lng
                    val: point.val + ((to[i].val - point.val) * factor)
            return ret

            