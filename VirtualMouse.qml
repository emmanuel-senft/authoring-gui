import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12

Item{
    id: virtualMouse
    Item{
        x:-dragPoint2.width/2
        y:-dragPoint2.width/2
        opacity: 1
        Rectangle{
            id:dragPoint2
            visible: true
            x:0
            y:0
            width: map.width/15
            height: width
            border.width: width/20
            border.color: "steelblue"
            rotation: -45
            z:-1
            radius: height/2
            gradient: Gradient {
                GradientStop { position: 0.0; color: mouseArea.pressed ? "GhostWhite":"Gainsboro" }
                GradientStop { position: 1.0; color: mouseArea.pressed ? "Gainsboro":"GhostWhite" }
            }
            Rectangle {
                property var k: 1.5
                id: rectIn2
                anchors.horizontalCenter: dragPoint2.horizontalCenter
                anchors.verticalCenter: dragPoint2.verticalCenter
                width: parent.width/k
                height: parent.height/k
                radius: parent.radius/k
                rotation: 135
                z:1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: mouseArea.pressed ? "GhostWhite":"Gainsboro" }
                    GradientStop { position: 1.0; color: mouseArea.pressed ? "Gainsboro":"GhostWhite" }
                }
            }
            Image{
               id:img2
               width: rectIn.width
               height: rectIn.height
               source: "/res/drag.png"
               anchors.horizontalCenter: dragPoint2.horizontalCenter
               anchors.verticalCenter: dragPoint2.verticalCenter
               rotation: 45
               z:2
               fillMode: Image.PreserveAspectFit
            }
        }
    }
    Item{
        x:-dragPoint.width/2
        y:-dragPoint.width/2
        opacity: .7
        Rectangle{
            id:dragPoint
            visible: true
            x:0
            y:0
            width: map.width/15
            height: width
            border.width: width/20
            border.color: "steelblue"
            rotation: -45
            z:-1
            radius: height/2
            gradient: Gradient {
                GradientStop { position: 0.0; color: mouseArea.pressed ? "GhostWhite":"Gainsboro" }
                GradientStop { position: 1.0; color: mouseArea.pressed ? "Gainsboro":"GhostWhite" }
            }
            Rectangle {
                property var k: 1.5
                id: rectIn
                anchors.horizontalCenter: dragPoint.horizontalCenter
                anchors.verticalCenter: dragPoint.verticalCenter
                width: parent.width/k
                height: parent.height/k
                radius: parent.radius/k
                rotation: 135
                z:1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: mouseArea.pressed ? "GhostWhite":"Gainsboro" }
                    GradientStop { position: 1.0; color: mouseArea.pressed ? "Gainsboro":"GhostWhite" }
                }
            }
            Image{
               id:img
               width: rectIn.width
               height: rectIn.height
               source: "/res/drag.png"
               anchors.horizontalCenter: dragPoint.horizontalCenter
               anchors.verticalCenter: dragPoint.verticalCenter
               rotation: 45
               z:2
               fillMode: Image.PreserveAspectFit
            }
            MouseArea {
                id:mouseArea
                anchors.fill: dragPoint
                drag.target: dragPoint
                drag.axis: Drag.XAndYAxis
                onReleased: {
                    dragPoint.x=0
                    dragPoint.y=0
                    moving = true
                    commandPublisher.text = "mouse;"+parseInt(dragPoint.x)+":"+parseInt(dragPoint.y)
                }
            }
            onXChanged: {
                moving = true
                commandPublisher.text = "mouse;"+parseInt(dragPoint.x)+":"+parseInt(dragPoint.y)
            }

        }
    }
}
