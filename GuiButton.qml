import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12


Button{
    id: button
    width: map.width/25
    height: width
    property var color: "yellowgreen"
    property var name: "plan"
    property var borderWidth: width/20
    property bool mirror: false
    style: ButtonStyle {
        background: Rectangle {
            border.width: button.borderWidth

            border.color: button.color
            radius: parent.height/2
            color: "transparent"

            Rectangle {
                id: rect
                anchors.fill: parent
                radius: parent.radius
                rotation: -45
                z:-1

                gradient: Gradient {
                    GradientStop { position: 0.0; color: button.pressed ? "GhostWhite":"Gainsboro" }
                    GradientStop { position: 1.0; color: button.pressed ? "Gainsboro":"GhostWhite" }
                }
            }
            Rectangle {
                property var k: 1.5
                id: rectIn
                anchors.horizontalCenter: rect.horizontalCenter
                anchors.verticalCenter: rect.verticalCenter
                width: parent.width/k
                height: parent.height/k

                radius: parent.radius/k
                rotation: 135
                z:-1

                gradient: Gradient {
                    GradientStop { position: 0.0; color: button.pressed ? "GhostWhite":"Gainsboro" }
                    GradientStop { position: 1.0; color: button.pressed ? "Gainsboro":"GhostWhite" }
                }
            }
            Image{
               id:img
               width: rectIn.width/1.41
               height: rectIn.height/1.41
               source: "/res/"+name+".png"
               anchors.horizontalCenter: rect.horizontalCenter
               anchors.verticalCenter: rect.verticalCenter
               mirror: button.mirror
               fillMode: Image.PreserveAspectFit
            }
        }
    }
    Component.onCompleted: {text=""}
}
