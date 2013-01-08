define ["js/struct/events"], (Events) ->
    class Sidebar extends Events
        constructor: (@el) ->
            @ul = $("ul", @el)
            @existingLis = {}

            $.ajax
                url: "articleDetails.json"
                dataType:"json"
                success:(data) =>
                    @data = data
                    @trigger "loaded"
            super()

        receiveData: (data,obj) =>
            @ul.empty()
            previ = -60
            for article, i in data.articleCounts

                target = @existingLis[article[0]]
                if !target
                    data = @data[article[0]]
                    if !data then data = {title: article[0]}
                    target = $("<li><a href='#{article[0]}'>#{data.title}</a></li>")
                
                previ += 60
                target.css("top", previ)
                @ul.append(target)

                if i == 20
                    break;
                
                