import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: anchor
    property var center: null
    property var virtualX: null
    property var virtualY: null
    property bool released: false
    property bool snapping: false
    x:center.x
    y:center.y
    width: 50
    height: width
    radius: width/2
    z:30
    color: "red"
    border.color: "steelblue"
    border.width:width/3
    opacity: .5

    MouseArea {
        id:mouseArea
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onClicked: {

            virtualX=0
            virtualY=0
            anchor.parent.selected(true)
        }
        onReleased: {
            anchor.released = true
        }
    }
    onXChanged: {
        released = false
        actionList.update()
    }
    function getCoord(){
        var off_x = (map.width-map.paintedWidth)/2
        var off_y = (map.height-map.paintedHeight)/2
        var imx = (x - off_x)/map.paintedWidth * map.sourceSize.width;
        var imy = (y - off_y)/map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }

    function snapTo(X,Y){
        snapping = true
        virtualX=x-X
        virtualY=y-Y
        x=X
        y=Y
        timerEndSnap.restart()
    }
}
