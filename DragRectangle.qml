import QtQuick 2.12


Rectangle {
    id: rect
    x:objX-margin/2
    y:objY-margin/2
    width: objWidth+margin
    height: objHeight+margin
    color: "transparent"
    border.color: "transparent"
    property int index: 0
    property real objWidth: 100
    property real objHeight: 100
    property real objX: 100
    property real objY: 100
    property real margin:200

    border.width: 5
    radius: 1
    property string name: ""
    property var objColor: "red"
    property var objInside: "transparent"
    PinchHandler { }
    Rectangle{
        id:actualRect
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.objWidth
        height: parent.objHeight
        color: parent.objInside
        border.color: parent.objColor
        border.width: parent.border.width
        radius: parent.radius
    }

    Rectangle{
        id: target
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: 10
        height: width
        radius: width/2
        color: "red"
    }
    onXChanged: {
        //Prevent emission on creation
        if (objColor !== "red")
            sendCommand("viz")
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        console.log(name)
        var indexes = null
        if (name === "circle")
            indexes = indexCircles
        if (name === "rect")
            indexes = indexRects
        if (name === "surface")
            indexes = indexSurfaces

        indexes.splice(indexes.indexOf(index), 1);

    }
    Component.onCompleted: {
        objColor = figures.colors[index]
    }
}
