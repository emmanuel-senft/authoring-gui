import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: anchor
    property var center: null
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
        anchors.fill: parent
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onClicked: {
            console.log("click")
            console.log(figures.toDelete)
            if(figures.toDelete){
                anchor.parent.destroy()
                figures.toDelete = false
            }
        }
    }
    function getCoord(){
        var off_x = (map.width-map.paintedWidth)/2
        var off_y = (map.height-map.paintedHeight)/2
        var imx = (x - off_x)/map.paintedWidth * map.sourceSize.width;
        var imy = (y - off_y)/map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }
}
