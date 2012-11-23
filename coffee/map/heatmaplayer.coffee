define ["jslib/leaflet","./coordinate","jslib/heatmap"], (L, Coordinate, HeatMap) ->
    class HeatMapLayer
        constructor: (options) ->
            bounds =
                sw:
                    lat:180
                    lng:180
                ne:
                    lat:-180
                    lng:-180

            options.datas.forEach (data) ->
                data.forEach (row) ->
                    if row.lat > bounds.ne.lat then bounds.ne.lat = row.lat
                    else if row.lat < bounds.sw.lat then bounds.sw.lat = row.lat

                    if row.lng > bounds.ne.lng then bounds.ne.lng = row.lng
                    else if row.lng < bounds.sw.lng then bounds.sw.lng = row.lng
            console.log bounds
            @overallBounds = bounds
        onAdd: (map) ->
            @map = map

            #if @map.options.zoomAnimation && L.Browser.any3d 
                #@map.on('zoomanim', @onAnimateZoom, this)
            
            @map.on "zoomend", @onReset, this
            @onReset()
  
        onRemove: () ->
            map.getPanes().overlayPane.removeChild(@_el[0])
            map.off('viewreset', @onReset, this)

        onReset: (e) =>
            if @_el
                @_el.remove()
                @_el =null
            #@_el.remove()

            size = @map.getSize()
            pxBounds = @map.getPixelBounds()


            # base dimensions are 2x screen to allow people to move and still see
            dimensions = 
                sw:
                    x:0- size.x
                    y: size.y * 2
                ne:
                    x: size.x * 2
                    y: 0- size.y

            # extent of our data points
            pxOverallBounds =
                sw: @map.latLngToContainerPoint(@overallBounds.sw)
                ne: @map.latLngToContainerPoint(@overallBounds.ne)

            # shrink the canvas if we can
            if pxOverallBounds.sw.x > dimensions.sw.x then dimensions.sw.x = pxOverallBounds.sw.x
            if pxOverallBounds.ne.x < dimensions.ne.x then dimensions.ne.x = pxOverallBounds.ne.x

            if pxOverallBounds.sw.y < dimensions.sw.y then dimensions.sw.y = pxOverallBounds.sw.y
            if pxOverallBounds.ne.y > dimensions.ne.y then dimensions.ne.y = pxOverallBounds.ne.y

           
            test = $ "<div/>"
                
                css:
                    width: dimensions.ne.x - dimensions.sw.x
                    height: dimensions.sw.y - dimensions.ne.y
                    top: dimensions.ne.y
                    left: dimensions.sw.x
                    background:"blue"
                    opacity:0.5
                    position: "absolute"

            $(@map.getPanes().tilePane).append(test)
            console.log test[0]
            return
            if !@_el
                @_el = $ '<div/>',
                    width: size.x# * 2
                    height: size.y# * 2
                    "class":"leaflet-layer"
                    css:
                        top: 0#-(size.y/2)
                        left: 0#-(size.x/2)
                        "-webkit-transition":"-webkit-transform 0.2s linear"
                        #background:"blue"
                        position: "absolute"

                
                #@baseDiv.append(@_el)
                console.log @map.getPanes()
                #@_el.insertBefore($(@map.getPanes().overlayPane).children().last())
                $(@map.getPanes().overlayPane).append(@_el)
                @heatmap = heatmapFactory.create
                    element: @_el[0]
                    radius:7

            points = @points.map((p) =>
                    t = @map.latLngToLayerPoint([p.lat, p.lng])
                    #console.log t
                    x: t.x# + (size.x/2)
                    y: t.y# + (size.y/2)
                    count: p.val
                    ).filter((t) -> return t.x > 0 && t.y > 0)
            @heatmap.store.setDataSet
                max:100
                data: points

            ,false,colorize
           

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


            