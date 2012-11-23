define ["jslib/leaflet", "./heatmaplayer"], (leaflet, HeatMapLayer) ->
    return class MapDisplay
        constructor: (target) ->
            @mapEl = target
            @map = L.map(@mapEl[0])
            tileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-n7irpmld/{z}/{x}/{y}.png', 
               maxZoom: 18
            tileLayer.addTo(@map)

             
 
            sttileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-rjqv06av/{z}/{x}/{y}.png', 
               maxZoom: 18
            console.log sttileLayer
            sttileLayer.addTo(@map)
            @map.addLayer(new HeatMapLayer)

            @map.fitBounds [[27.7, -126.8],[45.1, -60.8]]

            

        