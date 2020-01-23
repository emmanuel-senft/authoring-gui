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
    property var objColor: "transparent"
    property var objBorderColor: "red"
    PinchHandler { }
    Rectangle{
        id:actualRect
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.objWidth
        height: parent.objHeight
        color: parent.objColor
        border.color: parent.objBorderColor
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
        sendCommand("viz")
    }
    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
    }
}
