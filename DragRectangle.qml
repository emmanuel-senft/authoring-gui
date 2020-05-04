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
    property var action: "undefined"
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
        onPressed: {
            if(inHull(Qt.point(mouseX,mouseY))){
                if (c === true){
                    console.log("double")
                    objects.visible = ! objects.visible
                    c = false
                }
                else{
                    c = true
                    resetClick.start()
                    mouse.accepted = false;
                }
            }
            else
                mouse.accepted = false;
        }
    }
    onCChanged: {
        console.log(c)
    }

    Timer{
        id: resetClick
        interval: 300
        onTriggered: {
            c = false
        }
    }

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

            ctx.strokeStyle = rect.objColor;
            ctx.fillStyle = rect.objColor;

            ctx.beginPath();

            ctx.moveTo(p0.x+p0.width/2, p0.y+p0.width/2);
            ctx.lineTo(p1.x+p0.width/2, p1.y+p0.width/2);
            ctx.lineTo(p2.x+p0.width/2, p2.y+p0.width/2);
            ctx.lineTo(p3.x+p0.width/2, p3.y+p0.width/2);
            ctx.lineTo(p0.x+p0.width/2, p0.y+p0.width/2);

            ctx.stroke();
            if(action === "Wipe")
                ctx.fill();
        }
        opacity: .5
    }
    Rectangle {
        id:boundingArea
        x:0
        y:0
        width: 100
        height: 100
        visible: false
    }

    ButtonGroup {
        id: objectType
        buttons: objects.children
        property var selected: ""
        onSelectedChanged: {
            selectedPois()
            target = selected+"s"
            if(target === "screws"){
                move.visible = true
                loosen.visible = true
                tighten.visible = true
                push.visible = false
                wipe.visible = false
                if(actionType.selected !== "Loosen" && actionType.selected !== "Tighten")
                actionType.selected = "Move"
            }
            if(target === "pushers"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                push.visible = true
                wipe.visible = false
                actionType.selected = "Push"
            }
            if(target === "nons"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                push.visible = false
                wipe.visible = true
                actionType.selected = "Wipe"
                target = figures.colorNames[index]+" Area"
            }
            for(var i =0; i<actions.children[0].children.length;i++){
                if(actionType.selected.includes(actions.children[0].children[i].name)){
                    actions.children[0].children[i].checked = true
                }
                else{
                    actions.children[0].children[i].checked = false
                }
            }
        }
    }
    Column {
        id: objects
        visible:false
        anchors.top: p1.top
        anchors.left:boundingArea.right
        ColumnLayout {
            GuiRadioButton {
                text: "Screws"
                group: objectType
            }
            GuiRadioButton {
                text: "Holes"
                group: objectType
            }
            GuiRadioButton {
                text: "Pushers"
                group: objectType
            }
            GuiRadioButton {
                text: "None"
                group: objectType
            }
        }
    }
    ButtonGroup {
        id: actionType
        buttons: actions.children
        property var selected: ""
        onSelectedChanged: updateAction()
    }
    CheckBox {
        id: inspect
        anchors.top: boundingArea.bottom
        anchors.left:p3.right
        checked: false
        visible:objects.visible
        indicator: Rectangle {
            implicitWidth: 26
            implicitHeight: 26
            x: inspect.leftPadding
            y: parent.height / 2 - height / 2
            radius: 3
            border.color: inspect.down ? "#696969" : "black"

            Rectangle {
                width: 14
                height: 14
                x: 6
                y: 6
                radius: 2
                color: inspect.down ? "#696969" : "black"
                visible: inspect.checked
            }
        }
        contentItem: Text {
            text: "Inspect"
            font.family: "Helvetica"
            font.pointSize: 15
            font.bold: true
            style: Text.Outline
            styleColor: "black"
            color: "white"
            verticalAlignment: Text.AlignVCenter
            leftPadding: inspect.indicator.width + inspect.spacing
        }
        onCheckedChanged: updateAction()
    }
    function updateAction(){
        timerUpdateActions.restart()
    }

    Column {
        id: actions
        visible:objects.visible
        anchors.top: p0.top
        anchors.right:boundingArea.left
        ColumnLayout {
            GuiRadioButton {
                id: move
                text: "Move"
                group: actionType
                name:text
            }
            GuiRadioButton {
                id: tighten
                text: "Tighten"
                group: actionType
                name:text
            }
            GuiRadioButton {
                id: loosen
                text: "Loosen"
                group: actionType
                name:text
            }
            GuiRadioButton {
                id: push
                text: "Push"
                group: actionType
                name:text
            }
            GuiRadioButton {
                id: wipe
                text: "Wipe"
                group: actionType
                name:text
            }
        }
    }
    function paint(){
        updateArea()
        timerPois.start()
        canvas.requestPaint()
    }
    function updateArea(){
        boundingArea.x=Math.min(p0.x,p3.x)
        boundingArea.width=Math.max(p1.x,p2.x)-boundingArea.x
        boundingArea.y=Math.min(p0.y,p1.y)
        boundingArea.height=Math.max(Math.max(p2.y,p3.y)-boundingArea.y,objects.height)

    }

    Label{
        z:50
        id: actionDisplay
        text:action+" "+target
        x:p0.x
        y:p0.y-50
        font.bold: true
        font.pixelSize: 40
        style: Text.Outline
        styleColor: "black"
        color: "white"
    }
    DragAnchor{
        id:p0
        center: p0Coord
        onXChanged: paint();
        opacity: canvas.opacity
    }
    DragAnchor{
        id:p1
        center: p1Coord
        onXChanged: paint();
        opacity: canvas.opacity
    }
    DragAnchor{
        id:p2
        center: p2Coord
        onXChanged: paint();
        opacity: canvas.opacity
    }
    DragAnchor{
        id:p3
        center: p3Coord
        onXChanged: paint();
        opacity: canvas.opacity
    }


    Component.onCompleted: {
        if(action === "undefined"){
            var types = getPoiType()
            var maxN = 0
            var text = ""
            for(var key in types){
                if (types[key]>maxN){
                    maxN = types[key]
                    text = key
                }
            }
            objectType.selected = text
            for(var i =0; i<objects.children[0].children.length;i++){
                //console.log(objects.children[0].children[i].name)
                if(objects.children[0].children[i].name === text){
                    objects.children[0].children[i].checked = true
                    break
                }
            }
            if(text === "screw")
                action = "Move"
            if(text === "pusher")
                action = "Push"
            if(text === ""){
                action = "Wipe"
                target = figures.colorNames[index]+" Area"
            }
        }
        for(var i =0; i<actions.children[0].children.length;i++){
            //console.log(actions.children[0].children[i].name)
            if(action.includes(actions.children[0].children[i].name)){
                actions.children[0].children[i].checked = true
                break
            }
        }
        if(action.includes("Inspect"))
            inspect.checked = true

        objColor = figures.colors[index]
        currentItem = true

        paint()
        timerUpdateActions.restart()
    }

    function getPoints(){
        return p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()
    }

    function getPoiType(){
        var objectTypes={}
        for(var i=0; i<pois.children.length; i++){
            var poi = pois.children[i]
            if(poi.type === "hole")
                continue
            if (inHull(poi)){
                if(objectTypes[poi.type])
                    objectTypes[poi.type]+=1
                else
                    objectTypes[poi.type]=1
            }
        }
        return objectTypes
    }

    function selectedPois(){
        var type = objectType.selected
        var currentPois = []
        var i = listPoints.length
        while(i--){
            if(! inHull(listPoints[i].origin) || listPoints[i].origin.type !== type){
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
        timerUpdateActions.start()
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
            canvas.opacity=.5
            if(figures.currentItem !== null && figures.currentItem !== rect)
                figures.currentItem.selected(false)
            figures.currentItem = rect
            paint()
        }
        else{
            canvas.opacity=.2
            objects.visible = false
            paint()
        }
    }
    function setIndexes(val){
        indexes = val
    }
    function selected(val){
        //console.log("selected")
        //console.log(val)
        currentItem = val
    }
    function setIndex(val){
        index = val
        currentItem = false
        currentItem = true
        timerUpdateActions.restart()
    }
    Component.onDestruction: {
        indexes.splice(indexes.indexOf(index), 1);
        timerUpdateActions.restart()
    }
    function getTemplate(){
        var template ={}
        template["type"] = actionType.selected
        template["targets"] = []
        for(var i=0;i<listPoints.length;i++){
            template["targets"].push(listPoints[i].origin.name)
        }
        return template
    }

    function getAction(){
        var str = ""
        str = ""
        if(inspect.checked)
            str+="Inspect-"
        str+=actionType.selected
        action = str

        if (action === "Wipe"){
            var a ={}
            a.name = rect.action
            a.target = p0.getCoord()+'_'+p1.getCoord()+'_'+p2.getCoord()+'_'+p3.getCoord()
            a.targetDisplay = rect.target
            a.order = rect.index
            a.color = rect.objColor
            a.done = done || doneSim
            a.img1 = "none_ "
            a.img2 = a.name
            a.img3 = figures.colorNames[index]+"_ "
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

        //console.log(a.target)
        //console.log(a.target.split("_")[1])
        if(parseInt(a.target.split("_")[1])<parseInt(b.target.split("_")[1]))
            return -1
        if(a.order>b.order)
            return 1
    }

    function testDone(act, t){
        //console.log(listPoints.length)
        for(var i =0; i < listPoints.length; i++){
            if(listPoints[i].testDone(act, t)){
                done = true
                return true
            }
        }
        return false
    }

    function testDelete(){
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
                listPoints[i].doneSim = false
    }

    function poiUpdated(){
        if(listPoints.length > 0 && visible){
            var minX = width
            var maxX = 0
            var minY = height
            var maxY = 0
            var allInHull = true
            for(var i =0; i < listPoints.length; i++){
                if (! inHull(listPoints[i].origin)){
                    //console.log("not in hull")
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
                //console.log('Adding')
                var component = Qt.createComponent("SnapPoint.qml");
                var anchor = component.createObject(rect, {container:rect,snappedPoi:poi,type:poi.type,index:poi.index,x:poi.x,y:poi.y,objColor:figures.colors[rect.index],opacity:1,origin:poi});
                listPoints.push(anchor)
                type = poi.type
            }
        }
        poiUpdated()
        objectType.selected = type
        for(var i =0; i<objects.children[0].children.length;i++){
            //console.log(objects.children[0].children[i].name)
            if(objects.children[0].children[i].name === type){
                objects.children[0].children[i].checked = true
                break
            }
        }
        updateAction()
    }
}
