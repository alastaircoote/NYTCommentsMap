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
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"
   
requirejs ["./js/map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
     