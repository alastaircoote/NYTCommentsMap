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
   
requirejs ["./js/map/mapdisplay","js/data/unemployment","js/map/heatmaplayer", "jquery"], (MapDisplay, UnemploymentData,HeatMapLayer) ->
    mapDisplay = new MapDisplay $("#map")
    unemp = new UnemploymentData()

    heatmapLayer = new HeatMapLayer();
    mapDisplay.map.addLayer(heatmapLayer);

    unemp.on "loaded", () ->
        heatmapLayer.setPoints(unemp.points)
        heatmapLayer.setData(unemp.getNext().data)

        
        int = setInterval () ->
            next = unemp.getNext()
            if !next
                clearInterval(int)
                return
            console.log next.year, next.period
            heatmapLayer.setData next.data
        ,300



     