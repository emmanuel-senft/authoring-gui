import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4


import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    width: 2736
    height: 1824

    property int prevWidth:800
    property int prevHeight:600
    property var initTime: 0
    property bool autonomous: false
    property bool moving: false
   onWidthChanged: {
        prevWidth=width;
        pois.updatePois()
    }
    onHeightChanged: {
        prevHeight=height;
    }

    color: "white"
    title: qsTr("Authoring GUI")

    Item {
        id: displayView
        property int lineWidth: 50
        property color fgColor: "steelblue"
        property bool drawEnabled: true
        property var touchs
        anchors.fill: parent
        Image {
            id: map
            fillMode: Image.PreserveAspectCrop
            anchors.top: parent.top
            width: parent.width
            height: parent.height
            property string toLoad: realCamera
            //property string realCamera: "res/default.jpg"
            property string realCamera: "image://rosimage/rgb/image_raw"
            //property string realCamera: virtualCamera
            property string virtualCamera: "image://rosimage/virtual_camera/image"
            property bool useRealImage: true
            source: toLoad
            cache: false
            horizontalAlignment: Image.AlignLeft
            verticalAlignment: Image.AlignTop
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
        }

        DrawingArea {
            id: drawingarea

            touchs: touchArea

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: parent.rotation
                x: parent.x // + (parent.width - parent.paintedWidth)/2
                y: parent.y //+ (parent.height - parent.paintedHeight)/2
            }
            onDrawEnabledChanged: backgrounddrawing.signal()
        }


        MultiPointTouchArea {
            id: touchArea
            enabled: drawingarea.enabled
            anchors.fill: parent

            touchPoints: [
                TouchJoint {id:touch1;name:"touch1"}
            ]
        }

        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                commandPublisher.text=str
            }
        }
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
            text: "Add Gesture"
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
            text: "Save"
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
        height: parent.height
        width: map.paintedWidth
        color: "transparent"

        GuiButton{
            id: commandButton
            z:10
            width: parent.width/15
            anchors.right: displayArea.right
            anchors.rightMargin: width/2
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            name: "send"
            onClicked:{gamePlan.sendCommand("exec");
                globalStates.state = "execution"
            }
            visible: drawingGui.visible
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
            visible: drawingGui.visible
        }
        GuiButton{
            id: zoomInButton
            z:10
            width: parent.width/25
            anchors.bottom: virtualMouse.top
            anchors.bottomMargin: 1.5*height
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.horizontalCenterOffset: width/1.5
            name: "zoom_in"
            color: "steelblue"
            onClicked:{
                moving = true
                commandPublisher.text = "zoom_in"
            }
            visible: drawingGui.visible
        }
        GuiButton{
            id: zoomOutButton
            z:10
            width: zoomInButton.width
            anchors.verticalCenter: zoomInButton.verticalCenter
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.horizontalCenterOffset: -width/1.5
            name: "zoom_out"
            color: "steelblue"
            onClicked:{
                moving = true
                commandPublisher.text = "zoom_out"
            }
            visible: drawingGui.visible
        }

        VirtualMouse{
            id: virtualMouse
            z:11
            visible: drawingGui.visible
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.bottom: resetButton.top
            anchors.bottomMargin: 1.*resetButton.height
        }
        GuiButton{
            id: resetButton
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: width/2
            z:10
            name: "reset"
            onClicked:{
                globalStates.state = "execution"
                commandPublisher.text = "reset_position"
            }
            visible: drawingGui.visible
        }
        GuiButton{
            id: deleteButton
            z:10

            anchors.bottom: parent.bottom
            anchors.bottomMargin: width/2
            anchors.left: parent.left
            anchors.leftMargin: width/2
            name: "del"
            color: "red"
            onClicked:{
                figures.currentItem.destroy()
                figures.currentItem = null
                for(var i =0; i < figures.children.length; i++){
                    if(figures.children[i].testDelete()){
                        figures.children[i].destroy()
                    }
                }
            }
            visible: drawingGui.visible
        }
        GuiButton{
            id: viewButton
            z:10
            visible: true
            anchors.horizontalCenter: commandButton.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: height/2
            name: "switch"
            color: "#ffc27a"
            onClicked:{
                //console.log(globalStates.state)
                switch(globalStates.state){
                    case "visualization":
                        globalStates.state = "drawing"
                        map.toLoad = map.realCamera
                        commandPublisher.text = "init_gui"
                        break

                    case "drawing":
                        globalStates.state = "visualization"
                        map.toLoad = map.virtualCamera
                        commandPublisher.text = "unlock"
                        break

                    case "simulation":
                        globalStates.state = "drawing"
                        commandPublisher.text = "stop_sim"
                        break

                    case "execution":
                        globalStates.state = "drawing"
                        break
                }
                //console.log(globalStates.state)
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
                globalStates.state = "drawing"
                commandPublisher.text = "lock"
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
                commandPublisher.text = "go"
            }
        }
        GuiButton{
            id: stopButton
            z:10
            visible: executionGui.visible
            anchors.right: parent.right
            anchors.rightMargin: width/2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height/2
            name: "stop"
            color: "red"
            onClicked:{
                commandPublisher.text = "stop"
                globalStates.state = "drawing"
            }
        }
        GuiButton{
            id: editButton
            z:10
            visible: executionGui.visible
            anchors.right: parent.right
            anchors.rightMargin: width/2
            anchors.top: parent.top
            anchors.topMargin: height/2
            name: "edit"
            color: "#ffc27a"
            onClicked:{
                eventPublisher.text = 'start_edit'
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
        }
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
                eventPublisher.text = "gui_takeover"
                globalStates.state = "drawing"
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
        id:drawingGui
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
                globalStates.state = "drawing"
            else
                globalStates.state = "gestureEdit"
        }
    }

    Label{
        id: warningDepth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Bad depth, please move one drawing"
        font.pixelSize: 50
        color: "red"
        visible: false

    }

    Figures {
        id:figures
        z:10
    }

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

    RosStringSubscriber{
        id: eventsSubscriber
        topic: "/event"
        text:""
        onTextChanged:{
            if(text === "start_exec"){
                moving = true
            }
            if(text === "motion_finished"){
                    moving = false
                globalStates.state = "drawing"
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
                if(globalStates.state !== "drawing"){
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

        }
    }
    RosStringSubscriber{
        id: infoSubscriber
        topic: "/parser/gui_info"
        text:""
        onTextChanged:{
            if(text === "bad_depth"){
                warningDepth.visible = true
                return
            }
            if(text === "good_depth"){
                warningDepth.visible = false
                return
            }
            var cmd = text.split(";")
            if(cmd[0] === "poi"){
                //console.log(cmd)
                pois.cmd = cmd
            }

        }
    }

    Recognizer{
        id: recognizer
    }

    Item{
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
                //console.log("adding"+type+id)
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
    }

    Item{
        id: pois
        visible: true
        property var cmd: null
        function addPoi(type,id,x,y){
            //console.log("adding"+type+id)
            var component = Qt.createComponent("POI.qml")
            var color = "red"
            if(type === "screw")
                color = "yellow"
            if(type === "hole")
                color = "white"
            if(type === "pusher")
                color = "black"
            var poi = component.createObject(pois, {type:type,index:id,color:color,x:x,y:y})
        }
        function clearPoi(){
            for(var i =0;i<pois.children.length;i++){
                pois.children[i].destroy()
            }
        }

        onCmdChanged: {timerPoi.start()}
        Timer{
            id: timerPoi
            interval: 500
            onTriggered: {pois.updatePois()}
        }
        function updatePois(){
            //clearPoi()
            if(map.paintedWidth < 1000)
                return
            for(var i=0;i<cmd.length-1;i++){
                var info = cmd[i+1].split(":")
                var type = info[0]
                var id = parseInt(info[1])
                var coord = info[2]
                var x = (1 - parseInt(coord.split(",")[0])/map.sourceSize.width) * map.paintedWidth
                var y = (1 - parseInt(coord.split(",")[1])/map.sourceSize.height) * map.paintedHeight
                if(map.rotation === 0){
                    x = (parseInt(coord.split(",")[0])/map.sourceSize.width) * map.paintedWidth
                    y = (parseInt(coord.split(",")[1])/map.sourceSize.height) * map.paintedHeight
                }
                if(pois.children.length<cmd.length-1)
                    pois.addPoi(type, id, x, y)
                else{
                    for(var j =0;j<pois.children.length;j++){
                        var poi = pois.children[j]
                        if(poi.type === type && poi.index === id){
                            poi.x = x
                            poi.y = y
                        }
                    }
                }
            }
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

    GamePlan{
        id: gamePlan
    }
    TemplateLoader{
        id: templateLoader
    }

    Timer{
        id: timerUpdateActions
        interval: 100
        onTriggered:gamePlan.update()
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "gestureEdit"
                PropertyChanges { target: gestureGui; visible: true }},
            State {name: "drawing"
                PropertyChanges { target: drawingGui; visible: true }
                PropertyChanges { target: resetButton; enabled: true }},
            State {name: "visualization"
                PropertyChanges { target: lockViewButton; visible: true }
                PropertyChanges { target: goToButton; visible: true }
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: gamePlan; visible: false }
            },
            State {name: "simulation"
                PropertyChanges { target: map; toLoad: virtualCamera}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
            },
            State {name: "execution"
                //PropertyChanges { target: map; toLoad: "image://rosimage/virtual_camera/image"}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: executionGui; visible: true}
            },
            State {name: "edit"
                PropertyChanges { target: map; toLoad: virtualCamera}
                PropertyChanges { target: pois; visible: true }
                PropertyChanges { target: figures; visible: true}
                PropertyChanges { target: drawingarea; enabled: true }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: executionGui; visible: false}
                PropertyChanges { target: stopEditButton; visible: true}
            },
            State {name: "force_dimension"
                //PropertyChanges { target: map; toLoad: "image://rosimage/virtual_camera/image"}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: viewButton; visible: false}
                PropertyChanges { target: fdGui; visible: true}
            }
    ]
        onStateChanged: {
            //console.log(globalStates.state)
            switch (globalStates.state){
                case "gestureEdit":
                    break
                case "drawing":
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
        globalStates.state = "drawing"
        commandPublisher.text="init_gui"

    }
    Component.onDestruction: {
        commandPublisher.text="remove;all"
    }
}
