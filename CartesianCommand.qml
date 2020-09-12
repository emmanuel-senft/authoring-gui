import QtQuick 2.12
 import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12

Rectangle{
    property var parameterType: "distance"
    property var unit: "mm"
    property var label: "x:"
    property bool edited: false
    property var text: input.text
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width*9/10
    height: parent.height/10
    radius: height/5
    color: "transparent"

    Row{
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        spacing: width/20
        Text {
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            width: parent.width*2/10
            height: parent.height
            font.family: "Helvetica"
            font.pointSize: map.width/80
            color: "black"
            text: label
            z:2
        }
        Rectangle{
            id:back
            color: edited ? "steelblue":"white"
            width: parent.width/2
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            TextInput{
                id: input
                anchors.fill: parent
                text: "0"
                font.family: "Helvetica"
                font.pointSize: map.width/80
                color: "black"
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                onTextChanged: {
                    var val = parseFloat(text)
                    if(isNaN(val)){
                        warningReach.visible = false
                        warningNumber.visible = true
                        edited = false
                        return
                    }
                    warningNumber.visible = false
                    if(unit === "m" && (val > .8 || val < -.8)){
                        warningReach.visible = true
                        edited = false
                        return
                    }
                    if(label === "z:" && val < 0.04){
                        warningReach.visible = true
                        edited = false
                        return
                    }
                    if(label === "y:" && val < -0.25){
                        warningReach.visible = true
                        edited = false
                        return
                    }
                    warningReach.visible = false
                }
                onFocusChanged: {
                    if(focus){
                        selectAll()
                    }
                }
                onTextEdited: {
                    edited = true
                    console.log("edited")
                }
                onAccepted: {
                    send_pose()
                    focusMouse.focus = true
                }
            }
        }
        Text {
            width: parent.width *2/10
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.family: "Helvetica"
            font.pointSize: map.width/80
            color: "black"
            text: unit
            z:2
            height: parent.height
        }
    }

    function setText(val){
        if(!edited && !input.focus)
            input.text = val
    }

    Component.onCompleted: {
        if(parameterType === "angle"){
            unit = "deg"
        }
        if(parameterType === "distance"){
            unit = "m"
        }
    }
}
