import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: spiral

    x:objX-margin/2
    y:objY-margin/2
    width: objWidth+margin
    height: objHeight+margin
    property color objColor: "red"
    property string name: ""
    property int index: 0
    property real objWidth: canvas.width
    property real objHeight: objWidth
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
        onPaint: {

            var i = 0;
            var center = {x: width/2,y:height/2}
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

            ctx.moveTo(center.x, center.y);
            for (i=0;i<100;i++){
                angle = i*Math.PI/25.
                r = width/2*i/100.
                console.log(angle)
                ctx.lineTo(center.x+r*Math.cos(angle), center.y+r*Math.sin(angle));

            }
            ctx.stroke();
        }
    }
    function paint(){
        canvas.requestPaint()
    }
    Rectangle{
        id: target
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 10
        height: width
        radius: width/2
        z:30
        color: "red"
    }
    onXChanged: {
        //Prevent emission on creation
        if (objColor !== "red")
            sendCommand("viz")
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        indexSpiral.splice(indexSpiral.indexOf(index), 1);
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
