import QtQuick 2.7
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
            source: "image://rosimage/rbg/image_raw"
            cache: false
            Timer {
                id: imageLoder
                interval: 100
                repeat: true
                running: true
                onTriggered: {
                    map.source = "";
                    map.source = "image://rosimage/rgb/image_raw";
                    interval = 100
                }
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
            text: "Send Command"
            onClicked:{
                figures.sendCommand();
            }
        }
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
    Component.onCompleted: {
        globalStates.state = "user"
    }
}
