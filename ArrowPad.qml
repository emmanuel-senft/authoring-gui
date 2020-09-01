import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12

Item{
    id: arrowPad
    property var type: "translation"
    width: map.width/10
    height: width
    property var imageNameRight: "arrow"
    property var imageNameLeft: imageNameRight
    property var imageNameUp: imageNameLeft
    property var imageNameDown: imageNameLeft

    property var rotRight: 180
    property var rotLeft: 180
    property var rotUp: 90
    property var rotDown: 90

    property var mirrorRight: true
    property var mirrorLeft: false
    property var mirrorUp: true
    property var mirrorDown: false

    property var scaleX: .05
    property var scaleY: .05

    Component.onCompleted: {
        if(type === "rotation"){
            imageNameRight="rotArrow"
            scaleX = -Math.PI/16
            scaleY = Math.PI/16
        }
        if(type === "other"){
            imageNameRight="rotArrow"
            scaleX = -.05
            scaleY = -Math.PI/16
            imageNameRight= "skip"
            imageNameLeft= imageNameRight
            imageNameUp= "zoom_in"
            imageNameDown= "zoom_out"
            rotRight = 90
            rotLeft = -90
            rotUp = 0
            rotDown = 0
            mirrorUp = false
            mirrorDown = false
        }
    }

    function publish(x,y){
        moving = true
        x*=scaleX
        y*=scaleY
        if(type === "translation"){
            commandPublisher.text = "mouse;"+x+":"+y+":0:0:0:0"
        }
        if(type === "rotation"){
            commandPublisher.text = "mouse;0:0:0:"+y+":"+x+":0"
        }
        if(type === "other"){
            commandPublisher.text = "mouse;0:0:"+x+":0:0:"+y
        }
    }

    GuiButton{
        id:right
        width: parent.width/2.5
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        color: "steelblue"
        rotation: rotRight
        mirror: mirrorRight
        name: imageNameRight
        onClicked: {
            publish(0,-1)
        }
    }
    GuiButton{
        id:left
        width: parent.width/2.5
        height: width
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        rotation: rotLeft
        mirror: mirrorLeft
        color: "steelblue"
        name: imageNameLeft
        onClicked: {
            publish(0,1)
        }
    }
    GuiButton{
        id:up
        width: parent.width/2.5
        height: width
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: rotUp
        mirror: mirrorUp
        color: "steelblue"
        name: imageNameUp
        onClicked: {
            publish(1,0)
        }
    }
    GuiButton{
        id:down
        width: parent.width/2.5
        height: width
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        rotation: rotDown
        mirror: mirrorDown
        color: "steelblue"
        name: imageNameDown
        onClicked: {
            publish(-1,0)
        }
    }
}
