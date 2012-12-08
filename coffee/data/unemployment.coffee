define ["../struct/events"], (Events) ->
    class UnemploymentData extends Events
        constructor: () ->
            super()
            @loadData()
            @years = []
            @periods = null

            @yearIndex = -1
            @periodIndex = 9999

        loadData: () =>
            $.ajax
                url: "/TwitterMap/dummydata/plv82.json"
                dataType: "json"
                success: (data) =>
                    @points = data.areas
                    @data = data.data
                    for key,val of @data
                        @years.push key
                    @trigger "loaded"

        getNext: () =>
            if @periodIndex >= 11
                @yearIndex++
                currentYear = @data[@years[@yearIndex]]
                @periods = []
                for key,val of currentYear
                    @periods.push key

                @periodIndex = 0
            else
                if @periodIndex == 9 && @yearIndex == 4 then return false
                @periodIndex++

            yearToGet = @years[@yearIndex]
            periodToGet = @periods[@periodIndex]

            return {data: @data[yearToGet][periodToGet], year: yearToGet, period: periodToGet}
