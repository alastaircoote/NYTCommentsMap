define [], () ->

    class Coordinate
        constructor: (@x,@y)->
        distanceTo: (otherCoord) =>
            xs = 0
            ys = 0

            xs = otherCoord.x - this.x
            xs = xs * xs 

            ys = otherCoord.y - this.y
            ys = ys * ys

            return Math.sqrt xs + ys 