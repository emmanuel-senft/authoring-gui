import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: circle
    property var centerCoord: null
    property var rMax: null
    name: "circle"
    action: "Pick"

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

            ctx.strokeStyle = circle.objColor;
            ctx.fillStyle = circle.objColor;

            ctx.beginPath();

            ctx.moveTo(c.x+rMax, c.y);
            for (i=1;i<51;i++){
                angle = i*Math.PI/25.
                ctx.lineTo(c.x+rMax*Math.cos(angle), c.y+rMax*Math.sin(angle));

            }
            ctx.stroke();
        }
    }
    function paint(){
        canvas.requestPaint()
    }
    DragAnchor{
        id: center
        center:centerCoord

        onXChanged: {
            checkSnap()
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
