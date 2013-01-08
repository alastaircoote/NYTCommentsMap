define [], () ->
    class Events
        constructor: () ->
            @events = {}

        on: (ev, func) =>
            if !@events[ev] then @events[ev] = []
            @events[ev].push(func)

        trigger: (ev, args) =>
            for func in @events[ev]
                func(args)