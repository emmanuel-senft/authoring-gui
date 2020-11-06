import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.15
import QtWebSockets 1.15

//import Ros 1.0

import ImagePainterQml 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    width: 2736
    height: 1824
    property bool simu: true
    property int prevWidth:800
    property int prevHeight:600
    property var initTime: 0
    property bool autonomous: false
    property bool moving: false
    property var pandaPose: Qt.vector3d(.36,0,.56)
    property var scaleX: 1 //map.width / map.paintedWidth
    property var scaleY: 1 //map.height / map.paintedHeight
    property var pixScale: map.ratio //map.width / map.paintedWidth
    title: qsTr("Authoring GUI")

    MouseArea{
        id: clickRecorder
        z:200
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: {
            if (mouse.button == Qt.RightButton)
                pubEvent("right_click")
            else
                pubEvent("left_click")
            mouse.accepted = false
        }
    }

    Item {
        id: displayView
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: Math.min(width*3/4, window.height)
        rotation: 0

        ImagePainter{
            id: map
            anchors.centerIn: parent
            width: parent.width
            height: parent.height
            /*
            fillMode: Image.PreserveAspectFit
            property string toLoad: realCamera
            property string virtualCamera: "image://rosimage/virtual_camera/image_repub"
            property string realCamera: "res/default.jpg"
            property string realCamera: simu ? virtualCamera : "image://rosimage/rgb/image_raw"
            property bool useRealImage: true
            source: toLoad
            cache: false
            rotation: 0
            Timer {
                id: imageLoader
                interval: 100
                repeat: true
                running: true
                onTriggered: {
                    map.source = "";
                    if(map.useRealImage){
                        map.source = map.toLoad;
                        interval = 100
                    }
                    else{
                        toLoad: "res/default.jpg"
                        repeat = false
                    }
                }
            }
            onSourceChanged: {
                if(source == realCamera){
                    rotation = 0
                    horizontalAlignment = Image.AlignLeft

                }
                else{
                    rotation = 0
                    horizontalAlignment = Image.AlignLeft
                }
            }
            */
            Item{
                id: pois
                visible: hidePoisButton.show
                property var cmd: null
                function addPoi(type,id,x,y){
                    var component = Qt.createComponent("POI.qml")
                    var color = "red"
                    if(type === "screw")
                        color = "yellow"
                    if(type === "box")
                        color = "gainsboro"
                    if(type === "hole"){
                        //return
                        color = "white"
                    }
                    if(type === "drawer")
                        color = "aliceblue"
                    if(type === "edge")
                        color = "blue"
                    var poi = component.createObject(pois, {type:type,index:id,color:color,x:x,y:y})
                }
                function clearPoi(){
                    for(var i =0;i<pois.children.length;i++){
                        try{
                            pois.children[i].destroy()

                        }
                        catch(err) {
                         ;
                        }
                    }
                }

                onCmdChanged: {timerPoi.start()}
                Timer{
                    id: timerPoi
                    interval: 500
                    onTriggered: {pois.updatePois()}
                }
                function updatePois(){
                    //if(map.paintedWidth < 1000)
                    //    return

                    for(var i =0;i<pois.children.length;i++){
                        pois.children[i].enabled = false
                    }

                    for(var i=0;i<cmd.length-1;i++){
                        var info = cmd[i+1].split(":")
                        var type = info[0]
                        var id = parseInt(info[1])
                        var coord = info[2]

                        var x = (parseInt(coord.split(",")[0])) * pixScale
                        var y = (parseInt(coord.split(",")[1]) - map.offset) * pixScale
                        var new_poi = true

                        for(var j =0;j<pois.children.length;j++){
                            var poi = pois.children[j]
                            if(poi.type === type && poi.index === id){
                                poi.x = x
                                poi.y = y
                                new_poi = false
                                poi.enabled = true
                                break
                            }
                        }
                        if(new_poi)
                            pois.addPoi(type, id, x, y)
                    }

                    //for(var i = pois.children.length; i > 0 ; i--) {
                    //  if (pois.children[i-1].updated === false){
                    //      pois.children[i-1].destroy()
                    //  }
                    //}
                    if(waitGui.waitPoi){
                        roi.visible = true
                    }
                    for(var i=0;i<figures.children.length;i++){
                        figures.children[i].poiUpdated()
                    }
                    if(roi.poi !== null){
                        roi.x = roi.poi.x-roi.width/2
                        roi.y = roi.poi.y-roi.width/2
                    }
                }
            }

       Rectangle{
                id: selectionArea
                opacity: .2
                color: "grey"
                property var startPoint: null
                visible: false

            }

            MouseArea{
                enabled: globalStates.state === "command"

                anchors.fill: parent
                property bool active: false
                onPressed: {
                    for(var i = 0;i<figures.children.length;i++){
                        if(figures.children[i].name === "rect" && figures.children[i].inHull(Qt.point(mouseX,mouseY))){
                            active = false
                            return
                        }
                    }
                    active = true
                    selectionArea.startPoint = Qt.point(mouseX,mouseY)
                    selectionArea.x = selectionArea.startPoint.x
                    selectionArea.y = selectionArea.startPoint.y
                    selectionArea.width = 0
                    selectionArea.height = 0
                    selectionArea.visible = true
                }
                onPositionChanged: {
                    if(!active)
                        return
                    selectionArea.width = Math.abs(mouseX-selectionArea.startPoint.x)
                    selectionArea.height = Math.abs(mouseY-selectionArea.startPoint.y)
                    selectionArea.visible = selectionArea.width>map.width/40 || selectionArea.height > map.height/40
                    console.log(selectionArea.visible)
                    selectionArea.x = Math.min(mouseX,selectionArea.startPoint.x)
                    selectionArea.y = Math.min(mouseY,selectionArea.startPoint.y)
                }

                onReleased: {
                    if(!selectionArea.visible)
                        return
                    if(selectionArea.width === 0){
                        console.log("is 0")
                        selectionArea.width = map.width/12
                        selectionArea.height = map.width/12
                        selectionArea.x -= selectionArea.width/2
                        selectionArea.y -= selectionArea.height/2
                        console.log(-selectionArea.width/2)
                    }

                    selectionArea.visible = false
                    figures.createRect(selectionArea.x,selectionArea.y,Math.max(100,selectionArea.width),Math.max(selectionArea.height))
                }
            }

        }
        MouseArea{
            id:protectionArea
            width: parent.width*2.02/3
            anchors.right: parent.right
            height: parent.height/6.5
            anchors.bottom: parent.bottom
            z:9
        }

        Figures {
            id:figures
            z:10
        }
        /*Item{
            id: movedPois
            visible: false

            function updatePoi(type,id,x,y,objColor){
                var found = false
                for(var i=0;i<movedPois.children.length;i++){
                    var poi = movedPois.children[i]

                    if(poi.type === type && poi.index === id && poi.color == objColor){
                        poi.x = x
                        poi.y = y
                        found = true
                        break
                    }
                }
                if(!found){
                    var component = Qt.createComponent("POI.qml")
                    var poi = component.createObject(movedPois, {type:type,index:id,color:objColor,x:x,y:y})
                }
            }
            function removePoi(type, index, objColor){
                for(var i =0;i<movedPois.children.length;i++){
                    var poi = movedPois.children[i]
                    if (poi.type === type && poi.index === index && poi.color == objColor){
                        movedPois.children[i].destroy()
                    }
                }
            }
        }*/
    }
    GamePlan{
        id: gamePlan
    }
    Item{
        id:gestureGui
        anchors.fill: parent
        visible: false

        GuiButton{
            id: addGestureButton
            z:10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            name: "add"
            onClicked:{
                drawingarea.addGesture = true
            }
            TextEdit{
                id: gestureName
                width: addGestureButton.width
                height: addGestureButton.height
                anchors.top: addGestureButton.bottom
                anchors.horizontalCenter: addGestureButton.horizontalCenter
                text: "gestureName"
                color: "white"
            }
        }
        GuiButton{
            id: saveButton
            z:10
            anchors.left: addGestureButton.right
            anchors.leftMargin: height
            anchors.verticalCenter: addGestureButton.verticalCenter
            name: "save"
            onClicked:{
                var string = recognizer._r.GetUserGestures()
                fileio.write("/src/authoring-gui/res/gestures.json",string)
            }
        }
    }
    Item{
        id:visualizationGui
        width: map.width
        height: map.height
        anchors.left: parent.left
        anchors.top: parent.top
        visible: true
    }
    Rectangle{
        id: displayArea
        anchors.top: parent.top
        anchors.left: parent.left
        height: map.height
        width: map.width
        color: "transparent"

        GuiButton{
            id: commandButton
            z:10
            width: parent.width/20
            anchors.right: displayArea.right
            anchors.rightMargin: width/2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            name: "play"
            onClicked:{gamePlan.sendCommand("exec");
                globalStates.state = "execution"
            }
            visible: false//commandGui.visible
        }
        GuiButton{
            id: simulateButton
            z:10
            anchors.bottom: commandButton.top
            anchors.bottomMargin: height/2
            anchors.horizontalCenter: commandButton.horizontalCenter
            name: "sim"
            color: "#ffc27a"
            onClicked:{
                gamePlan.sendCommand("sim");
                globalStates.state = "simulation"
            }
            visible: false //commandGui.visible
        }
        GuiButton{
            id: hidePoisButton
            z:10
            anchors.verticalCenter: deleteButton.verticalCenter
            anchors.left: displayArea.left
            anchors.leftMargin: width
            name: show ? "hide" : "show"
            property bool show: true
            onClicked:{
                show = ! show
            }
            visible: globalStates.state === "command"
        }

        ControlPanel{
            id: controlPanel
        }
/*
        GuiButton{
            id: bookButton
            anchors.verticalCenter: resetButton.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width / 5 - width/2
            z:10
            property int counter: 0
            color: figures.colors[counter]
            name: "bookview"
            onClicked:{
                viewButtons.children[counter].visible = true
                commandPublisher.text = "save_view;"+counter.toString()
                counter = (counter+1)%2
            }
            visible: false// commandGui.visible
        }
        Item{
            id:viewButtons
            anchors.verticalCenter: bookButton.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: + parent.width / 5
            visible: commandGui.visible
            GuiButton{
                property int number: 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: number * 3/2 * width
                color: figures.colors[number]
                z:10
                name: "view"
                onClicked:{
                    commandPublisher.text = "load_view;"+number.toString()
                }
                visible: false
            }
            GuiButton{
                property int number: 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: number * 3/2 * width
                color: figures.colors[number]
                z:10
                name: "view"
                onClicked:{
                    commandPublisher.text = "load_view;"+number.toString()
                }
                visible: false
            }
        }
*/

    //    GuiButton{
    //        id: resetButton
    //        anchors.horizontalCenter: commandButton.horizontalCenter
    //        anchors.bottom: parent.bottom
    //        anchors.bottomMargin: width
    //        z:10
    //        name: "reset"
    //        onClicked:{
    //            globalStates.state = "execution"
    //            commandPublisher.text = "reset_position"
    //        }
    //        visible: visible
    //    }
        GuiButton{
            id: deleteButton
            z:10

            anchors.verticalCenter: viewButton.verticalCenter
            anchors.horizontalCenter: viewButton.horizontalCenter
            anchors.horizontalCenterOffset: -2*width
            name: "del"
            color: "red"
            onClicked:{
                if(figures.currentItem !== null){
                    try{
                        figures.currentItem.destroy()
                    }
                    catch(err){
                        console.log(err)
                    }
                    figures.currentItem = null
                    timerCurrentItem.start()
                }
            }
            visible: commandGui.visible
        }
        Timer{
            id: timerCurrentItem
            interval: 200
            onTriggered: {
                if(figures.currentItem === null){
                    if(figures.children.length>0){
                        figures.children[figures.children.length-1].currentItem = true
                    }
                }
            }
        }

        GuiButton{
            id: infoButton
            z:10

            anchors.verticalCenter: deleteButton.verticalCenter
            anchors.horizontalCenter: deleteButton.horizontalCenter
            anchors.horizontalCenterOffset: -2*width
            name: "unknown"
            color: "orange"
            onClicked:{
                var item = figures.currentItem
                if(item !== null){
                    item.nextTip()
                }
            }
            visible: commandGui.visible && figures.children.length>0
        }
        GuiButton{
            id: viewButton
            z:10
            visible: false//true
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: height/2
            name: "switch"
            color: "#ffc27a"
            onClicked:{
                switch(globalStates.state){
                    case "visualization":
                        globalStates.state = "command"
                        map.toLoad = map.realCamera
                        pubCommand("init_gui")
                        break

                    case "command":
                        globalStates.state = "visualization"
                        map.toLoad = map.virtualCamera
                        pubCommand("unlock")
                        break

                    case "simulation":
                        globalStates.state = "command"
                        pubCommand("stop_sim")
                        break

                    case "execution":
                        globalStates.state = "command"
                        break
                }
            }
        }
        GuiButton{
            id: lockViewButton
            visible: false
            z:10
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.top: viewButton.bottom
            anchors.topMargin: height/2
            name: "lock"
            color: "FireBrick"
            onClicked:{
                globalStates.state = "command"
                pubCommand("lock")
            }
        }
        GuiButton{
            id: goToButton
            visible: false
            z:10

            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.verticalCenter: commandButton.verticalCenter

            name: "send"
            onClicked:{
                globalStates.state = "execution"
                map.toLoad = map.realCamera
                pubCommand("go")
            }
        }
      /*  GuiButton{
            id: stopButton
            z:10
            visible: executionGui.visible
            anchors.horizontalCenter: resetButton.horizontalCenter
            anchors.verticalCenter: resetButton.verticalCenter
            name: "stop"
            color: "red"
            onClicked:{
                commandPublisher.text = "stop"
                globalStates.state = "command"
            }
        }
        GuiButton{
            id: pauseButton
            z:10
            visible: false//executionGui.visible
            anchors.horizontalCenter: stopButton.horizontalCenter
            anchors.verticalCenter: commandButton.verticalCenter
            name: "pause"
            color: "orange"
            onClicked:{
                commandPublisher.text = name
                if(name === "pause"){
                    name = "play"
                    color = "green"
                }
                else{
                    name = "pause"
                    color = "orange"
                }
            }
        }
        GuiButton{
            id: editButton
            z:10
            //visible: executionGui.visible
            visible: false//executionGui.visible
            anchors.right: parent.right
            anchors.rightMargin: width/2
            anchors.top: parent.top
            anchors.topMargin: height/2
            name: "edit"
            color: "#ffc27a"
            onClicked:{
                eventPublisher.text = 'start_edit'
                pauseButton.name = "play"
                pauseButton.color = "green"
                commandPublisher.text = "pause"
                globalStates.state = "edit"
            }
        }
        GuiButton{
            id: stopEditButton
            z:10
            visible: false
            anchors.right: parent.right
            anchors.rightMargin: width/2
            anchors.top: parent.top
            anchors.topMargin: height/2
            name: "stop_edit"
            color: "#ffc27a"
            onClicked:{
                eventPublisher.text = 'stop_edit'
                globalStates.state = "execution"
            }
        }
        GuiButton{
            id: actButton
            visible: roi.visible
            z:20
            anchors.horizontalCenter: stopButton.horizontalCenter
            anchors.top: commandButton.bottom
            anchors.topMargin: height/2
            name: "act"
            onClicked:{
                waitGui.visible = false
                eventPublisher.text = "act"
                hideRoiTimer.start()
            }
        }
        GuiButton{
            id: nextButton
            visible: roi.visible
            z:30
            anchors.horizontalCenter: stopButton.horizontalCenter
            anchors.bottom: commandButton.top
            anchors.bottomMargin: height/2
            name: "skip"
            onClicked:{
                waitGui.visible = false
                eventPublisher.text = "skip"
                hideRoiTimer.start()
            }
        }*/
    }

    Item{
        id:executionGui
        visible: false
    }
    Item{
        id:fdGui
        visible: false
        anchors.fill: parent
        GuiButton{
            id: controlButton
            z:10
            visible: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            width: parent.width/5
            anchors.bottomMargin: height
            text: "Take Back Control"
            onClicked:{
                pubEvent("gui_takeover")
                globalStates.state = "command"
            }
        }
    }
    Item{
        id:waitGui
        property bool waitPoi: false
        visible: false
        anchors.fill: parent
        Timer{
            id: hideRoiTimer
            interval: 100
            onTriggered: roi.visible = false
        }

        Rectangle{
            id: roi
            x:0
            y:0
            property var poi: null
            visible: false
            width: 100
            height: width
            radius: width/2
            opacity: .5
            color: "transparent"
            border.color: "red"
            border.width: width/10
        }
        onVisibleChanged: {
            waitPoi = true
        }
    }
    Item{
        id:commandGui
        anchors.fill: parent
        visible: false
    }
    GuiButton{
        id: gestureEditButton
        z:10
        visible: false
        anchors.left: parent.left
        anchors.top: parent.top
        text: "Switch Mode"
        onClicked:{
            if (globalStates.state === "gestureEdit")
                globalStates.state = "command"
            else
                globalStates.state = "gestureEdit"
        }
    }
    Rectangle{
        id: backWarningDepth
        anchors.verticalCenter: warningDepth.verticalCenter
        anchors.horizontalCenter: warningDepth.horizontalCenter
        width: 1.1 * warningDepth.width
        height: 1.2 * warningDepth.height
        color: "gainsboro"
        radius: height/4
        border.color: "steelblue"
        visible: warningDepth.visible
        opacity: .8
    }

    Label{
        id: warningDepth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Bad depth, please move one handle"
        font.pixelSize: 50
        color: "red"
        visible: false
    }

    Rectangle{
        id: backWarningReach
        anchors.verticalCenter: warningReach.verticalCenter
        anchors.horizontalCenter: warningReach.horizontalCenter
        width: 1.1 * warningReach.width
        height: 1.2 * warningReach.height
        color: "gainsboro"
        radius: height/4
        border.color: "steelblue"
        visible: warningReach.visible
        opacity: .8
    }

    Label{
        id: warningReach
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Position out of reach, please move one handle"
        font.pixelSize: 50
        color: "red"
        visible: false
    }
