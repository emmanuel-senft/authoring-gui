import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

Item {

    id: rect

    anchors.fill: parent
    property color objColor: "red"
    property string name: ""
    property int index: 0
    property bool currentItem: false
    property var indexes: null
    property var action: []
    property var target: "undefined"
    property var done: false
    property var doneSim: false

    property var p0Coord: null
    property var p1Coord: null
    property var p2Coord: null
    property var p3Coord: null
    property bool c: false
    property var listPoints: []

    MouseArea{
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            cleanSnappedPois()
            if(inHull(Qt.point(mouseX,mouseY))){
                if (mouse.button & Qt.RightButton){
                    overlay.additionalVisible = ! overlay.additionalVisible
                }
                else{
                    mouse.accepted = false;
                }
            }
            else
                mouse.accepted = false;
        }
    }

    onActionChanged: {
        paint()
    }
    Item{
        id: drawings
        anchors.fill: parent
        opacity: .5
        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true
            z:-1
            property var path: []
            onPaint: {
                var ctx = canvas.getContext('2d');
                ctx.reset();
                ctx.lineJoin = "round"
                ctx.lineCap="round";

                ctx.lineWidth = 5;

                ctx.strokeStyle = rect.objColor;
                ctx.fillStyle = "white"
                ctx.beginPath();

                ctx.moveTo(p0.x+p0.width/2, p0.y+p0.width/2);
                ctx.lineTo(p1.x+p0.width/2, p1.y+p0.width/2);
                ctx.lineTo(p2.x+p0.width/2, p2.y+p0.width/2);
                ctx.lineTo(p3.x+p0.width/2, p3.y+p0.width/2);
                ctx.lineTo(p0.x+p0.width/2, p0.y+p0.width/2);

                ctx.stroke();
                ctx.fill();
                if(action === "Wipe")
                    ctx.fill();
            }
        }

        DragAnchor{
            id:p0
            center: p0Coord
            onUpdated: {
                updateAction()
                paint()
                normalise(p1,p2,p3)
            }
        }
        DragAnchor{
            id:p1
            center: p1Coord
            onUpdated: {
                updateAction()
                paint()
                normalise(p2,p3,p0)
            }
        }
        DragAnchor{
            id:p2
            center: p2Coord
            onUpdated: {
                updateAction()
                paint()
                normalise(p3,p0,p1)
            }
        }
        DragAnchor{
            id:p3
            center: p3Coord
            onUpdated: {
                updateAction()
                paint()
                normalise(p0,p1,p2)
            }
        }

        FreePoint{
            id: movePoint
            visible: overlay.target === "unknown"
            Component.onCompleted: {
                //radius = (p2Coord.x-p0Coord.x)/4
                center= Qt.point((p0Coord.x+p2Coord.x)/2,(p0Coord.y+p2Coord.y)/2)
            }
        }
        TriPoint{
            id: graspPoint
            visible: action.includes("Wipe")
            midPoint: Qt.point((p0Coord.x+p2Coord.x)/2,(p0Coord.y+p2Coord.y)/2)
            radius: map.width/30
        }
    }
    Rectangle {
        id:boundingArea
        x:0
        y:0
        width: 100
        height: 100
        visible: true
        z:250
        color: "transparent"
        property var displayAngle: -displayView.rotation
        rotation:displayAngle
        onDisplayAngleChanged: {
            updateArea()
        }
        RectangleOverlay{
            id: overlay
            anchors.fill:parent
            action: rect.action
            target: rect.target
        }
    }
    function updateAction(){
        timerUpdateActions.restart()
    }

    function paint(){
        updateArea()
        timerPois.start()
        canvas.requestPaint()
    }
    function updateArea(){
        var alpha = boundingArea.displayAngle/180*Math.PI
        var xs = [p0.x,p1.x,p2.x,p3.x]
        var ys = [p0.y,p1.y,p2.y,p3.y]
        var nxs = [0,0,0,0]
        var nys = [0,0,0,0]
        for(var i = 0; i<4;i++){
            nxs[i] = xs[i]*Math.cos(-alpha)-ys[i]*Math.sin(-alpha)
            nys[i] = xs[i]*Math.sin(-alpha)+ys[i]*Math.cos(-alpha)
        }
        var width_ini = Math.max.apply(Math,xs) - Math.min.apply(Math,xs)
        var height_ini = Math.max.apply(Math,ys) - Math.min.apply(Math,ys)
        var x=Math.min.apply(Math,xs)
        var width=Math.max.apply(Math,nxs)-Math.min.apply(Math,nxs)
        var y=Math.min.apply(Math,ys)
        var height=Math.max.apply(Math,nys)-Math.min.apply(Math,nys)
        boundingArea.width=width
        boundingArea.height=height
        //var d_diag = Math.sqrt(boundingArea.width**2+boundingArea.height**2)
        boundingArea.x=x-width/2+width_ini/2
        boundingArea.y=y-height/2+height_ini/2//+Math.min(height_ini/2,height/2)
        //boundingArea.x=x//*Math.cos(-alpha)-y*Math.sin(-alpha)//-Math.abs(width_ini/2*Math.cos(alpha))//-Math.abs(height_ini/2*Math.sin(alpha))+width_ini/2
        //boundingArea.y=y//*Math.cos(-alpha)+x*Math.sin(-alpha)//-Math.abs(height_ini/2*Math.cos(alpha))//-Math.abs(width_ini/2*Math.sin(alpha))+height_ini/2
    }

    Component.onCompleted: {
        if(action.length === 0){
            var types = getPoiType()
            var maxN = 0
            var text = ""
            for(var key in types){
                if (key !== "holes" && types[key]>maxN){
                    maxN = types[key]
                    text = key
                }
            }

            overlay.setObjectSelected(text)
            var objects = overlay.getObjects()
            for(var i =0; i<objects.children[0].children.length;i++){
                if(objects.children[0].children[i].name === text){
                    objects.children[0].children[i].checked = true
                    break
                }
            }
            if(text === "screws")
                action = ["Move"]
            if(text === "pushers")
                action = ["Push"]
            if(text === "s"){
                action = ["Wipe"]
                target = figures.colorNames[index]+" Area"
            }
        }
        var actions = overlay.getActions()
        for(var i =0; i<actions.children.length;i++){
            if(action.includes(actions.children[i].name)){
                actions.children[i].checked = true
                break
            }
        }
        if(action.includes("Inspect"))
            overlay.setInspect(true)

        objColor = figures.colors[index]
        currentItem = true
        updateObjects()
        paint()
        updateAction()
    }

    function updateObjects(){
        var types = getPoiType()
        var objects = overlay.getObjects()
        for(var i =0; i<objects.children[0].children.length;i++){
            objects.children[0].children[i].visible = objects.children[0].children[i].name in types
        }
    }

    function getPoints(){
        return p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()
    }

    function getPoiType(){
        cleanSnappedPois()
        var objectTypes={}
        for(var i=0; i<pois.children.length; i++){
            var poi = pois.children[i]
            if (inHull(poi)){
                if(objectTypes[poi.type+"s"])
                    objectTypes[poi.type+"s"]+=1
                else
                    objectTypes[poi.type+"s"]=1
            }
        }
        objectTypes["unknown"]=1
        objectTypes["surface"]=1
        return objectTypes
    }

    function selectedPois(){
        cleanSnappedPois()
        if(globalStates.state === "execution" || globalStates.state === "simulation" ){
            updateAction()
            return
        }

        var type = overlay.getObjectSelected().slice(0,-1)
        var currentPois = []
        var i = listPoints.length
        while(i--){
            if(typeof listPoints[i].origin === "undefined" || ! inHull(listPoints[i].origin) || listPoints[i].origin.type !== type){
                listPoints[i].destroy()
                listPoints.splice(i,1)
            }
            else{
                currentPois.push(listPoints[i].origin.name)
            }
        }

        for(var i=0; i<pois.children.length; i++){
            var poi = pois.children[i]
            if (inHull(poi) && poi.type === type && ! currentPois.includes(poi.name)){
                var component = Qt.createComponent("SnapPoint.qml");
                var anchor = component.createObject(rect, {container:rect,snappedPoi:poi,type:poi.type,index:poi.index,x:poi.x,y:poi.y,objColor:figures.colors[rect.index],opacity:1,origin:poi});
                listPoints.push(anchor)
            }
        }
        for(var i=0; i<movedPois.children.length; i++){
            var poi = movedPois.children[i]
            if (inHull(poi) && poi.type === type && ! currentPois.includes(poi.name)){
                var component = Qt.createComponent("SnapPoint.qml");
                var anchor = component.createObject(rect, {container:rect,snappedPoi:poi,type:poi.type,index:poi.index,x:poi.x,y:poi.y,objColor:figures.colors[rect.index],opacity:1,origin:poi});
                listPoints.push(anchor)
            }
        }
        //timerUpdateActions.start()
    }

    function inHull(poi){
        var a0 = Math.atan2(poi.y-p0.y,poi.x-p0.x)
        var a1 = Math.atan2(poi.y-p1.y,poi.x-p1.x)
        var a2 = Math.atan2(poi.y-p2.y,poi.x-p2.x)
        var a3 = Math.atan2(poi.y-p3.y,poi.x-p3.x)
        var a = [a0,a1,a2,a3]
        //a.sort(function (a, b) { return a-b; })
        //First triangle (Cutting rectangle into two convex hulls
        var d0=getDiff(a[1],a[0])
        var d1=getDiff(a[3],a[1])
        var d2=getDiff(a[0],a[3])
        //Second triangle
        var d3=getDiff(a[2],a[1])
        var d4=getDiff(a[3],a[2])
        var d5=getDiff(a[1],a[3])

        if((d0<0 && d1<0 && d2<0) || (d3<0 && d4<0 && d5<0))
            return true
        return false
    }
    function getDiff(a1,a2){
        return (a2-a1+3*Math.PI)%(2*Math.PI)-Math.PI
    }

    Timer{
        id: timerPois
        interval: 10
        onTriggered: selectedPois()
    }
    onCurrentItemChanged: {
        if(currentItem){
            drawings.opacity=.5
            if(figures.currentItem !== null && figures.currentItem !== rect)
                figures.currentItem.selected(false)
            figures.currentItem = rect
            paint()
        }
        else{
            drawings.opacity=.2
            overlay.additionalVisible = false
            paint()
        }
    }
    function setIndexes(val){
        indexes = val
    }
    function selected(val){
        currentItem = val
    }
    function setIndex(val){
        index = val
        currentItem = false
        currentItem = true
        updateAction()
    }
    Component.onDestruction: {
        indexes.splice(indexes.indexOf(index), 1);
        updateAction()
    }
    function getTemplate(){
        var template ={}
        template["type"] = overlay.actionType.selected
        template["targets"] = []
        for(var i=0;i<listPoints.length;i++){
            template["targets"].push(listPoints[i].origin.name)
        }
        return template
    }

    function getAction(){
        var act = overlay.getActionsSelected()
        if(overlay.getInspect())
            act[0]="Inspect-"+act[0]
        if(action !== act)
            action = act
        if (overlay.target === "unknown"){
            var a ={}
            a.name = rect.action[0]
            a.target = movePoint.getTarget()
            a.targetDisplay = "Object ("+figures.colorNames[index]+")"
            a.order = rect.index
            a.color = rect.objColor
            a.done = done || doneSim
            a.img1 = "unknown_ "
            a.img2 = a.name
            a.img3 = "unknown_ "

            a.time = 0
            return [a]
        }
        if (action[0] === "Wipe"){
            var a ={}
            a.name = action[0]
            a.target = graspPoint.getCoord()+'_'+p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()
            a.targetDisplay = rect.target
            a.order = rect.index
            a.color = rect.objColor
            a.done = done || doneSim
            a.img1 = "none_ "
            a.img2 = a.name
            a.img3 = figures.colorNames[index]+"_ "
            a.time = 0
            return [a]
        }
        var actions = []
        for(var i =0; i < listPoints.length; i++){
            actions = actions.concat(listPoints[i].getAction())
        }

        actions.sort(compare)

        return actions
    }

    function compare(a, b) {
        if(a.time>b.time)
            return 1
        if(a.time<b.time)
            return -1
        if(parseInt(a.target.split("_")[1]) > parseInt(b.target.split("_")[1]))
            return 1
        if(parseInt(a.target.split("_")[1]) < parseInt(b.target.split("_")[1]))
            return -1
        if(a.order>b.order)
            return 1
        if(a.order<b.order)
            return -1
        return 0
    }

    function testDone(act, t){
        if(overlay.target === "unknown"){
            if(act === "Move" && t === movePoint.getTarget()){
                done = true
                return true
            }
            return false
        }
        if(act === "Wipe"){
            if( t === graspPoint.getCoord()+'_'+p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()){
                done = true
                return true
            }
            return false
        }

        for(var i =0; i < listPoints.length; i++){
            if(listPoints[i].testDone(act, t)){
                done = true
                return true
            }
        }
        return false
    }

    function testDelete(){
        if(overlay.target === "unknown" || overlay.target === "surface"){
                return done
        }
        for(var i =0; i < listPoints.length; i++){
            if(listPoints[i].testDelete()){
                return true
            }
        }
        return false
    }

    onDoneSimChanged: {
        if(!doneSim)
            for(var i =0; i < listPoints.length; i++)
                listPoints[i].doneSim = []
    }

    function poiUpdated(){
        if(listPoints.length > 0){
            cleanSnappedPois()
            var minX = width
            var maxX = 0
            var minY = height
            var maxY = 0
            var allInHull = true
            for(var i =0; i < listPoints.length; i++){
                if (! inHull(listPoints[i].origin)){
                    allInHull = false
                }
                listPoints[i].poiUpdated()
                minX = Math.min(minX,listPoints[i].origin.x-width/100)
                maxX = Math.max(maxX,listPoints[i].origin.x+width/100)
                minY = Math.min(minY,listPoints[i].origin.y-height/100)
                maxY = Math.max(maxY,listPoints[i].origin.y+height/100)
            }
            if (!allInHull){
                p0.x = minX
                p0.y = minY
                p1.x = maxX
                p1.y = minY
                p2.x = maxX
                p2.y = maxY
                p3.x = minX
                p3.y = maxY
            }
        }
    }
    function init(names){
        var i = listPoints.length
        while(i--){
            listPoints[i].destroy()
            listPoints.splice(i,1)
        }
        var type =""
        for(var i=0; i<pois.children.length; i++){
            var poi = pois.children[i]
            if (names.indexOf(poi.name) >= 0){
                var component = Qt.createComponent("SnapPoint.qml");
                var anchor = component.createObject(rect, {container:rect,snappedPoi:poi,type:poi.type,index:poi.index,x:poi.x,y:poi.y,objColor:figures.colors[rect.index],opacity:1,origin:poi});
                listPoints.push(anchor)
                type = poi.type
            }
        }
        poiUpdated()
        overlay.objectType.selected = type
        for(var i =0; i<objects.children[0].children.length;i++){
            if(objects.children[0].children[i].name === type){
                objects.children[0].children[i].checked = true
                break
            }
        }
        updateAction()
    }

    function cleanSnappedPois(){
        for(var i = listPoints.length; i > 0 ; i--) {
           if(typeof listPoints[i] === "undefined")
               continue
          if (typeof listPoints[i].origin === "undefined" || listPoints[i-1].origin === null){
              try{
                listPoints[i-1].destroy()
              }
              catch(err) {
               ;
              }
              listPoints.splice(i-1,1)
          }
        }
    }
}
