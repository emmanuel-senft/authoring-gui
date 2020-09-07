import QtQuick 2.12
 import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12
import QtQuick.Controls 2.15


MouseArea{
    id: actionButton
    width: parent.width*4/5
    anchors.horizontalCenter: parent.horizontalCenter
    height: parent.height/12
    property var text: ""
    property var parameterType: ""
    property var color: "yellowgreen"
    property var borderWidth: height/20
    property var unit: ""
    property var value: slider.value
    visible: false
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    property var usableItem: []
    Text {
        anchors.fill: parent
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family: "Helvetica"
        font.pointSize: map.width/80
        color: "black"
        text: actionButton.text
        z:2
    }
    Rectangle{
        border.width: actionButton.borderWidth
        anchors.fill: parent
        border.color: actionButton.color
        radius: parent.height/5
        color: "transparent"

        Rectangle {
            id: rect
            anchors.fill: parent
            radius: parent.radius
            z:-1

            gradient: Gradient {
                GradientStop { position: 0.0; color: actionButton.pressed ? "GhostWhite":"Gainsboro" }
                GradientStop { position: 1.0; color: actionButton.pressed ? "Gainsboro":"GhostWhite" }
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
            z:-1

            gradient: Gradient {
                GradientStop { position: 0.0; color: actionButton.pressed ? "GhostWhite":"Gainsboro" }
                GradientStop { position: 1.0; color: actionButton.pressed ? "Gainsboro":"GhostWhite" }
            }
        }
    }
    onClicked: {
        if(mouse.button & Qt.RightButton){
            var viz = !parameterArea.visible
            for (var i=0;i<actionList.children.length;i++)
                actionList.children[i].hideParam()
            if(parameterType != "")
                parameterArea.visible = viz
        }
        else{
            delayedHide.start()
        }
    }

    Rectangle{
        id: disabledIndicator
        color: "black"
        border.width: actionButton.borderWidth
        anchors.fill: parent
        border.color: "black"
        radius: parent.height/5
        opacity: actionButton.enabled ? 0 :.5
    }


    Item {
        id: parameterArea
        width: 600
        height: 200
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.left
        visible: false

        Canvas {
            id: parameterBubble
            antialiasing: true
            anchors.fill: parent
            onPaint: {
                var ctx = parameterBubble.getContext('2d');
                var ref = parent
                var triangleSize = width/40
                var radius = width/10
                ctx.reset();
                var recHeight = .9 * height
                var recWidth = .9 * width
                var xoffset = (width-recWidth)/2
                var yoffset = (height-recHeight)/2

                ctx.lineJoin = "round"
                ctx.lineCap="round";

                ctx.lineWidth = 10

                ctx.strokeStyle = "#ffc27a";
                ctx.fillStyle = "#B0f8f8ff";

                ctx.beginPath();

                ctx.moveTo(xoffset, height/2);
                ctx.arc(xoffset+radius, radius+yoffset,radius, Math.PI,3*Math.PI/2)
                ctx.lineTo(xoffset+recWidth-radius, yoffset);
                ctx.arc(xoffset+recWidth-radius, radius+yoffset,radius, -Math.PI/2,0)

                ctx.lineTo(xoffset+recWidth, height/2-triangleSize);
                ctx.lineTo(xoffset+recWidth+triangleSize, height/2);
                ctx.lineTo(xoffset+recWidth, height/2+triangleSize);

                ctx.lineTo(xoffset+recWidth, recHeight - radius+yoffset);
                ctx.arc(xoffset+recWidth-radius, recHeight-radius+yoffset,radius, 0, Math.PI/2)
                ctx.lineTo(xoffset+radius, recHeight+yoffset);
                ctx.arc(xoffset+radius, recHeight-radius+yoffset,radius, Math.PI/2, Math.PI)
                ctx.lineTo(xoffset, height/2);
                ctx.stroke();
                ctx.fill()
            }
        }
        Component.onCompleted: parameterBubble.requestPaint()
        Column{
            width: parent.width * .7
            height: parent.height * .6
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            spacing: height/10
            Text {
                renderType: Text.NativeRendering
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Helvetica"
                font.pointSize: map.width/80
                color: "black"
                text: parameterType + ": " + slider.value.toString()+" "+unit
                z:2
            }

            Slider {
                id: slider
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                property int delta: 1
                from: 0
                value: 0
                to: 100
                stepSize: 1
                GuiButton{
                    id: plusButton
                    anchors.verticalCenter: slider.verticalCenter
                    anchors.left: slider.right
                    width: map.width/60
                    onClicked: slider.value+=slider.stepSize
                    name: "add"
                }
                GuiButton{
                    id: minusButton
                    anchors.verticalCenter: slider.verticalCenter
                    anchors.right: slider.left
                    width: map.width/60
                    onClicked: slider.value-=slider.stepSize
                    name: "minus"
                }
                // https://stackoverflow.com/questions/36398040/qml-slider-tickmark-with-text-at-start-and-end
                Item{
                    id: tickArea
                    height: 20
                    width: slider.availableWidth - slider.implicitHandleWidth
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.bottom

                    Repeater {
                        id:repeater
                        model: (slider.to-slider.from) / (slider.stepSize * slider.delta)+1
                        z:10
                        Item{
                            width: 50
                            x:-width/2+index * ((tickArea.width) / (repeater.count-1))
                            y:-slider.height/10
                            Rectangle {id: tick; width: 5; height: 10; color: "black";anchors.horizontalCenter: parent.horizontalCenter}
                            Text {
                                anchors.top: tick.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "black"
                                font.pixelSize: 20
                                text: getText()
                                horizontalAlignment: Text.AlignHCenter

                                function getText() {
                                    return slider.from+slider.delta*slider.stepSize*index
                                }
                            }
                        }
                    }
                }
            }
        }
        onVisibleChanged: slider.value = 0
    }
    Component.onCompleted: {
        if(parameterType === "Angle"){
            slider.from = -90
            slider.value = 0
            slider.to = 90
            slider.delta = 30
            unit = "deg"
        }
        if(parameterType === "Distance"){
            slider.from = 0
            slider.value = 1
            slider.to = 10
            unit = "inch"
        }
    }
    function hideParam(){
        parameterArea.visible = false
    }
    onVisibleChanged: {
        if(!visible)
            hideParam()
    }
    Timer{
        id: delayedHide
        interval: 100
        onTriggered: {
            hideParam()
        }
    }
}
