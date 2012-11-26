define ["jslib/leaflet","./coordinate","jslib/heatmap"], (L, Coordinate, HeatMap) ->
    
    class HeatMapTile
        constructor: (@layer,@canvas,point) ->
            @xy = point.multiplyBy(@layer.options.tileSize)
            @tileBounds = new L.LatLngBounds(
                @layer._map.unproject([@xy.x-25,@xy.y+@layer.options.tileSize+25]),
                @layer._map.unproject([@xy.x+@layer.options.tileSize+25,@xy.y-25]))
            @createHeatmap()
            @drawData(@layer.data)
        createHeatmap: () =>
            @hm = heatmapFactory.create
                element: @canvas
                radius:15
        drawData: (data) =>
            @filteredPoints = data.filter (p) =>
                return @tileBounds.contains([p.lat,p.lng])

            convergedPoints = []
            @filteredPoints.forEach (p)=>
                ll = @layer._map.project([p.lat,p.lng])

                newPoint =
                    x: (Math.round(ll.x/10) * 10) - @xy.x
                    y: (Math.round(ll.y/10) * 10) - @xy.y
                    count: p.val
                existing = convergedPoints.filter (p) ->
                    p.x == newPoint.x && p.y == newPoint.y

                if existing.length == 1 then existing[0].count += newPoint.count
                else convergedPoints.push newPoint

            @filteredPoints = convergedPoints
            if @filteredPoints.length > 0
                @setData()
        setData: () =>
            start = new Date().valueOf()
            
            @hm.store.setDataSet
                max:100
                data: @filteredPoints
            #console.log "draw", new Date().valueOf() - start

    class HeatMapLayer extends L.TileLayer.Canvas
        constructor: (options) ->
            @data = options.data
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
            super(map)
        pauseDuringZoom: () =>
            stopAnimation = true
            #restart = () ->
            #     map.on "zoomend"
        setData: (newdata,animationDuration) =>
            if !animationDuration then animationDuration = -1
            setDataFinal = () =>
                @data = newdata
                for tile in @tiles
                   tile.drawData(newdata) 
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

            