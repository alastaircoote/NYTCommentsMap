define ["jslib/leaflet","./coordinate","jslib/heatmap", "./heatmaptile"], (L, Coordinate, HeatMap,HeatMapTile) ->
    
    window.requestAnimFrame = 
              window.requestAnimationFrame       || 
              window.webkitRequestAnimationFrame || 
              window.mozRequestAnimationFrame    || 
              window.oRequestAnimationFrame      || 
              window.msRequestAnimationFrame     || 
              ( callback ) ->
                window.setTimeout(callback, 1000 / 60)
              
    




    class HeatMapLayer extends L.TileLayer.Canvas
        paused: false
        constructor: (options) ->
            @tiles = []
            @stopAnimation = false
        drawTile: (canvas, point) ->
            @tiles.push(new HeatMapTile(this,canvas,point, 10))
            return
        resetTiles: (z1,z2) =>
            @tiles = []
        onAdd: (map) ->
            map.on "zoomstart",() =>
                @pause()
                for tile in @tiles
                    tile.hm.clear()
                @resetTiles()
                

            map.on "zoomend", @resume
            map.on "moveend", @resume
            map.on "movestart", @pause
            #@on "load", @assignPointsToTiles
            @setRadius(map)

            map.on "click", =>
                if @paused then @resume() else @pause()



            super(map)
            
        setRadius: (map) =>
            
            @radius = 10
        adjustTilesAfterZoom: () =>
            @setRadius(@_map)
            @projectAndRoundPoints()
            @setData(@currentData)
            @assignPointsToTiles()
            @redrawAllTiles()
            #@resume()
       
        redrawAllTiles: () ->
            for tile in @tiles
                tile.draw()

        setData: (data) =>
            @data = data
            
        pause: () =>
            console.log "pause"
            @paused = true
            if @data && @lowIndex
                @pausePoint = @data[@lowIndex].date

        resume: () =>
            console.log "resume"
            if !@hasEverStarted || !@paused then return console.log "NO"
            @paused = false
            @animate()
            #@pausePoint = null

        animate: () =>
            @hasEverStarted = true
            interval = 10 * 60 * 1000 # 10 mins
            @lowIndex = 0
            startDate = @pausePoint || 1352200631000
            startMoment = new Date().valueOf()
            multiplier = 1000

            articleCounts = []
            articleCountMaps = {}
            
            doDraw = () =>
                dateMoment = startDate + ((new Date().valueOf() - startMoment) * multiplier)
                if @paused
                    return


                lower = dateMoment - interval
                upper = dateMoment + interval

                while @data[@lowIndex].date < lower
                    @lowIndex++
                toDraw = []
                
                i = @lowIndex
                if i >= @data.length
                    return
                while @data[i].date <= upper
                    d = @data[i]



                    if !articleCountMaps[d.article]
                        articleCountMaps[d.article] = articleCounts.length
                        articleCounts.push [d.article,1]
                    else 
                        articleCounts[articleCountMaps[d.article]][1]++

                    toDraw.push
                        lat: d.lat
                        lng: d.lng
                        count: 50 * (1 - Math.abs(d.date - dateMoment) / (upper - lower))
                    i++

                articleCounts.sort (a,b) ->
                    return b[1] - a[1]

                @fire("articlelist",{articleCounts})
                @fire("datechange",{dateMoment})
               
                @setDataRaw(toDraw)

                window.requestAnimFrame  () ->
                    doDraw()

            window.requestAnimFrame  () ->
                 doDraw()

        setDataRaw: (data) =>
            for tile in @tiles
                tile.points = []
            projected = data.map (data) =>
                proj =  @_map.project([data.lat, data.lng])
                return {
                    x: proj.x
                    y: proj.y
                    count: data.count
                }

            for point in projected
                for tile in @tiles
                    if tile.pixelBounds.contains([point.x,point.y])
                        tile.points.push(point)

            @redrawAllTiles()
        

            