/*
    RosStringPublisher{
        id: commandPublisher
        topic: "/gui/command"
        text:""
        Component.onCompleted: text="reset_position"
    }
    RosStringPublisher{
        id: eventPublisher
        topic: "/event"
        text:""
    }
*/
    function pubCommand(msg){
        socket.sendTextMessage("command:"+msg)
    }
    function pubEvent(msg){
        socket.sendTextMessage("event:"+msg)
    }
/*
    RosStringSubscriber{
        id: eventsSubscriber
        topic: "/event"
        text:""
        onTextChanged:{
            onEvent(text)
        }
    }

    RosStringSubscriber{
        id: infoSubscriber
        topic: "/parser/gui_info"
        text:""
        onTextChanged:{
            onParser(text)
        }
    }
    */
    WebSocket {
        id: socket
        url: "ws://146.151.105.145:49152"
        //url: "ws://0.0.0.0:49155"
        onTextMessageReceived: {
            if(message.startsWith("event:"))
                onEvent(message.substring("event:".length))
            if(message.startsWith("parser:"))
                onParser(message.substring("parser:".length))
        }
        onBinaryMessageReceived: {
            map.bArray = message
            map.update()
        }

        onStatusChanged:{
            if (socket.status == WebSocket.Error) {
                 console.log("Error: " + socket.errorString)
                 //socketChecker.restart()
             } else if (socket.status == WebSocket.Open) {

             } else if (socket.status == WebSocket.Closed) {
                 console.log("Socket closed")
             }
        }
        active: true
    }

    function onParser(text){
        if(text === "bad_depth"){
            warningDepth.visible = true
            globalStates.state = "command"
            warningReach.visible = false
            return
        }
        if(text === "out_of_reach"){
            console.log("got it")
            warningReach.visible = true
            warningDepth.visible = false
            globalStates.state = "command"
            return
        }
        if(text === "good_move"){
            warningDepth.visible = false
            warningReach.visible = false
            return
        }
        var cmd = text.split(";")
        if(cmd[0] === "poi" && globalStates.state === "command"){
            pois.cmd = cmd
        }
        if(cmd[0] === "panda_pose"){
            var pose = cmd[1].split(",")
            var panda_pose =[]
            for(var i=0;i<pose.length;i++){
                panda_pose.push(parseFloat(pose[i]))
            }
            controlPanel.filter_button(panda_pose)
        }
    }

    function onEvent(text){
        console.log("event")
        if(text === "start_exec"){
            moving = true
        }
        if(text === "motion_finished"){
            moving = false
            for(var i =0; i < figures.children.length; i++){
                if(figures.children[i].testDelete()){
                    try{
                        figures.children[i].destroy()
                    }
                    catch(err){
                        ;
                    }
                }
            }
            globalStates.state = "command"
            delayedTimerUpdateActions.start()
            return
        }
        var cmd = text.split(";")
        if (cmd[0] === "action_finished"){
            cmd = cmd[1].split(":")
            var name = cmd[0]
            var target = cmd[1]
            for (var i = 0; i<figures.children.length;i++){
                if(figures.children[i].testDone(name, target)){
                    gamePlan.update()
                    break
                }
            }
        }
        if (cmd[0] === "wait"){
            if(globalStates.state !== "command"){
                waitGui.visible = true
                for(var j =0;j<pois.children.length;j++){
                    var poi = pois.children[j]
                    if(poi.name === cmd[1]){
                        roi.poi = poi
                        roi.x = poi.x-roi.width/2
                        roi.y = poi.y-roi.width/2
                    }
                }
            }
        }
        if (cmd[0] === "fd_takeover"){
            globalStates.state = "force_dimension"
        }
        /*if (cmd[0] === "z_or"){
            // Use commanded theta and add absolute difference, not relative! Use orientation on click?
            var theta = -parseFloat(cmd[1])
            rotationSlider.theta_r = theta*180/Math.PI
            theta += rotationSlider.theta_h/180.*Math.PI
            dial.x=rotationSlider.width/2*(1+Math.sin(theta))-dial.width/2
            dial.y=rotationSlider.height/2*(1-Math.cos(theta))-dial.height/2
            displayView.rotation = theta/Math.PI*180
            return
            var theta=Math.atan2(dialCenter.y-rotationSlider.width/2,dialCenter.x-rotationSlider.width/2)
            theta += parseFloat(cmd[1])/25.
        }*/

    }

    Recognizer{
        id: recognizer
    }

   Column{
        id: palette
        visible: false
        anchors.top: parent.top
        anchors.topMargin: parent.height/10
        anchors.right: parent.right
        anchors.rightMargin: parent.width/10
        spacing: 10
        PaletteElement{index:0}
        PaletteElement{index:1}
        PaletteElement{index:2}
        PaletteElement{index:3}
    }

    TemplateLoader{
        visible: false
        id: templateLoader
    }

    Timer{
        id: timerUpdateActions
        interval: 100
        onTriggered:{
            gamePlan.update()
        }
    }
    Timer{
        id: delayedTimerUpdateActions
        interval: 500
        onTriggered:{
            gamePlan.update()
        }
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "gestureEdit"
                PropertyChanges { target: gestureGui; visible: true }},
            State {name: "command"
                PropertyChanges { target: commandGui; visible: true }},
            State {name: "visualization"
                PropertyChanges { target: lockViewButton; visible: true }
                PropertyChanges { target: goToButton; visible: true }
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                //PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: gamePlan; visible: false }
            },
            State {name: "simulation"
                PropertyChanges { target: map; toLoad: virtualCamera}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                //PropertyChanges { target: drawingarea; enabled: false }
            },
            State {name: "execution"
                //PropertyChanges { target: map; toLoad: "image://rosimage/virtual_camera/image"}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                //PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: executionGui; visible: true}
            },
            State {name: "edit"
                PropertyChanges { target: map; toLoad: virtualCamera}
                PropertyChanges { target: pois; visible: true }
                PropertyChanges { target: figures; visible: true}
                //PropertyChanges { target: drawingarea; enabled: true }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: executionGui; visible: false}
                PropertyChanges { target: stopEditButton; visible: true}
                PropertyChanges { target: pauseButton; visible: true}
            },
            State {name: "force_dimension"
                //PropertyChanges { target: map; toLoad: "image://rosimage/virtual_camera/image"}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                //PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: fdGui; visible: true}
            }
    ]
        onStateChanged: {
            switch (globalStates.state){
            case "execution":
            //    pauseButton.name = "pause"
                break
                case "gestureEdit":
                    break
                case "command":
                    waitGui.visible = false
                    for (var i = 0; i<figures.children.length;i++)
                            figures.children[i].doneSim = false
                    gamePlan.update()
                    break
                case "visualization":
                    break
            }
        }
    }

    Component.onCompleted: {
        globalStates.state = "command"
        pubCommand("init_gui")
        pubEvent("starting_authoring")

    }
    Component.onDestruction: {
        pubCommand("remove;all")
        pubEvent("closing")
    }
}
