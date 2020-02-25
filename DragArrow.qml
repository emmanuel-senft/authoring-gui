import QtQuick 2.12
import QtQuick.Controls 1.4

DragItem {

    id: arrow

    property var originCoord: null
    property var endCoord: null

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
        canvas.requestPaint()
        sendCommand("viz")
    }
    function getPoints(){
        return end.getCoord()+'_'+origin.getCoord()
    }

    DragAnchor{
        id: origin
        color:"transparent"
        center:originCoord
        onXChanged: paint();
    }
    DragAnchor{
        id: end
        center:endCoord
        onXChanged: {
            checkSnap()
            paint()
        }
        onReleasedChanged: {
            doSnap()
        }
    }

    Component.onCompleted: {
        doSnap()
        indexes = indexArrows
    }

    function checkSnap(){
        var dMin=Math.pow(end.x-origin.x,2)+Math.pow(end.y-origin.y,2)
        for (var i=0;i<pois.children.length;i++){
            var d = Math.pow(pois.children[i].x-end.x,2)+Math.pow(pois.children[i].y-end.y,2)
            console.log(d)
            if(d < dMin){
                console.log("snapping")
                console.log(d)
                dMin=d
                snap.x=pois.children[i].x+pois.children[i].width/2-snap.width/2
                snap.y=pois.children[i].y+pois.children[i].width/2-snap.width/2
                snappedPoi = pois.children[i]
            }
        }
        if(dMin === Math.pow(end.x-origin.x,2)+Math.pow(end.y-origin.y,2)){
            snap.x=end.x+end.width/2-snap.width/2
            snap.y=end.y+end.width/2-snap.width/2
            snappedPoi=null
        }
    }
    function doSnap(){
        end.x = snap.x-end.width/2+snap.width/2
        end.y = snap.y-end.width/2+snap.width/2
    }
    function selected(val){
        console.log(val)
        currentItem = val
    }

    onCurrentItemChanged: {
        console.log(currentItem)
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
            console.log("resetting color")
        }
    }
}
