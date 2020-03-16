import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: anchor
    property var objColor: "red"
    property var name: null
    property var type: null
    property var index: null
    property var rMax: 1000
    property var snappedPoi: null
    property var origin: null
    property var container: null
    property var target: null
    property var done: false
    property var action: container.action
    z:30
    opacity: .5

    Rectangle{
        opacity: .5
        id: dragPoint
        x:-width/2
        y:-height/2
        width: 40
        height: width
        radius: width/2
        color: "red"
        border.color: "steelblue"
        border.width:width/3
    }

    onSnappedPoiChanged: {
        if(snappedPoi !== null){
            name = snappedPoi.name
            index = snappedPoi.index
            type = snappedPoi.type
            updateParam()
        }

    }

    MouseArea {
        id:mouseArea
        anchors.fill: dragPoint
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onPressed: {
            container.selected(true)
            snappedPoi = null
        }
        onReleased: {
            doSnap()
        }
    }

    Item{
        id: snapPoint
        x:x
        y:y
    }

    Rectangle{
        id: snapRect
        color: objColor
        width: 20
        height: width
        radius: width/2
        x:snapPoint.x-width/2
        y:snapPoint.y-height/2
        z:10
        opacity: 1
        visible: false
    }
    /*
    Label{
        z:30
        id: actionDisplay
        text:action+" "+param.replace("_"," ")
        x:snapPoint.x-snapRect.width
        y:snapPoint.y-3*snapRect.height
        font.bold: true
        font.pixelSize: 40
        style: Text.Outline
        styleColor: "black"
        color: "white"
    }*/
    Item{
        id: startPoint
        x:origin.x-anchor.x-width/2
        y:origin.y-anchor.y-height/2
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

    Canvas{
        id: canvas
        x:0
        y:0
        z:-2
        width: 0
        height: 0
        onPaint: {

            var ctx = canvas.getContext('2d');
            var start = Qt.point(0,0)
            var end = Qt.point(width,height)

            ctx.reset();
            ctx.lineJoin = "round"
            ctx.lineCap="round";
            context.setLineDash([6]);

            ctx.lineWidth = 5;

            ctx.strokeStyle = objColor;
            ctx.fillStyle = "transparent";

            ctx.beginPath();

            if(startPoint.x*startPoint.y<0){
                console.log("reverse")
                start.x = width
                end.x =0
            }
            ctx.moveTo(start.x, start.y);
            ctx.lineTo(end.x, end.y);
            ctx.stroke();
        }
    }
    function paint(){
        canvas.x = Math.min(0,startPoint.x)
        canvas.y = Math.min(0,startPoint.y)
        canvas.width = Math.max(0,startPoint.x)-canvas.x
        canvas.height = Math.max(0,startPoint.y)-canvas.y
        canvas.requestPaint()
    }

    onXChanged: {
        if (mouseArea.pressed){
            checkSnap()
            paint()
        }
    }
    onYChanged: {
        if (mouseArea.pressed){
            checkSnap()
            paint()
        }
    }

    function getCoord(){
        var imx = x /map.paintedWidth * map.sourceSize.width;
        var imy = y /map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }
    function checkSnap(){
        var dMin=rMax*rMax
        var parentPois = []
        for(var i=0;i<parent.listPoints.length;i++){
            if(snappedPoi === null || parent.listPoints[i].name !== name)
                parentPois.push(parent.listPoints[i].name)
        }
        console.log(parentPois)
        for (var i=0;i<pois.children.length;i++){
            if(parentPois.includes(pois.children[i].name))
                continue
            var d = Math.pow(pois.children[i].x-x,2)+Math.pow(pois.children[i].y-y,2)
            if(d < dMin){
                dMin=d
                snapRect.visible = true
                snapPoint.x = pois.children[i].x-x
                snapPoint.y = pois.children[i].y-y
                snappedPoi = pois.children[i]
            }
        }
        if(dMin === rMax*rMax){
            snapRect.visible = false
            snappedPoi=null
        }
    }
    function doSnap(){
        console.log("snapping")
        var targetx = x + snapPoint.x
        var targety = y + snapPoint.y
        snapRect.visible = false
        if (snappedPoi !== null){
            x = snappedPoi.x
            y = snappedPoi.y
        }
        paint()
    }
    function updateParam(){
        timerUpdateActions.restart()
        /*if(action === "Move"){
            param = origin.name +" to "+snappedPoi.name
        }
        else
            param = snappedPoi.name*/
    }

    onOriginChanged:updateParam()

    function getAction(){
        target = snappedPoi.name
        if(action === "Move"){
            if (origin.name === snappedPoi.name)
                return []
            target = origin.name +"-"+snappedPoi.name
        }
        var a={}
        a.name = anchor.action
        a.target = target
        a.targetDisplay = target.replace(/_/g," ").replace('-',' to ')
        a.order = container.index
        a.color = container.objColor
        a.done = anchor.done
        console.log(a.name)
        console.log(a.targetDisplay)
        return a
    }

    function testDone(act, t){
        if(action === act && target === t){
            done = true
            return true
        }
        return false
    }
    function poiUpdated(){
        x = snappedPoi.x
        y = snappedPoi.y
        paint()
    }
}
