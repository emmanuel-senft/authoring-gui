import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12

Item{
    id: virtualMouse
    property bool angle: false
    width: map.width/15
    height: width

    Item{
        x:-dragPoint2.width/2
        y:-dragPoint2.width/2
        width: parent.width
        opacity: 1
        Rectangle{
            id:dragPoint2
            visible: true
            x:0
            y:0
            width: parent.width
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
               source: angle ? "/res/switch.png" : "/res/drag.png"
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
            property double relativeX: x*Math.cos(displayView.rotation*Math.PI/180.)+y*Math.sin(displayView.rotation*Math.PI/180.)
            property double relativeY: y*Math.cos(displayView.rotation*Math.PI/180.)-x*Math.sin(displayView.rotation*Math.PI/180.)
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
               source: angle ? "/res/switch.png" : "/res/drag.png"
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
                    timerUpdate.stop()
                    dragPoint.x=0
                    dragPoint.y=0
                    moving = true
                    if(!angle)
                        commandPublisher.text = "mouse;"+parseInt(dragPoint.relativeX)+":"+parseInt(dragPoint.relativeY)+":0:0"
                    else
                        commandPublisher.text = "mouse;0:0:"+parseInt(dragPoint.relativeX)+":"+parseInt(dragPoint.relativeY)
                }
                onPressed: {
                    timerUpdate.restart()
                }
                Timer{
                    id: timerUpdate
                    interval: 10
                    running: false
                    repeat: true
                    onTriggered: {
                        if(!angle)
                            commandPublisher.text = "mouse;"+parseInt(dragPoint.relativeX)+":"+parseInt(dragPoint.relativeY)+":0:0"
                        else
                            commandPublisher.text = "mouse;0:0:"+parseInt(dragPoint.relativeX)+":"+parseInt(dragPoint.relativeY)
                    }
                }
            }

        }
    }
}
