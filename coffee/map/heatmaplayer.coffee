define ["jslib/leaflet","./coordinate","jslib/heatmap"], (L, Coordinate, HeatMap) ->
    class HeatMapLayer
        lineWidth: 2
        options:
            maxZoom:18
            minZoom:1
        constructor: () ->
            
        onAdd: (map) ->
            @map = map

            sw = @map.latLngToLayerPoint([25.0, -126.8])
            ne = @map.latLngToLayerPoint([50.8, -60.8])

            
            map.on('viewreset', @onReset, this)

            

            $.ajax
                url: "dummydata/points.json"
                success: (data) =>
                    @points = JSON.parse(data)
                    @onReset()
                    
            if @map.options.zoomAnimation && L.Browser.any3d 
                @map.on('zoomanim', @onAnimateZoom, this)
            

            
 
        onRemove: () ->
            map.getPanes().overlayPane.removeChild(@_el[0])
            map.off('viewreset', @onReset, this)

        onReset: () =>
            if @_el
                @_el.remove()

            size = @map.getSize()
            pxBounds = @map.getPixelBounds()


            @_el = $ '<div/>',
                width: size.x
                height: size.y
                "class":"leaflet-layer"
                css:
                    top: pxBounds.y
                    left: pxBounds.x
                    "-webkit-transition":"-webkit-transform 0.2s linear"
                    #background:"blue"
                    position: "absolute"

            
            #@baseDiv.append(@_el)
            @_el.insertBefore($(@map.getPanes().tilePane).children().last())
            @heatmap = heatmapFactory.create
                element: @_el[0]

            @heatmap.store.setDataSet
                max:500
                data: @points.map((p) =>
                    t = @map.latLngToLayerPoint([p.lat, p.lng])
                    #console.log t
                    x: t.x
                    y: t.y 
                    count: 60
                    ).filter((t) -> return t.x > 0 && t.y > 0)



        onAnimateZoom: (e) =>
            scale = @map.getZoomScale(e.zoom)
            bounds = @map.getBounds()
            nw = bounds.getNorthWest()
            se = bounds.getSouthEast()

            topLeft = @map._latLngToNewLayerPoint(nw, e.zoom, e.center)
            size = @map._latLngToNewLayerPoint(se, e.zoom, e.center)._subtract(topLeft)
            currentSize = @map.latLngToLayerPoint(se)._subtract(@map.latLngToLayerPoint(nw))
            origin = topLeft._add(size._subtract(currentSize).divideBy(2))

            @_el.css L.DomUtil.TRANSFORM, L.DomUtil.getTranslateString(origin) + ' scale(' + scale + ') '


            