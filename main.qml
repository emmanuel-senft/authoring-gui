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
    title: qsTr("Cartesian GUI")
    property var selected: ""
    property bool grasped: false
    property bool simu: false

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
            property string realCamera: simu ? virtualCamera : "image://rosimage/rgb/image_raw"
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
        }
    }
    Label{
        id: warningNumber
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Please enter numbers"
        font.pixelSize: 50
        color: "red"
        visible: false
    }
    Label{
        id: warningReach
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height/10.
        text: "Outside of robot reach"
        font.pixelSize: 50
        color: "red"
        visible: false
    }


    Item{
        id:cartesianPanel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 3*parent.width/8
        anchors.top: parent.top
        anchors.topMargin: height/8
        width: parent.width/5
        height: parent.height*3/5
        Rectangle{
            id: commandBackground
            anchors.fill: parent
            color: "white"
            border.color: "steelblue"
            opacity: .5
            radius: width/10
        }
        Text{
            id: title
            text: "End-effector position"
            renderType: Text.NativeRendering
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height*2/10
            font.family: "Helvetica"
            font.pointSize: map.width/80
            color: "black"
        }

        Column{
            id:dimensions
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            height: parent.height*6/10
            width: parent.width*8/10
            spacing: height/20
            CartesianCommand{
                id:x
                label: "x:"
            }
            CartesianCommand{
                id:y
                label: "y:"
            }
            CartesianCommand{
                id:z
                label: "z:"
            }
            CartesianCommand{
                id:rX
                parameterType: "angle"
                label: "RX:"
            }
            CartesianCommand{
                id:rY
                parameterType: "angle"
                label: "RY:"
            }
            CartesianCommand{
                id:rZ
                parameterType: "angle"
                label: "RZ:"
            }
        }
        GuiButton{
            id: run
            name: "play"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: dimensions.bottom
            onPressedChanged: {
                if(pressed){
                    send_pose()
                }
            }
        }
    }
    function send_pose(){
        var msg = "panda_goal;"
        for(var i=0;i<dimensions.children.length;i++){
            msg+=dimensions.children[i].text+","
            dimensions.children[i].edited = false
            dimensions.children[i].focus = false
        }
        commandPublisher.text = msg.slice(0,-1)
        globalStates.state = "execution"
    }

    Item{
        id:commandGui
        anchors.fill: parent
    }
    MouseArea {
        id: focusMouse
        anchors.fill: parent
        onPressed: {
            focus = true
            mouse.accepted = false
        }
    }
    ControlPanel{
        id:controlPanel
    }

    StateGroup {
        id: globalStates
        states: [
            State {name: "command"},
            State {name: "execution"}//; PropertyChanges { target: cartesianPanel; visible: false}}
    ]
        onStateChanged: {
            switch (globalStates.state){
            case "execution":
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
            var cmd = text.split(";")
            if(cmd[0] === "panda_pose"){
                var pose = cmd[1].split(",")
                var panda_pose =[]
                for(var i=0;i<dimensions.children.length;i++){
                    dimensions.children[i].setText(pose[i])
                    panda_pose.push(parseFloat(pose[i]))
                }
                controlPanel.filter_button(panda_pose)

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
