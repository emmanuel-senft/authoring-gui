import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: surf
    property var p0Coord: null
    property var p1Coord: null
    property var p2Coord: null
    property var p3Coord: null

    Canvas {
        id: canvas
        anchors.fill: parent
         antialiasing: true
        z:20
        property var path: []
        onPaint: {
            var ctx = canvas.getContext('2d');
            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = surf.objColor;
            ctx.fillStyle = Qt.hsla(surf.objColor.hslHue, surf.objColor.hslSaturation, surf.objColor.hslLightness, .5)

            ctx.beginPath();

            ctx.moveTo(p0.x+p0.width/2, p0.y+p0.width/2);
            ctx.lineTo(p1.x+p0.width/2, p1.y+p0.width/2);
            ctx.lineTo(p2.x+p0.width/2, p2.y+p0.width/2);
            ctx.lineTo(p3.x+p0.width/2, p3.y+p0.width/2);
            ctx.lineTo(p0.x+p0.width/2, p0.y+p0.width/2);

            ctx.stroke();
            ctx.fill();
        }
    }
    function paint(){
        canvas.requestPaint()
        actionList.update()
    }
    DragAnchor{
        id:p0
        center: p0Coord
        onXChanged: paint();
    }
    DragAnchor{
        id:p1
        center: p1Coord
        onXChanged: paint();
    }
    DragAnchor{
        id:p2
        center: p2Coord
        onXChanged: paint();
    }
    DragAnchor{
        id:p3
        center: p3Coord
        onXChanged: paint();
    }

    function getPoints(){
        return p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()
    }
}
