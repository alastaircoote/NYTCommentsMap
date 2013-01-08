define ["jslib/leaflet", "./heatmaplayer"], (leaflet,h) ->
    return class MapDisplay
        constructor: (target) ->
            @mapEl = target
            @map = L.map @mapEl[0],
                fadeAnimation:false
                zoom: 2
                center: [16.5, -3.2]
            tileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-n7irpmld/{z}/{x}/{y}.png', 
               maxZoom: 18
            tileLayer.addTo(@map)

            
            sttileLayer = L.tileLayer 'http://{s}.tiles.mapbox.com/v3/alastaircoote.map-rjqv06av/{z}/{x}/{y}.png', 
                maxZoom: 18
                zIndex:100
            sttileLayer.addTo(@map) 

            #@map.fitBounds [[27.7, -126.8],[45.1, -60.8]]
            return

            $.ajax
                url: "commentdata/points.json"
                success: (data) =>
                    points = JSON.parse(data)
                    
                    heat = new h
                        data: points

                    adjustedData = @adjustData(points)

                    activeData = adjustedData

                    @map.addLayer(heat)

                    heat.on "animationComplete", () ->
                        if activeData == points then activeData = adjustedData
                        else activeData = points
                        heat.setData activeData, 10000
                        

                    heat.setData adjustedData, 10000

                    


                  #  heat.redraw()

            

        adjustData: (data) ->
            data.map (p) ->
                lat: p.lat
                lng: p.lng
                val: if p.val > 50 then p.val - 50 else p.val + 50

        