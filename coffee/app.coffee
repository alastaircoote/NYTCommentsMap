requirejs.config
    baseUrl: "/TwitterMap"
    shim:
        "jslib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "jslib/jsbezier":
            exports: "jsBezier"
        "jslib/heatmap-leaflet":
            deps:["jslib/leaflet", "jslib/heatmap"]
    paths: 
        "jquery":"jslib/jquery-1.8.0"
   
requirejs ["./js/map/mapdisplay","js/data/comments","js/map/heatmaplayer", "jquery"], (MapDisplay, CommentData,HeatMapLayer) ->
    mapDisplay = new MapDisplay $("#map")
    com = new CommentData()

    heatmapLayer = new HeatMapLayer();
    mapDisplay.map.addLayer(heatmapLayer);

    com.on "loaded", () ->
        
        interval = 10 * 60 * 1000 # 10 mins
        lowIndex = 0
        startDate = com.data[0].date
        startMoment = new Date().valueOf()
        multiplier = 1000
        
        doDraw = () ->
            dateMoment = startDate + ((new Date().valueOf() - startMoment) * multiplier)
            lower = dateMoment - interval
            upper = dateMoment + interval

            while com.data[lowIndex].date < lower
                lowIndex++
            toDraw = []
            i = lowIndex
            while com.data[i].date <= upper
                d = com.data[i]
                toDraw.push
                    lat: d.lat
                    lng: d.lng
                    count: 50 - Math.abs(d.date - dateMoment)
                i++

             
            #window.webkitRequestAnimationFrame () ->
             #       doDraw()

        window.webkitRequestAnimationFrame () ->
             doDraw()

        ###
        int = setInterval () ->
            next = unemp.getNext()
            if !next
                clearInterval(int)
                return
            console.log next.year, next.period
            heatmapLayer.setData next.data
        ,300
        ###



     