import QtQuick 2.12
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.15


import Ros 1.0

Window {
    id: window
    visible: true
    width: 2736
    height: 1824
    title: qsTr("Authoring GUI")
    property var selected: ""
    property bool grasped: false
    property var pandaPose: Qt.vector3d(.36,0,.56)
    Item {
        id: displayView
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: width*3/4
        Image {
            id: map
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            property string toLoad: realCamera
            property string virtualCamera: "image://rosimage/virtual_camera/image_repub"
            //property string realCamera: "res/default.jpg"
            property string realCamera: virtualCamera
            //property string realCamera: "image://rosimage/rgb/image_raw"
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
            Item{
                id: pois
                anchors.fill:parent
                visible: actionPanel.visible && hidePoisButton.show

                property var scaleX: map.sourceSize.width / map.paintedWidth
                property var scaleY:map.sourceSize.height / map.paintedHeight
                property var cmd: null
                function addPoi(type,id,x,y){
                    var component = Qt.createComponent("POI.qml")
                    var color = "red"
                    if(type === "screw")
                        color = "yellow"
                    if(type === "box")
                        color = "grey"
                    if(type === "hole"){
                        return
                        color = "white"
                    }
                    if(type === "drawer")
                        color = "black"
                    if(type === "edge")
                        color = "blue"
                    var poi = component.createObject(pois, {type:type,index:id,objColor:color,center:Qt.point(x,y)})
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

                    for(var i =0;i<pois.children.length;i++){
                        pois.children[i].updated = false
                    }

                    for(var i=0;i<cmd.length-1;i++){
                        var info = cmd[i+1].split(":")
                        var type = info[0]
                        var id = parseInt(info[1])
                        var coord = info[2]
                        var x = parseInt(coord.split(",")[0])/scaleX
                        var y = parseInt(coord.split(",")[1])/scaleY
                        var new_poi = true

                        for(var j =0;j<pois.children.length;j++){
                            var poi = pois.children[j]
                            if(poi.type === type && poi.index === id){
                                poi.center.x = x
                                poi.center.y = y
                                new_poi = false
                                poi.updated = true
                                break
                            }
                        }
                        if(new_poi)
                            pois.addPoi(type, id, x, y)
                    }

                    for(var i = pois.children.length; i > 0 ; i--) {
                      if (pois.children[i-1].updated === false){
                          pois.children[i-1].destroy()
                      }
                    }
                }
            }

            MouseArea{
                anchors.fill: parent
                onPressed:{
                    if(globalStates.state === "execution")
                        return
                    target.visible = true
                    target.x = mouseX
                    target.y = mouseY
                    var item = pois.childAt(mouseX,mouseY)
                    console.log(item)
                    if (item === null){
                        selected = "unknown"
                    }
                    else{
                        selected = item
                    }
                }
            }
            Item{
                id:target
                width: parent.width/40
                height: width
                visible: false
                z:2
                Rectangle{
                    width: parent.width
                    height: width
                    radius: width/2
                    color:  "transparent"
                    border.color: "red"
                    border.width: width/10
                    x:-width/2
                    y:-height/2
                }
                function getCoord(){
                    var scaleX = map.sourceSize.width / map.paintedWidth
                    var scaleY = map.sourceSize.height / map.paintedHeight
                    return parseInt(x*scaleX)+','+parseInt(y*scaleY)
                }
            }
        }
    }

    Label{
        id: warningDepth
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Bad depth, please move target"
        font.pixelSize: 50
        color: "red"
        visible: false

    }

    onSelectedChanged: {
        var type = ""
        if(typeof selected === "string")
            type = selected
        else
            type = selected.type
        for (var i=0;i<actionList.children.length;i++){
            if(actionList.children[i].usableItem.indexOf(type) !== -1){
                actionList.children[i].visible = true
            }
            else
                actionList.children[i].visible = false
        }
    }

    Item{
        id:commandGui
        anchors.fill: parent
    }
    Item{
        id:actionPanel
        anchors.right: parent.right
        anchors.rightMargin: width/10
        anchors.topMargin: anchors.rightMargin
        anchors.top: parent.top
        width: parent.width/5
        height: parent.height*2/3
        Rectangle{
            id: actionBackground
            anchors.fill: parent
            color: "white"
            border.color: "steelblue"
            opacity: .5
            radius: width/10
        }
        MouseArea{
            anchors.fill: parent
        }

        Label{
            id: title
            visible: true
            x:parent.width/20
            y:x
            font.pixelSize: map.width/50
            height: map.height/30
            text: "Possible actions"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        Label{
            id: objectSelected
            x:parent.width/20
            anchors.top: title.bottom
            font.pixelSize: map.width/50
            height: map.height/30
            text: "on "+selected.type
            visible: selected !== "none"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        Column{
            id: actionList
            width: parent.width
            height: parent.height*9/10
            y: parent.height/6
            spacing: height/40
            ActionButton{
                text: "Move to target"
                usableItem: ["unknown"]
                parameterType: "Angle"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;MoveContact:"+target.getCoord()+","+parseInt(value)
                }
            }
            ActionButton{
                text: grasped ? "Place at target" : "Pick at target"
                usableItem: ["unknown"]
                parameterType: "Angle"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;"+text.split(" ")[0]+":"+target.getCoord()+","+parseInt(value)
                }
            }
            ActionButton{
                id: forward
                text: "Move forward"
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton){
                        console.log(value*25.4)
                        commandPublisher.text = "direct;Go:"+parseInt(value*25.4)+",0,0"
                    }
                }
            }
            ActionButton{
                text: "Move back"
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Go:-"+parseInt(value*25.4)+",0,0"
                }
            }
            ActionButton{
                id: up
                text: "Move up"
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Go:0,0,"+parseInt(value*25.4)
                }
            }
            ActionButton{
                id: down
                text: "Move down"
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Go:0,0,-"+parseInt(value*25.4)
                }
            }
            ActionButton{
                text: "Pull"
                usableItem: ["drawer"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Pull:"+selected.name
                }
            }
            ActionButton{
                text: "Push"
                usableItem: ["drawer"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Push:"+selected.name
                }
            }
            ActionButton{
                text: "Move right"
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Go:0,-"+parseInt(value*25.4)+",0"
                }
            }
            ActionButton{
                text: "Move left"
                visible: false
                usableItem: ["none"]
                parameterType: "Distance"
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Go:0,"+parseInt(value*25.4)+",0"
                }
            }
            ActionButton{
                text: "Place in"
                visible: false
                usableItem: ["box"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Place:"+selected.name
                }
            }
            ActionButton{
                text: "Pick"
                usableItem: ["screw"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Pick:"+selected.name
                }
            }
            ActionButton{
                text: "Screw"
                usableItem: ["screw"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Screw:"+selected.name
                }
            }
            ActionButton{
                text: "Unscrew"
                usableItem: ["screw"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;Unscrew:"+selected.name
                }
            }
            ActionButton{
                text: grasped ? "Release" : "Grasp"
                usableItem: ["none"]
                onClicked: {
                    if(mouse.button & Qt.LeftButton)
                        commandPublisher.text = "direct;"+text
                }
            }
        }
        GuiButton{
            id: cancel
            anchors.bottom: parent.bottom
            anchors.bottomMargin: width/2
            anchors.horizontalCenter: parent.horizontalCenter
            name: 'add'
            rotation: 45
            color: "red"
            visible: target.visible

            onPressedChanged: {
                target.visible = false
                selected = "none"
            }
        }
    }


    GuiButton{
        id: resetButton
        anchors.right: displayView.right
        anchors.rightMargin: width/2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width
        z:10
        name: "reset"
        onClicked:{
            commandPublisher.text = "reset_position"
        }
        visible: globalStates.state === "command"
    }

    GuiButton{
        id: stopButton
        z:10
        anchors.horizontalCenter: resetButton.horizontalCenter
        anchors.verticalCenter: resetButton.verticalCenter
        name: "stop"
        color: "red"
        onClicked:{
            commandPublisher.text = "stop"
            globalStates.state = "drawing"
        }
        visible: globalStates.state === "execution"
    }
    GuiButton{
        id: hidePoisButton
        z:10
        anchors.top: actionPanel.top
        anchors.left: displayView.left
        anchors.leftMargin: width
        name: show ? "hide" : "show"
        property bool show: true
        onClicked:{
            show = ! show
        }
        visible: globalStates.state === "command"
    }
    ArrowPad{
        id: arrowPad
        z:11
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width / 15 + width/2
        anchors.verticalCenter: resetButton.verticalCenter
        visible: actionPanel.visible
    }
    ArrowPad{
        id: arrowPadOther
        z:11
        type: "other"
        //width: map.width/14
        visible: actionPanel.visible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: resetButton.verticalCenter
    }
    ArrowPad{
        id: arrowPadAngle
        z:11
        visible: actionPanel.visible
        type: "rotation"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width / 15 - width/2
        anchors.verticalCenter: resetButton.verticalCenter
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "command"},
            State {name: "execution"; PropertyChanges { target: actionPanel; visible: false}}
    ]
        onStateChanged: {
            switch (globalStates.state){
            case "execution":
                target.visible = false
                selected = "none"
            break
            }
        }
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
                pois.cmd = cmd
            }
            if(cmd[0] === "panda_pose"){
                var pose = cmd[1].split(",")
                pandaPose.x = parseFloat(pose[0])
                pandaPose.y = parseFloat(pose[1])
                pandaPose.z = parseFloat(pose[2])
                if(pandaPose.z > .6){
                   arrowPadOther.setEnabled("down", false)
                   up.enabled = false
                }
                else{
                    arrowPadOther.setEnabled("down", true)
                    up.enabled = true
                }
                if(pandaPose.x > .55){
                   arrowPad.setEnabled("up", false)
                   forward.enabled = false
                }
                else{
                    arrowPad.setEnabled("up", true)
                    forward.enabled = true
                }
                if(pandaPose.x**2 + pandaPose.z**2 > .56){
                    arrowPad.setEnabled("up", false)
                    forward.enabled = false
                    arrowPadOther.setEnabled("down", false)
                    up.enabled = false
                }


                for(var i =0;i<pois.children.length;i++){
                    pois.children[i].update_shape()
                }
            }
        }
    }
    RosStringSubscriber{
        id: pandaSubscriber
        topic: "/panda/events"
        text:""
        onTextChanged:{
            if(text === "release_finished"){
                grasped = false
                return
            }
            if(text === "grasp_finished"){
                grasped = true
                return
            }
        }
    }
    RosStringSubscriber{
        id: eventsSubscriber
        topic: "/event"
        text:""
        onTextChanged:{
            if(text === "start_exec"){
                globalStates.state = "execution"
            }
            if(text === "motion_finished"){
                globalStates.state = "command"
            }
        }
    }


    Component.onCompleted: {
        commandPublisher.text="init_gui"
        globalStates.state = "command"
        selected = "none"
    }
}
