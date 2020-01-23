import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: arrow

    x:objX-margin/2
    y:objY-margin/2
    width: objWidth+margin
    height: objHeight+margin
    property var origin: null
    property var end: null
    property color color: "red"
    property string name: ""
    property int index: 0
    property real objWidth: canvas.width
    property real objHeight: canvas.height
    property real objX: 100
    property real objY: 100
    property real margin:200
    z:10
    visible: true

    PinchHandler { }

    Canvas {
        id: canvas
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: objWidth
        height: objHeight
        antialiasing: true
        z:20
        property var path: []
        property double angle: 0

        property int arrowHeadLength: 75 //px
        property int offset: 80
        onPaint: {

            var i = 0;
            var p1 = {x: 0,y:height/2}
            var p2 = {x: width,y:height/2}

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
    onXChanged: {
        sendCommand("viz")
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
    }
}
