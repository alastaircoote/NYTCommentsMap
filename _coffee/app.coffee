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
   
requirejs ["js/map/mapdisplay","js/data/comments","js/map/heatmaplayer","js/sidebar", "jquery"], (MapDisplay, CommentData,HeatMapLayer,SideBar) ->
    mapDisplay = new MapDisplay $("#map")
    com = new CommentData()

    allowStart = () ->
        $("button").html("Start")
        $("button").prop("disabled",false)

    heatDataLoaded = false
    sideDataLoaded = false



    heatmapLayer = new HeatMapLayer();
    #sidebar = new SideBar($("#sidebar"))

    #sidebar.on "loaded", () ->
    #    sideDataLoaded = true
    #    if heatDataLoaded
    #        allowStart()



    #heatmapLayer.on "articlelist", (data) ->
    #    sidebar.receiveData(data)

    heatmapLayer.on "datechange", (d) ->
        date = new Date(d.dateMoment)
        month = date.getMonth()+1
        day = date.getDate()
        hour = date.getHours()
        suffix = "am"
        if hour > 12
            hour = hour - 12
            suffix = "pm"
        minutes = date.getMinutes()
        if minutes < 10
            minutes = "0" + minutes

        $("h2").html("#{month}/#{day} #{hour}:#{minutes}#{suffix}")

    mapDisplay.map.addLayer(heatmapLayer);

    com.on "loaded", () ->
        heatmapLayer.setData com.data
        $("button").html("Start")
        $("button").prop("disabled",false)
        heatDataLoaded = true
        if (sideDataLoaded)
            allowStart()
       # heatmapLayer.animate()

    $("button").click () ->
        $("button, p").remove()
        heatmapLayer.animate()



     