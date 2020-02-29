import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4


import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:3020
    height: 1880

    property int prevWidth:800
    property int prevHeight:600
    property var initTime: 0
    property bool autonomous: false
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
        property bool bgHasChanged: true
        anchors.fill: parent
        Image {
            id: map
            fillMode: Image.PreserveAspectFit
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            property string toLoad: "image://rosimage/rgb/image_raw"
            source: toLoad
            cache: false
            Timer {
                id: imageLoader
                interval: 100
                repeat: true
                running: true
                onTriggered: {
                    map.source = "";
                    map.source = map.toLoad;
                    interval = 100
                }
            }
            onPaintedWidthChanged: {
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
            width: parent.width/10
            height: parent.height/10
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
            width: parent.width/10
            height: parent.height/10
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
        anchors.fill: parent
        visible: true
        GuiButton{
            id: viewButton
            width: parent.width/10
            height: parent.height/10
            z:10
            visible: true
            anchors.right: parent.right
            anchors.top: parent.top
            text: "Switch view"
            onClicked:{
                if (globalStates.state === "visualization"){
                    globalStates.state = "drawing"
                    map.toLoad = "image://rosimage/rgb/image_raw"
                }
                if (globalStates.state === "drawing"){
                    globalStates.state = "visualization"
                    map.toLoad = "image://rosimage/virtual_camera/image"
                }
                if (globalStates.state === "simulation"){
                    globalStates.state = "drawing"
                }
            }
        }
        GuiButton{
            id: lockViewButton
            width: parent.width/10
            height: parent.height/10
            visible: false
            z:10
            anchors.left: viewButton.left
            anchors.top: viewButton.bottom
            anchors.topMargin: height/2
            text: "Lock View"
            onClicked:{
                globalStates.state = "drawing"
            }
        }
    }
    Item{
        id:drawingGui
        anchors.fill: parent
        visible: false

        GuiButton{
            id: commandButton
            width: parent.width/10
            height: parent.height/10
            z:10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            text: "Execute"
            onClicked:{actionList.sendCommand("exec");
            }
        }
        GuiButton{
            id: simulateButton
            width: parent.width/10
            height: parent.height/10
            z:10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Simulate"
            onClicked:{
                 actionList.sendCommand("sim");
                globalStates.state = "simulation"
            }
        }
        GuiButton{
            id: deleteButton
            width: parent.width/10
            height: parent.height/10
            z:10
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: parent.width/4
            anchors.verticalCenter: commandButton.verticalCenter
            text: "Delete"
            onClicked:{
                figures.currentItem.destroy()
                figures.currentItem = null
            }
        }
    }
    GuiButton{
        id: gestureEditButton
        width: parent.width/10
        height: parent.height/10
        z:10
        anchors.left: parent.left
        anchors.top: parent.top
        text: "Switch mode"
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
    }

    RosStringPublisher{
        id: commandPublisher
        topic: "/gui/command"
        text:""
    }

    RosStringSubscriber{
        id: eventsSubscriber
        topic: "/event"
        text:""
        onTextChanged:{
            if(text === "motion_finished" && globalStates.state === 'simulation'){
                for (var i = 0; i<figures.children.length;i++)
                        figures.children[i].done = false
                globalStates.state = "drawing"
                return
            }
            var cmd = text.split(";")
            if (cmd[0] === "action_finished"){
                cmd = cmd[1].split(":")
                var name = cmd[0]
                var target = cmd[1]
                for (var i = 0; i<figures.children.length;i++){
                    var fig = figures.children[i]
                    console.log(fig.action)
                    console.log(fig.target)
                    if(fig.action === name && fig.target === target){
                        console.log("Done")
                        fig.done = true
                        actionList.update()
                    }
                }
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
                console.log(cmd)
                pois.cmd = cmd
            }

        }
    }

    Recognizer{
        id: recognizer
    }


    Item{
        id: virtualMouseCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height/2.
        anchors.right: parent.right
        anchors.rightMargin: parent.width/2.
    }
    Rectangle{
        id:virtualMouse
        visible: false
        x:virtualMouseCenter.x
        y:virtualMouseCenter.y
        width: parent.width/5
        height: width
        color: "red"
        radius: height/2
        PinchHandler {
            id: handler
            onActiveChanged: {
                if(!active){
                    virtualMouse.x=virtualMouseCenter.x
                    virtualMouse.y=virtualMouseCenter.y
                    virtualMouse.scale = 1
                    virtualMouse.rotation = 0
                    commandPublisher.text = "mouse;0:0:0:0:0"
                }
            }
        }
        onXChanged: {
            commandPublisher.text = "mouse;"+parseInt(handler.translation.y)+":"+parseInt(handler.translation.x)+":"+parseInt(100*(handler.scale-1))+":"+parseInt(handler.rotation)
        }

    }
    Item{
        id: pois
        visible: true
        property var cmd: null
        function addPoi(name,id,x,y){
            console.log("Adding poi")
            var component = Qt.createComponent("POI.qml")
            var color = "red"
            if(name === "screw")
                color = "yellow"
            if(name === "hole")
                color = "black"
            var poi = component.createObject(pois, {name:name,index:id,color:color,x:x,y:y})
        }
        function clearPoi(){
            for(var i =0;i<pois.children.length;i++){
                pois.children[i].destroy()
            }
        }

        onCmdChanged: {timerPoi.start()}
        Timer{
            id: timerPoi
            interval: 1500
            onTriggered: {pois.updatePois()}
        }
        function updatePois(){
            clearPoi()
            for(var i=0;i<cmd.length-1;i++){
                var info = cmd[i+1].split(":")
                var name = info[0]
                var id = parseInt(info[1])
                var coord = info[2]
                var x = parseInt(coord.split(",")[0])/map.sourceSize.width * map.paintedWidth + (map.width-map.paintedWidth)/2
                var y = parseInt(coord.split(",")[1])/map.sourceSize.height * map.paintedHeight + (map.height-map.paintedHeight)/2
                pois.addPoi(name, id, x, y)
            }
        }


    }
    Column{
        id: palette
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

    ListModel {
        id: actionList
        function update(){
            var actions = []
            actions.length = 0
            for(var i=0;i<figures.children.length;i++){
                var action ={}
                var fig = figures.children[i]
                action.name = figures.children[i].action
                action.target = figures.children[i].target
                if (action.name === "Wipe")
                    action.targetDisplay = figures.colorNames[figures.children[i].index]+" Area"
                else
                    action.targetDisplay = action.target.replace("_"," ")
                action.order = fig.index
                action.color = fig.objColor
                action.done = fig.done
                console.log(action.name)
                actions.push(action)
            }
            if(actions.length !== figures.children.length)
                return
            actions.sort(compare)
                actionList.clear()
            for(var i=0;i<actions.length;i++){
                actionList.append(actions[i])
            }
            if(globalStates.state === "drawing")
                sendCommand("viz")
        }
        function compare(a, b) {
            if(a.order<b.order)
                return -1
            if(a.order>b.order)
                return 1
            var order = ["Pick","Place","Screw","Wipe"]
            if(order.indexOf(a.name)<order.indexOf(b.name))
                return -1
            return 1
        }
        function sendCommand(type){
            var str=type
            for (var i=0;i<actionList.count;i++) {
                str+=";"+actionList.get(i).name+":"+actionList.get(i).target
            }
            commandPublisher.text=str
        }
    }
    Timer{
        id: timerUpdateActions
        interval: 100
        onTriggered:actionList.update()
    }

    Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height/2
        width: parent.width/10
        z:100

        Component {
            id: actionDelegate
            Item {
                width: 180; height: 80
                Column {
                    Text { text: '<b>'+name+':</b> ' + targetDisplay
                        font.strikeout: done
                    }
                }
            }
        }

        ListView {
            anchors.fill: parent
            model: actionList

            delegate: actionDelegate
            focus: true
        }
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "gestureEdit"
                PropertyChanges { target: gestureGui; visible: true }},
            State {name: "drawing"
                PropertyChanges { target: drawingGui; visible: true }},
            State {name: "visualization"
                PropertyChanges { target: lockViewButton; visible: true }
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: lockViewButton; visible: true }
            },
            State {name: "simulation"
                PropertyChanges { target: map; toLoad: "image://rosimage/virtual_camera/image"}
                PropertyChanges { target: pois; visible: false }
                PropertyChanges { target: figures; visible: false}
                PropertyChanges { target: drawingarea; enabled: false }
                PropertyChanges { target: viewButton; text: "Exit Simulation"}
            }
    ]
        onStateChanged: {
            switch (globalStates.state){
                case "gestureEdit":
                    break
                case "drawing":
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
