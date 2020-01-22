import QtQuick 2.12


Rectangle {
    id: rect
    width: 100
    height: 100
    color: "transparent"
    border.color: "transparent"
    border.width: 5
    radius: 1
    property string name: ""
    property var rectColor: "transparent"
    PinchHandler { }
    Rectangle{
        id:actualRect
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width/2
        height: parent.height/2
        color: parent.rectColor
        border.color: "red"
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
}
