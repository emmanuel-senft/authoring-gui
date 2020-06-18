import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: arrow

    property var originCoord: null
    property var endCoord: null
    name: "arrow"
    action: "Fold"

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        z:20
        property var path: []
        property double angle: 0

        property int arrowHeadLength: 75 //px
        property int offset: 80
        onPaint: {

            var i = 0;
            var p1 = {x: origin.x+origin.width/2,y:origin.y+origin.width/2}
            var p2 = {x: end.x+origin.width/2,y:end.y+origin.width/2}

            angle = -Math.atan2(p2.x-p1.x,p2.y-p1.y)+Math.PI/2
            p2.x -= arrowHeadLength * Math.cos(angle);
            p2.y -= arrowHeadLength * Math.sin(angle);

            var ctx = canvas.getContext('2d');

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = 10;

            ctx.strokeStyle = arrow.objColor;
            ctx.fillStyle = arrow.objColor;

            ctx.beginPath();

            ctx.moveTo(p1.x, p1.y);

            ctx.lineTo(p2.x, p2.y);

            ctx.stroke();
            ctx.beginPath();
            ctx.translate(p2.x, p2.y);
            ctx.rotate(angle);
            ctx.lineTo(0, 20);
            ctx.lineTo(arrowHeadLength, 0);
            ctx.lineTo(0, - 20);

            ctx.closePath();
            ctx.fill();
        }
    }
    function paint(){
        checkSnap()
        canvas.requestPaint()
    }
    function getPoints(){
        return end.getCoord()//+'_'+origin.getCoord()
    }

    DragAnchor{
        id: origin
        objColor:"transparent"
        center: originCoord
        onXChanged: paint();
    }
    DragAnchor{
        id: end
        center:endCoord
        onXChanged: {
            paint()
        }
        onReleasedChanged: {
            doSnap()
        }
    }

    Component.onCompleted: {
        paint()
        doSnap()
        doSnap()
    }

    function checkSnap(){
        var dMin=Math.pow(end.x-origin.x,2)+Math.pow(end.y-origin.y,2)
        for (var i=0;i<pois.children.length;i++){
            var d = Math.pow(pois.children[i].x-origin.x,2)+Math.pow(pois.children[i].y-origin.y,2)
            if(d < dMin){
                dMin=d
                snapTo(pois.children[i].x,pois.children[i].y)
                snappedPoi = pois.children[i]
            }
        }
        if(dMin === Math.pow(end.x-origin.x,2)+Math.pow(end.y-origin.y,2)){
            snapTo(origin.x,origin.y)
            snappedPoi=null
        }
    }
    function doSnap(){
        var d_x = snap.x-origin.x
        var d_y = snap.y - origin.y
        origin.x = snap.x
        origin.y = snap.y
        end.x += d_x
        end.y += d_y
    }
    function selected(val){
        currentItem = val
    }

    onCurrentItemChanged: {
        if(currentItem){
            objColor = Qt.lighter(objColor,1.3)
            if(figures.currentItem !== null && figures.currentItem !== arrow)
                figures.currentItem.selected(false)
            figures.currentItem = arrow
            paint()
        }
        else{
            objColor = figures.colors[index]
            paint()
        }
    }
}
