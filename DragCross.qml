import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: cross
    property var radius: 100
    property var centerCoord: null

    name: "cross"
    action: "Place"
    
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

            ctx.strokeStyle = cross.objColor;
            ctx.fillStyle = cross.objColor;

            ctx.beginPath();

            ctx.moveTo(center.x-radius, center.y-radius);
            ctx.lineTo(center.x+radius, center.y+radius);
            ctx.stroke();
            ctx.moveTo(center.x-radius, center.y+radius);
            ctx.lineTo(center.x+radius, center.y-radius);
            ctx.stroke();

        }
    }
    function paint(){
        checkSnap()
        canvas.requestPaint()
    }
    DragAnchor{
        id: center
        center:centerCoord

        onXChanged: {
            paint();
        }
        onReleasedChanged: {
            doSnap()
        }
    }
    function getPoints(){
        return center.getCoord()//+'_'+end.getCoord()
    }

    Component.onCompleted: {
        paint()
        doSnap()
        doSnap()
    }
    function checkSnap(){
        var dMin=radius*radius
        for (var i=0;i<pois.children.length;i++){
            var d = Math.pow(pois.children[i].x-center.x,2)+Math.pow(pois.children[i].y-center.y,2)
            if(d < dMin){
                dMin=d
                snapTo(pois.children[i].x,pois.children[i].y)
                snappedPoi = pois.children[i]
            }
        }
        if(dMin === radius*radius){
            snapTo(center.x,center.y)
            snappedPoi=null
        }
    }
    function doSnap(){
        center.x = snap.x
        center.y = snap.y
        paint()
    }
}
