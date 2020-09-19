import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Shapes 1.15

Item{
    id: triPoint
    anchors.fill: parent
    property var midPoint: Qt.point(0,0)
    property var radius: 0
    property bool selected: true
    property var  angle: 0
    property var color: objColor
    property var centerText: ""

    onRadiusChanged: {
        mid.center = Qt.point(midPoint.x,midPoint.y)
        updatePos()
    }


    Item{
        id: left
        x: mid.x-radius
        y: mid.y
        Rectangle{
            id: targetLeft
            x:-width/2
            y:-height/2
            width: 37
            height: width
            radius: width/2
            color: "black"
            border.color: "white"
            border.width:width/8
        }
        Text{
            anchors.verticalCenter: targetLeft.verticalCenter
            anchors.horizontalCenter: targetLeft.horizontalCenter
            text:"L"
            font.family: "Helvetica"
            font.pointSize: 15
            font.bold: true
            color: "white"
        }

        MouseArea {
            anchors.fill: targetLeft
            drag.target: parent
            drag.axis: Drag.XAndYAxis
            onPressed: {
                rect.selected(true)
            }
            onReleased: {
                updateAction()
            }
            onPositionChanged: {
                angle=Math.atan2(mid.y-left.y,mid.x-left.x)
                updatePos()
            }
        }
    }
    Item{
        id: right
        x: mid.x+radius
        y: mid.y
        Rectangle{
            id: targetRight
            x:-width/2
            y:-height/2
            width: 37
            height: width
            radius: width/2
            color: "white"
            border.color: "black"
            border.width:width/8
        }
        Text{
            anchors.verticalCenter: targetRight.verticalCenter
            anchors.horizontalCenter: targetRight.horizontalCenter
            text:"R"
            font.family: "Helvetica"
            font.pointSize: 15
            font.bold: true
            color: "black"
        }

        MouseArea {
            anchors.fill: targetRight
            drag.target: parent
            drag.axis: Drag.XAndYAxis
            onPressed: {
                rect.selected(true)
            }
            onReleased: {
                updateAction()
            }
            onPositionChanged: {
                angle=Math.atan2(right.y-mid.y,right.x-mid.x)
                updatePos()
            }
        }
    }
    DragAnchor{
        id: mid
        center: Qt.point(0,0)
        onUpdated: {
            updatePos()
            updateAction()
        }
        borderColor: color
    }
    Text{
        z:200
        anchors.verticalCenter: mid.verticalCenter
        anchors.horizontalCenter: mid.horizontalCenter
        text:centerText
        font.family: "Helvetica"
        font.pointSize: 20
        font.bold: true
        color: "black"
    }
    Shape {
        anchors.fill: parent
        z: -10
        ShapePath {
            strokeWidth: 5
            strokeColor: "#FF696969"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 3 ]
            startX: left.x; startY: left.y
            PathLine { x: right.x; y: right.y}
        }
    }
    function updatePos(){
        midPoint = Qt.point(mid.x,mid.y)
        right.x=mid.x+radius*Math.cos(angle)
        right.y=mid.y+radius*Math.sin(angle)
        left.x=mid.x-radius*Math.cos(angle)
        left.y=mid.y-radius*Math.sin(angle)
    }
    function getCoord(){
        var scaleX = map.sourceSize.width / map.paintedWidth
        var scaleY = map.sourceSize.height / map.paintedHeight
        return parseInt(midPoint.x*scaleX)+','+parseInt(midPoint.y*scaleY)+','+parseInt(-angle*180/(Math.PI))
    }

/*
    Item{
        id: startPoint
        x:(left.x+right.x)/2
        y:(left.y+right.y)/2
    }

    Rectangle{
        id: startRect
        color: "black"
        width: 10
        height: width
        radius: width/2
        x:startPoint.x-width/2
        y:startPoint.y-height/2
        z:-1
        opacity: 1
        visible: true
    }
    Rectangle{
        id: dragPoint
        x:startPoint.x-width/2
        y:startPoint.y-height/2
        width: 40
        height: width
        radius: width/2
        color: "red"
        border.color: objColor
        border.width:width/3
    }

    MouseArea {
        id:mouseArea
        anchors.fill: dragPoint
        drag.target: dragPoint
        drag.axis: Drag.XAndYAxis
        acceptedButtons: Qt.LeftButton
        onPressed: {
            rect.selected(true)
            dragPoint.x = dragPoint.x
            dragPoint.y = dragPoint.y
        }
    }
/*        MouseArea {
            id:mouseArea
            anchors.fill: dial
            drag.target: dial
            drag.axis: Drag.XAndYAxis

            onMouseXChanged: {
                var theta=Math.atan2(dialCenter.y-rotationSlider.width/2,dialCenter.x-rotationSlider.width/2)
                displayView.rotation = theta/Math.PI*180+90
                dial.x=rotationSlider.width/2*(1+Math.cos(theta))-dial.width/2
                dial.y=rotationSlider.height/2*(1+Math.sin(theta))-dial.height/2
                rotationSlider.theta_h=displayView.rotation - rotationSlider.theta_r
            }
            */

}
