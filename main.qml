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

}
