import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: cross

    
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
        actionList.update()
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
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        indexCross.splice(indexCross.indexOf(index), 1);
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
