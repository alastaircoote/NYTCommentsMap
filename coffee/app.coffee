requirejs.config
    shim:
        "lib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "lib/jsbezier":
            exports: "jsBezier"
    paths:
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"

requirejs ["map/mapdisplay","jquery"], (MapDisplay) ->
    new MapDisplay $("#map")