define ["../struct/events"], (Events) ->
    class CommentData extends Events
        constructor: () ->
            super()
            $.ajax
                url: "commentdata/commentout.json"
                dataType: "json"
                success: (data) =>
                    @data = data
                    this.trigger "loaded"
                   
