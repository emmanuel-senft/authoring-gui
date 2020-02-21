import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: spiral
    anchors.fill: parent
    property color objColor: "red"
    property bool snapping: false
    property string name: ""
    property int index: 0
    property var centerCoord: null
    property var rMax: null
    opacity: .6
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
                r = rMax*i/100.
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
            if(! snapping){
                end.x=x+rMax
                paint();
            }
        }
        onReleasedChanged: {
            if(released){
                timerSnap.restart()
            }
        }
    }
    DragAnchor{
        id: end
        x:center.x+rMax
        y:center.y
        color:"transparent"
        onXChanged: {
            if(! snapping){
                rMax = x-center.x
                y=center.y
                paint();
                center.resetSnap()
            }
        }
        onReleasedChanged: {
            if(released){
                timerSnap.restart()
            }
        }
    }
    Rectangle{
        id: snap
        color: objColor
        width: 20
        height: width
        radius: width/2
        x:0
        y:0
    }
    function updateSnap(x,y){
        snap.x = x
        snap.y = y
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
    Timer{
        id: timerSnap
        interval: 100
        onTriggered: {
            snapping = true
            var r = rMax
            var x = center.x
            var y = center.y
            center.snapTo(snap.x-center.width/2+snap.width/2,snap.y-center.width/2+snap.width/2)
            end.snapTo(center.x+r,center.y)
            timerEndSnap.restart()
            paint()
        }
    }
    Timer{
        id: timerEndSnap
        interval: 100
        onTriggered: {
            snapping = false
        }
    }
}
