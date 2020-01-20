import QtQuick 2.7
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4

import Box2D 2.0

import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:1920
    height: 1080

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
        Recognizer{
            id: recognizer
        }
    }
    Body {
        id: anchor
        world: physicsWorld
    }
    World {
        id: physicsWorld
        gravity: Qt.point(0.0, 0.0);

    }
    TFListener {
        id: frameManager
    }
    Item{
        id: figures
        property var listFigure: []
    }

    Component.onCompleted: {
        var data=fileio.read()
        console.log(data)
        recognizer._r.Init(data);
    }
    Component.onDestruction: {
        var string = recognizer._r.GetUserGestures()
        fileio.write("/home/senft/src/authoring-interface/res/gestures2.json",string)
    }

    function createFigure(name, points){
        var x=window.width
        var y= window.height
        var max_x=0
        var max_y= 0
        for (var i=0;i<points.length;i++){
            x=Math.min(x,points[i].X)
            max_x=Math.max(max_x,points[i].X)
            y=Math.min(y,points[i].Y)
            max_y=Math.max(max_y,points[i].Y)
            console.log(points[i].X)
        }
        var width = (max_x-x)
        var height = (max_y-y)
        if (name === "circle"){
            var component = Qt.createComponent("DragRectangle.qml");
            width = Math.max(width,height)
            var figure = component.createObject(figures, {x:x,y:y,width:width,height:width,z:10,radius:width/2});
            //figures.listFigure.push(figure);
            console.log(x+" "+max_x)
            if (figure == null) {
                // Error Handling
                console.log("Error creating object");
            }
        }
        //if (name === "rec"){
        else{
            var component = Qt.createComponent("DragRectangle.qml");
            var figure = component.createObject(figures, {x:x,y:y,width:width,height:height,z:10});
            //figures.listFigure.push(figure);
            console.log(x+" "+max_x)
            if (figure == null) {
                // Error Handling
                console.log("Error creating object");
            }
        }
    }
    RosStringPublisher{
        id: commandPublisher
        topic: "/gui/command"
        text:""
    }
}
