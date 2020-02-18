import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: spiral
    anchors.fill: parent
    property color objColor: "red"
    property string name: ""
    property int index: 0
    property var centerCoord: null
    property var r_max: null
    z:10
    visible: true

    PinchHandler { }

    Canvas {
        id: canvas
        anchors.fill: parent
         antialiasing: true
        z:20
        property var path: []
        onPaint: {

            var i = 0;
            var c = {x: center.x+center.width/2,y:center.y+center.width/2}
            var r = 0;
            var angle = 0;
            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = spiral.objColor;
            ctx.fillStyle = spiral.objColor;

            ctx.beginPath();

            ctx.moveTo(c.x, c.y);
            for (i=0;i<101;i++){
                angle = i*Math.PI/25.
                r = r_max*i/100.
                console.log(angle)
                ctx.lineTo(c.x+r*Math.cos(angle), c.y+r*Math.sin(angle));

            }
            ctx.stroke();
        }
    }
    function paint(){
        canvas.requestPaint()
        sendCommand("viz")
    }
    DragAnchor{
        id: center
        center:centerCoord
        onXChanged: {
            end.x=x+r_max
            paint();
        }
    }
    DragAnchor{
        id: end
        x:center.x+r_max
        y:center.y
        color:"transparent"
        onXChanged: {
            r_max = x-center.x
            y=center.y
            paint();
        }
    }
    function getPoints(){
        return center.getCoord()+'_'+end.getCoord()
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        indexSpiral.splice(indexSpiral.indexOf(index), 1);
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
