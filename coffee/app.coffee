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
   
requirejs ["./js/map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
     