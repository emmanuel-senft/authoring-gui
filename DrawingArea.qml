import QtQuick 2.2
 import QtQuick.Controls 2.14

import Ros 1.0

Item {

    id: drawingarea

    height: parent.height
    width: parent.width
    anchors.left: parent.left
    anchors.top: parent.top

    property double pixelscale: 1.0 // how many meters does 1 pixel represent?

    property string bgImage
    property int lineWidth: 10

    property color fgColor: "steelblue"

    property bool drawEnabled: true

    property var touchs

    property bool bgHasChanged: true

    property bool addGesture: false

    Canvas {
        id: canvas
        antialiasing: true
        opacity: 1
        property real alpha: 1

        property var lastCanvasData
        property var bgCanvasData

        anchors.fill: parent

        function storeCurrentDrawing() {
            var ctx = canvas.getContext('2d');
            lastCanvasData = ctx.getImageData(0,0,width, height);
        }

        onPaint: {

            var strokeIdx = 0;
            var i = 0;
            var ctx = canvas.getContext('2d');

            //ctx.reset();

            ctx.globalAlpha = canvas.alpha;


            // background image not yet loaded
            // if(!bgCanvasData) return;

            if (bgCanvasData) ctx.drawImage(bgCanvasData,0,0);
            if (lastCanvasData) ctx.drawImage(lastCanvasData,0,0);

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            var currentStrokes = [];
            for (var i = 0; i < touchs.touchPoints.length,1; i++) {
                if (i > 0)
                    break
                if(touchs.touchPoints[i].currentStroke.length !== 0) {
                    currentStrokes.push({color: touchs.touchPoints[i].color.toString(),
                                points: touchs.touchPoints[i].currentStroke,
                                width: drawingarea.lineWidth
                            });
                }
            }

            for (strokeIdx = 0; strokeIdx < currentStrokes.length; strokeIdx++) {
                var points = currentStrokes[strokeIdx].points;
                var width = currentStrokes[strokeIdx].width;

                ctx.lineWidth = width;

                ctx.beginPath();

                var prevCompositeMode = ctx.globalCompositeOperation;


                ctx.strokeStyle = currentStrokes[strokeIdx].color;


                var p1 = points[0];
                var p2 = points[1];

                ctx.moveTo(p1.x, p1.y);

                for (i = 1; i < points.length; i++)
                {
                    // we pick the point between pi+1 & pi+2 as the
                    // end point and p1 as our control point
                    var midPoint = midPointBtw(p1, p2);
                    ctx.quadraticCurveTo(p1.x, p1.y, midPoint.x, midPoint.y);
                    p1 = points[i];
                    p2 = points[i+1];

                }
                ctx.lineTo(p1.x, p1.y);
                recognizer.addPoint(p1.x, p1.y)

                ctx.stroke();

            }

        }

        function midPointBtw(p1, p2) {
            return {
                x: p1.x + (p2.x - p1.x) / 2,
                y: p1.y + (p2.y - p1.y) / 2
            };
        }

        // Component.onCompleted: loadImage(drawingarea.bgImage);
    }

    function clearDrawing() {
        canvas.lastCanvasData = null;
        var ctx = canvas.getContext('2d');
        ctx.clearRect(0, 0, canvas.width, canvas.height)
        canvas.requestPaint();
        bgHasChanged = true; //will trigger publishing of background on ROS
    }

    function update() {
        canvas.requestPaint();
        timerGesture.stop()
    }

    function newStroke(){
        recognizer.newStroke()
    }

    function finishStroke(stroke) {
        bgHasChanged = true; //will trigger publishing of background on ROS
        canvas.storeCurrentDrawing();
        stroke = [];
        timerGesture.restart()
    }

    function endGesture(){
        if (addGesture) {
            recognizer.addGesture(gestureName.text)
            addGesture=false
        }
        else{
            var fig = recognizer.recognize();

        }
        clearDrawing()
    }

    Timer{
        id: timerGesture
        interval: 800
        onTriggered: {
            console.log("gesture finished")
            endGesture()
        }
    }
}
