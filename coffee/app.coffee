requirejs.config
    baseUrl: "/TwitterMap"
    shim:
        "jslib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "jslib/jsbezier":
            exports: "jsBezier"
    paths:
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"
        "socketio":"http://localhost:8100/socket.io/socket.io.js"
 
requirejs ["./js/map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
    require ["socketio"], () ->
        socket = io.connect('http://localhost:8100')
        socket.on "tweet", (tweet) ->
            map.drawLine tweet.from, tweet.to 
