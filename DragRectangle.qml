import QtQuick 2.0

Rectangle {
    id: rect
    width: 100
    height: 100
    color: "transparent"
    border.color: "red"
    border.width: 5
    radius: 1
    property string name: ""
    MouseArea{
        anchors.fill: parent
        drag.target: rect
        drag.axis: Drag.XAndYAxis
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
