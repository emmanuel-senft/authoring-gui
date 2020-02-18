import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: arrow

    anchors.fill: parent
    property var originCoord: null
    property var endCoord: null
    property color objColor: "red"
    property string name: ""
    property int index: 0
    z:10
    visible: true

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
            var p1 = {x: origin.x+origin.width/2,y:origin.y+origin.width/2}
            var p2 = {x: end.x+origin.width/2,y:end.y+origin.width/2}

            angle = -Math.atan2(p2.x-p1.x,p2.y-p1.y)+Math.PI/2
            p2.x -= arrowHeadLength * Math.cos(angle);
            p2.y -= arrowHeadLength * Math.sin(angle);

            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = arrow.objColor;
            ctx.fillStyle = arrow.objColor;

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
        sendCommand("viz")
    }
    function getPoints(){
        return end.getCoord()+'_'+origin.getCoord()
    }

    DragAnchor{
        id: origin
        color:"transparent"
        center:originCoord
        onXChanged: paint();
    }
    DragAnchor{
        id: end
        center:endCoord
        onXChanged: paint();
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        indexArrows.splice(indexArrows.indexOf(index), 1);
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
