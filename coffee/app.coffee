requirejs.config
    shim:
        "lib/leaflet":
            deps: ["jquery"]
            exports: "L"
        "lib/jsbezier":
            exports: "jsBezier"
    paths:
        "jquery":"//ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min"
        "socketio":"http://stream.local.dev:8100/socket.io/socket.io"

requirejs ["map/mapdisplay","jquery"], (MapDisplay) ->
    map = new MapDisplay $("#map")
    require ["socketio"], (io) ->
        socket = io.connect('http://stream.local.dev:8100')
        socket.on "tweet", (tweet) ->
            map.drawLine tweet.from, tweet.to 
