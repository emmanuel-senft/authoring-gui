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
    /*Item {
        id: simulatorView
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width/5
        height: parent.height/5
        z:20
        Image {
            id: simu
            fillMode: Image.PreserveAspectFit
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            source: "image://rosimage/virtual_camera/image"
            cache: false
            Timer {
                id: imageLoaderSimu
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    simu.source = "";
                    simu.source = "image://rosimage/virtual_camera/image";
                    interval = 100
                }
            }
        }
    }*/
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
                interval: 1000
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
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            lineWidth: 10

            fgColor: "steelblue"

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
            anchors.fill: parent

            touchPoints: [
                TouchJoint {id:touch1;name:"touch1"},
                TouchJoint {id:touch2;name:"touch2"},
                TouchJoint {id:touch3;name:"touch3"},
                TouchJoint {id:touch4;name:"touch4"},
                TouchJoint {id:touch5;name:"touch5"},
                TouchJoint {id:touch6;name:"touch6"}
            ]
        }

        MouseArea{
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            onClicked: {
                var point = figures.getImagePosition(mouseX,mouseY)
                var str = "click:"+parseInt(point.x)+":"+parseInt(point.y)
                commandPublisher.text=str
                console.log(str)
            }
        }
    }

    Item{
        id:gestureGui
        anchors.fill: parent

        Button{
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
        Button{
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
                fileio.write("/home/senft/src/authoring-gui/res/gestures.json",string)
            }
        }
    }
    Item{
        id:userGui
        anchors.fill: parent

        Button{
            id: commandButton
            width: parent.width/10
            height: parent.height/10
            z:10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: -parent.width/4
            text: "Send Command"
            onClicked:{
                figures.sendCommand("exec");
            }
        }
        Button{
            id: simulateButton
            width: parent.width/10
            height: parent.height/10
            z:10
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height
            anchors.horizontalCenter: parent.horizontalCenter
            text: "simulate Command"
            onClicked:{
                figures.sendCommand("sim");
            }
        }
        Button{
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
    Button{
        id: stateButton
        width: parent.width/10
        height: parent.height/10
        z:10
        anchors.left: parent.left
        anchors.top: parent.top
        text: "Switch mode"
        onClicked:{
            if (globalStates.state === "gestureEdit")
                globalStates.state = "user"
            else
                globalStates.state = "gestureEdit"
        }
    }
    Button{
        id: viewButton
        width: parent.width/10
        height: parent.height/10
        z:10
        anchors.right: parent.right
        anchors.top: parent.top
        text: "Switch view"
        onClicked:{
            if (map.toLoad === "image://rosimage/virtual_camera/image")
                map.toLoad = "image://rosimage/rgb/image_raw"
            else
                map.toLoad = "image://rosimage/virtual_camera/image"
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

    TFListener {
        id: frameManager
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
        id: feedbackSubscriber
        topic: "/parser/gui_info"
        text:""
        onTextChanged:{
            console.log(text)
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
                pois.cmd = cmd
            }

        }
    }

    Recognizer{
        id: recognizer
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "gestureEdit"},
            State {name: "user"}
    ]
        onStateChanged: {
            switch (globalStates.state){
                case "gestureEdit":
                    gestureGui.visible = true
                    userGui.visible = false
                    break
                case "user":
                    gestureGui.visible = false
                    userGui.visible = true
                    break
            }
        }
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
            console.log(handler.translation)
            commandPublisher.text = "mouse;"+parseInt(handler.translation.y)+":"+parseInt(handler.translation.x)+":"+parseInt(100*(handler.scale-1))+":"+parseInt(handler.rotation)
        }

    }
    Item{
        id: pois
        property var cmd: null
        function addPoi(name,id,x,y){
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
                console.log(pois.children.length)
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
            console.log(figures.children.length)
            for(var i=0;i<figures.children.length;i++){
                var action ={}
                var surface = false
                var fig = figures.children[i]
                if(fig.name === "circle")
                    action.name = "Pick"
                if(fig.name === "arrow")
                    action.name = "Place"
                if(fig.name === "spiral")
                    action.name = "Screw"
                if(fig.name === "surface"){
                    action.name = "Wipe"
                    surface = true
                }
                if(fig.snappedPoi !== null){
                    action.item = fig.snappedPoi.name+"_"+fig.snappedPoi.index.toString()
                }
                else{
                    action.item = fig.getPoints()
                }
                action.order = fig.index
                action.color = fig.objColor
                console.log(action.name)

                actions.push(action)
            }
            if(actions.length != figures.children.length)
                return
            actions.sort(compare)
            actionList.clear()
            for(var i=0;i<actions.length;i++){
                console.log(action)
                actionList.append(actions[i])
            }
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
                str+=";"+actionList.get(i).name+":"+actionList.get(i).item
            }
            commandPublisher.text=str
        }
    }
    Timer{
        id: timerUpdateActions
        interval: 100
        onTriggered: actionList.update()
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
                    Text { text: '<b>'+name+':</b> ' + item

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


    Component.onCompleted: {
        globalStates.state = "user"
    }
    Component.onDestruction: {
        commandPublisher.text="remove;all"
    }
}
