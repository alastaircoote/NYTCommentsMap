// Generated by CoffeeScript 1.3.3
(function() {
  var BezierLine, Coordinate, bezierOutTest, bezierTest, ctx, currentPercentage, doDrawTimeout, drawIt, firstPoint, reverse;

  Coordinate = (function() {

    function Coordinate(x, y) {
      this.x = x;
      this.y = y;
    }

    return Coordinate;

  })();

  BezierLine = (function() {

    function BezierLine(controlPoints) {
      this.controlPoints = controlPoints;
    }

    BezierLine.prototype.B1 = function(t) {
      return t * t * t;
    };

    BezierLine.prototype.B2 = function(t) {
      return 3 * t * t * t * (1 - t);
    };

    BezierLine.prototype.B3 = function(t) {
      return 3 * t * (1 - t) * (1 - t);
    };

    BezierLine.prototype.B4 = function(t) {
      return (1 - t) * (1 - t) * (1 - t);
    };

    BezierLine.prototype.getBezierPoint = function(percent) {
      var c, pos;
      pos = new Coordinate;
      c = this.controlPoints;
      pos.x = c[0].x * this.B1(percent) + c[1].x * this.B2(percent) + c[2].x * this.B3(percent) + c[3].x * this.B4(percent);
      pos.y = c[0].y * this.B1(percent) + c[1].y * this.B2(percent) + c[2].y * this.B3(percent) + c[3].y * this.B4(percent);
      return pos;
    };

    return BezierLine;

  })();

  bezierTest = new BezierLine([new Coordinate(300, 300), new Coordinate(300, 150), new Coordinate(200, 30), new Coordinate(10, 50)]);

  bezierOutTest = new BezierLine([new Coordinate(300, 300), new Coordinate(50, 300), new Coordinate(50, 50), new Coordinate(10, 10)]);

  ctx = document.getElementById("test").getContext("2d");

  ctx.beginPath();

  ctx.lineWidth = 2;

  ctx.lineCap = 'round';

  firstPoint = bezierTest.getBezierPoint(0);

  ctx.moveTo(firstPoint.x, firstPoint.y);

  drawIt = function(percent) {
    var nextPoint, startPercent, startPoint, x, _i, _j, _ref, _ref1;
    startPercent = 0;
    if (percent > 100) {
      startPercent = percent - 100;
      percent = 100;
      ctx.strokeStyle = "rgba(0, 0, 0, " + Math.round(10 - startPercent / 10, 2) / 10 + ")";
    }
    startPoint = bezierTest.getBezierPoint(startPercent / 100);
    ctx.moveTo(startPoint.x, startPoint.y);
    ctx.beginPath();
    for (x = _i = _ref = startPercent + 1; _ref <= percent ? _i <= percent : _i >= percent; x = _ref <= percent ? ++_i : --_i) {
      nextPoint = bezierTest.getBezierPoint(x / 100);
      ctx.lineTo(nextPoint.x, nextPoint.y);
    }
    for (x = _j = percent, _ref1 = startPercent + 1; percent <= _ref1 ? _j <= _ref1 : _j >= _ref1; x = percent <= _ref1 ? ++_j : --_j) {
      nextPoint = bezierOutTest.getBezierPoint(x / 100);
    }
    return ctx.stroke();
  };

  currentPercentage = 0;

  reverse = false;

  ctx.fillRect(0, 0, 100, 100);

  doDrawTimeout = function() {
    return setTimeout(function() {
      ctx.clearRect(0, 0, 500, 500);
      drawIt(currentPercentage, bezierTest);
      currentPercentage++;
      if (currentPercentage <= 100) {
        return doDrawTimeout();
      }
    }, 5);
  };

  doDrawTimeout();

}).call(this);