import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Shapes 1.15

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
    property var done: []
    property var doneSim: []
    property var action: container.action
    property var time: null
    //Scaling for variable display
    property var k: map.width/2500
    z:30
    opacity: .5

    Rectangle{
        opacity: .5
        id: dragPoint
        x:-width/2
        y:-height/2
        width: mouseArea.enabled ? 50*k : 25*k
        height: width
        radius: width/2
        color: "red"
        border.color: objColor
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
    onActionChanged: {
        if(action.includes("Move")){
            mouseArea.enabled = true
        }
        else{
            mouseArea.enabled = false
            snapRect.visible = false
            snappedPoi=origin
            doSnap(origin)
            //movedPois.removePoi(origin.type, origin.index, objColor)
        }
    }
    Component.onDestruction: {
        //if(origin !== null)
            //movedPois.removePoi(origin.type, origin.index, objColor)
    }
    Component.onCompleted: {
        snappedPoi = origin
    }

    MouseArea {
        id:mouseArea
        anchors.fill: dragPoint
        enabled: false
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onPressed: {
            if(time === null || time === -1){
                var d = new Date();
                time = d.getTime();
            }
            container.selected(true)
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
        width: 35*k
        height: width
        radius: width/2
        x:snapPoint.x-width/2
        y:snapPoint.y-height/2
        z:-11
        opacity: .8
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
        width: 10*k
        height: width
        radius: width/2
        x:startPoint.x-width/2
        y:startPoint.y-height/2
        z:-1
        opacity: 1
        visible: true
    }

     Shape {
        anchors.fill: parent
        z: -10
        ShapePath {
            strokeWidth: 5*k
            strokeColor: objColor
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 3 ]
            startX: startPoint.x; startY: startPoint.y
            PathLine { x: dragPoint.x+dragPoint.width/2; y: dragPoint.y+dragPoint.height/2}
        }
     }
     Shape{
         id: p
         anchors.fill: parent
         z: -10
         visible: ((startPoint.x - endX)**2 + (startPoint.y - endY)**2) > d**2
         property var endX: dragPoint.x+dragPoint.width/2
         property var endY: dragPoint.y+dragPoint.height/2
         property var angle: Math.atan2(startPoint.y-endY,startPoint.x-endX)
         property var d: 40*k
         ShapePath {
            strokeWidth: 5*k
            strokeColor: "black"
            fillColor: objColor
            startX: p.endX+20*k*Math.cos(p.angle); startY: p.endY+20*k*Math.sin(p.angle)
            PathLine { x: p.endX+p.d*Math.cos(p.angle+Math.PI/12); y: p.endY+p.d*Math.sin(p.angle+Math.PI/12)}
            PathLine { x: p.endX+p.d*Math.cos(p.angle-Math.PI/12); y: p.endY+p.d*Math.sin(p.angle-Math.PI/12)}
            PathLine { x: p.endX+15*k*Math.cos(p.angle); y: p.endY+15*k*Math.sin(p.angle)}
        }
    }

    onXChanged: {
        if (mouseArea.pressed){
            checkSnap()
        }
    }
    onYChanged: {
        if (mouseArea.pressed){
            checkSnap()
        }
    }

    function getCoord(){
        var imx = x/pixScale // /map.paintedWidth * map.sourceSize.width;
        var imy = y/pixScale + map.offset //  /map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }
    function checkSnap(){
        var dMin=rMax*rMax
        var parentPois = []
        for(var i=0;i<parent.listPoints.length;i++){
            if(snappedPoi === null){
                parentPois.push(parent.listPoints[i].name)
            }
        }
        var tempSnap = null
        for (var i=0;i<pois.children.length;i++){
            if(parentPois.includes(pois.children[i].name) || pois.children[i].type === "screw")
                continue
            var d = Math.pow(pois.children[i].x-x,2)+Math.pow(pois.children[i].y-y,2)
            if(d < dMin){
                dMin=d
                snapRect.visible = true
                snapPoint.x = pois.children[i].x-x
                snapPoint.y = pois.children[i].y-y
                tempSnap = pois.children[i]
            }
        }
        if(dMin === rMax*rMax){
            snapRect.visible = false
            snappedPoi=null
            //movedPois.removePoi(origin.type, origin.index,objColor)
        }
        else{
            if(tempSnap !== snappedPoi){
                snappedPoi = tempSnap
            }
            //movedPois.updatePoi(origin.type, origin.index,snappedPoi.x,snappedPoi.y,objColor)
        }
    }
    function doSnap(){
        var targetx = x + snapPoint.x
        var targety = y + snapPoint.y
        snapRect.visible = false
        if (snappedPoi !== null){
            x = snappedPoi.x
            y = snappedPoi.y
        }
    }
    function updateParam(){
        timerUpdateActions.restart()
        /*if(action === "Move"){
            param = origin.name +" to "+snappedPoi.name
        }
        else
            param = snappedPoi.name*/
    }

    onOriginChanged:{
        updateParam()
        if(origin === null){
            //movedPois.removePoi(type, index, objColor)
            try{
                anchor.destroy()
            }
            catch(err) {
              console.log(err.message)
            }
           return
        }
    }

    function getAction(){
        var actions=[]
        target = snappedPoi.name
        for(var i=0;i<action.length;i++){
            var a={}
            a.img1 = "none_ "
            a.name = action[i]
            if(a.name.includes("Move")){
                if (origin.name === snappedPoi.name){
                    continue //time = -1
                }
                target = origin.name +"-"+snappedPoi.name
                a.img1 = origin.name
                a.img3 = snappedPoi.name
            }
            else{
                target = origin.name
                a.img3 = target
            }
            if(a.name.includes("Inspect")){
                a.img2 = "Inspect"
                if(!a.name.includes("Move")){
                    a.img1 = a.name.split("-")[1]+"_ "
                }
            }
            else
                a.img2 = a.name
            a.target = target
            a.targetDisplay = target.replace(/_/g," ").replace('-',' to ')
            a.order = i
            a.color = container.objColor
            a.done = false
            if(done.includes(a.name) || doneSim.includes(a.name))
                a.done = true

            if (time === -1 || time === null){
                var d = new Date()
                time = d.getTime()
            }

            a.time = time
            actions.push(a)
        }
        return actions
    }

    function testDone(act, t){
        if(action.includes(act) && target.split("-").includes(t.split("-")[0])){
            if(act === "Pull")
                origin.pulled = true
            if(act === "Push")
                origin.pulled = false
            if(globalStates.state === "simulation")
                doneSim.push(act)
            else
                done.push(act)
            return true
        }
        return false
    }
    function poiUpdated(){
        if(!mouseArea.pressed){
            x = snappedPoi.x
            y = snappedPoi.y
        }
    }
    function testDelete(){
        if(action.includes("Move"))
            if (origin.name === snappedPoi.name)
                return true
        if(done.length>0)
            return true
        return false
    }
}
