import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: anchor
    property bool released: false
    property var objColor: "red"
    property var center: null
    x: center.x
    y: center.y
    z:30
    opacity: .5

    Rectangle{
        id: target
        x:-width/2
        y:-height/2
        width: 50
        height: width
        radius: width/2
        color: objColor
        border.color: "steelblue"
        border.width:width/3
    }

    MouseArea {
        id:mouseArea
        anchors.fill: target
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onPressed: {
            anchor.parent.selected(true)
        }
        onReleased: {
            anchor.released = true
        }
    }
    onXChanged: {
        released = false
    }
    function getCoord(){
        var imx = x /map.paintedWidth * map.sourceSize.width;
        var imy = y /map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }
}
