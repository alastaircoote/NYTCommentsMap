define ["lib/leaflet","./linelayer"], (leaflet, LineLayer) ->
    return class MapDisplay
        constructor: (target) ->
            @mapEl = target
            map = L.map(@mapEl[0]).setView([37, 0], 2);
            tileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-n7irpmld/{z}/{x}/{y}.png', 
               maxZoom: 18
            console.log "hi" 
            tileLayer.addTo(map)

            map.addLayer(new LineLayer(new L.LatLng(51.39216, -2.19939), new L.LatLng(40.68122, -73.97636)))
            map.addLayer(new LineLayer(new L.LatLng(40.7, -74), new L.LatLng(26.7, 114)))