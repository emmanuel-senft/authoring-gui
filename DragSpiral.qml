import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: spiral
    property var centerCoord: null
    property var rMax: null
    opacity: .6
    name: "spiral"
    action: "Screw"

    Canvas {
        id: canvas
        anchors.fill: parent
         antialiasing: true
        z:20
        property var path: []
        onPaint: {

            var i = 0;
            var c = {x: center.x+center.width/2,y:center.y+center.width/2}
            var r = 0;
            var angle = 0;
            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = spiral.objColor;
            ctx.fillStyle = spiral.objColor;

            ctx.beginPath();

            ctx.moveTo(c.x, c.y);
            for (i=0;i<101;i++){
                angle = i*Math.PI/25.
                r = rMax*i/100.
                ctx.lineTo(c.x+r*Math.cos(angle), c.y+r*Math.sin(angle));

            }
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
            end.x=x+rMax
            paint();
        }
        onReleasedChanged: {
            doSnap()
        }
    }
    DragAnchor{
        id: end
        x:center.x+rMax
        y:center.y
        objColor:"transparent"
        onXChanged: {
                checkSnap()
                rMax = x-center.x
                y=center.y
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
        doSnap()
        doSnap()
    }
    function checkSnap(){
        var dMin=rMax*rMax
        for (var i=0;i<pois.children.length;i++){
            var d = Math.pow(pois.children[i].x-center.x,2)+Math.pow(pois.children[i].y-center.y,2)
            if(d < dMin){
                dMin=d
                snapTo(pois.children[i].x,pois.children[i].y)
                snappedPoi = pois.children[i]
            }
        }
        if(dMin === rMax*rMax){
            snapTo(center.x,center.y)
            snappedPoi=null
        }
    }
    function doSnap(){
        center.x = snap.x
        center.y = snap.y
        end.x=center.x+rMax
        end.y=center.y
        paint()
    }
}
