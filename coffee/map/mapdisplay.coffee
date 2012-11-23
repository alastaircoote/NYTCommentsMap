define ["jslib/leaflet", "jslib/heatmap-leaflet"], (leaflet) ->
    return class MapDisplay
        constructor: (target) ->
            @mapEl = target
            @map = L.map(@mapEl[0])
            tileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-n7irpmld/{z}/{x}/{y}.png', 
               maxZoom: 18
            tileLayer.addTo(@map)

             
 
            sttileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-rjqv06av/{z}/{x}/{y}.png', 
               maxZoom: 18
            sttileLayer.addTo(@map)

            $.ajax
                url: "dummydata/points.json"
                success: (data) =>
                    points = JSON.parse(data)
                    
                    heat = new L.TileLayer.HeatMap
                        debug:true
                        radius:15

                    heat.addData points.map (p) ->
                        lat:p.lat
                        lon:p.lng
                        value: p.val


                    @map.addLayer(heat)
                  #  heat.redraw()

            @map.fitBounds [[27.7, -126.8],[45.1, -60.8]]

            

        