import QtQuick 2.0
import QtQuick.Controls 1.4

Item {

    id: arrow

    property var origin: null
    property var end: null
    property color color: "red"
    z:10
    visible: true
    rotation: 90

    width: 100
    height: 100
    x: 100
    y: 100
    MouseArea{
        anchors.fill: parent
        drag.target: arrow
        drag.axis: Drag.XAndYAxis
    }


    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        z:20
        property var path: []
        property double angle: 0

        property int arrowHeadLength: 75 //px
        property int offset: 80
        onPaint: {

            var i = 0;
            var p1 = {x: arrow.origin.x-parent.x,y:arrow.origin.y-parent.y}
            var p2 = {x: arrow.end.x-parent.x,y:arrow.end.y-parent.y}

            angle = -Math.atan2(p2.x-p1.x,p2.y-p1.y)+Math.PI/2
            p2.x -= arrowHeadLength * Math.cos(angle);
            p2.y -= arrowHeadLength * Math.sin(angle);

            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = arrow.color;
            ctx.fillStyle = arrow.color;

            ctx.beginPath();

            ctx.moveTo(p1.x, p1.y);

            ctx.lineTo(p2.x, p2.y);

            ctx.stroke();
            ctx.beginPath();
            ctx.translate(p2.x, p2.y);
            ctx.rotate(angle);
            ctx.lineTo(0, 20);
            ctx.lineTo(arrowHeadLength, 0);
            ctx.lineTo(0, - 20);

            ctx.closePath();
            ctx.fill();
        }
    }
    function paint(){
        canvas.requestPaint()
    }
}
