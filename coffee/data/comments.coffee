define ["../struct/events"], (Events) ->
    class CommentData extends Events
        constructor: () ->
            super()
            $.ajax
                url: "/TwitterMap/dummydata/commentout.json"
                dataType: "json"
                success: (data) =>
                    @data = data
                    this.trigger "loaded"
                   
