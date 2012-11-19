class Coordinate
    constructor: (@x,@y)->

class BezierLine
    constructor: (@controlPoints) ->

    B1: (t) ->
        t*t*t
    B2: (t) ->
        3*t*t*t*(1-t)
    B3: (t) ->
        3*t*(1-t)*(1-t)
    B4: (t) ->
        (1-t)*(1-t)*(1-t)

    getBezierPoint: (percent) ->
        pos = new Coordinate
        c = @controlPoints
        pos.x = c[0].x * @B1(percent) + c[1].x * @B2(percent) + c[2].x * @B3(percent) + c[3].x * @B4(percent)
        pos.y = c[0].y * @B1(percent) + c[1].y * @B2(percent) + c[2].y * @B3(percent) + c[3].y * @B4(percent)
        return pos

bezierTest = new BezierLine [
    new Coordinate 300, 300
    new Coordinate 300,150
    new Coordinate 200,30
    new Coordinate 10,50
]

bezierOutTest = new BezierLine [
    new Coordinate 300, 300
    new Coordinate 50,300
    new Coordinate 50,50
    new Coordinate 10,10
]


ctx = document.getElementById("test").getContext("2d");
ctx.beginPath(); 
ctx.lineWidth=2;
ctx.lineCap = 'round';
firstPoint = bezierTest.getBezierPoint(0)
ctx.moveTo firstPoint.x, firstPoint.y

drawIt = (percent) ->
    
    startPercent = 0
    if percent > 100
        startPercent = percent - 100 
        percent = 100
        ctx.strokeStyle = "rgba(0, 0, 0, " + Math.round(10-startPercent / 10,2) / 10 + ")"
    startPoint = bezierTest.getBezierPoint(startPercent/100)
    
    ctx.moveTo startPoint.x, startPoint.y
    ctx.beginPath()
    for x in [startPercent+1..percent]
        nextPoint = bezierTest.getBezierPoint(x/100)
        ctx.lineTo nextPoint.x, nextPoint.y

    for x in [percent..startPercent+1]
        nextPoint = bezierOutTest.getBezierPoint(x/100)
       # ctx.lineTo nextPoint.x, nextPoint.y

    ctx.stroke()

currentPercentage = 0
reverse = false
ctx.fillRect(0,0,100,100)

doDrawTimeout = () ->
    setTimeout () ->
        ctx.clearRect(0,0,500,500)
        drawIt(currentPercentage,bezierTest)
        #drawIt(currentPercentage,bezierOutTest)
        #setTimeout () ->
        #    ctx.clearRect(0,0,500,500)
        #,20
        currentPercentage++
        if currentPercentage <= 100 then doDrawTimeout()
    ,5
doDrawTimeout()
    #ctx.fill();