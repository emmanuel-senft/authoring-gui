import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: cross

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

            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = cross.objColor;
            ctx.fillStyle = cross.objColor;

            ctx.beginPath();

            ctx.moveTo(0, 0);
            ctx.lineTo(width, height);
            ctx.stroke();
            ctx.moveTo(width, 0);
            ctx.lineTo(0, height);
            ctx.stroke();

        }
    }
    function paint(){
        canvas.requestPaint()
    }
    Rectangle{
        id: origin
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 10
        height: width
        radius: width/2
        z:30
        color: "red"
    }
    Rectangle{
        id: end
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
        indexCross.splice(indexCross.indexOf(index), 1);
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
