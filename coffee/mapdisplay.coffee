define ["lib/leaflet"], (leaflet) ->
    return class MapDisplay
        constructor: (target) ->
            @mapEl = target
            map = L.map(@mapEl[0]).setView([37, 0], 2);
            tileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-n7irpmld/{z}/{x}/{y}.png', 
               maxZoom: 18
            
            tileLayer.addTo(map)