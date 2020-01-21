import QtQuick 2.2
import Box2D 2.0

import Ros 1.0

Item {
        id:item
        width: 20
        height: width
        rotation: 0

        objectName: "interactive"


        property var boundingbox:
            Polygon {
                id:bbpoly
                vertices: [
                    Qt.point(origin.x, origin.y),
                    Qt.point(origin.x + width * bbratio, origin.y),
                    Qt.point(origin.x + width * bbratio, origin.y + height * bbratio),
                    Qt.point(origin.x, origin.y + height * bbratio),
                ]
                density: 1
                friction: 1
                restitution: 0.1
            }

        property alias body: cubeBody
        property double bbratio: 1 // set later (cf below) once paintedWidth is known
        Body {
                id: cubeBody

                target: item
                world: physicsWorld
                bodyType: Body.Dynamic

                Component.onCompleted: {
                    cubeBody.addFixture(item.boundingbox);
                }

                angularDamping: 5
                linearDamping: 5
        }
        Item {
            // this item sticks to the 'visual' origin of the object, taking into account
            // possible margins appearing when resizing
            id: origin
            rotation: parent.rotation
            x: parent.x + (parent.width - parent.paintedWidth)/2
            y: parent.y + (parent.height - parent.paintedHeight)/2
        }
//   PinchArea {
//           anchors.fill: parent
//           pinch.target: parent
//           pinch.minimumRotation: -360
//           pinch.maximumRotation: 360
//           //pinch.minimumScale: 1
//           //pinch.maximumScale: 1
//           pinch.dragAxis: Pinch.XAndYAxis

//           MouseArea {
//                   anchors.fill: parent
//                   drag.target: item
//                   scrollGestureEnabled: false
//           }
//   }

    function isIn(tx, ty) {
        return (tx > x) && (tx < x + width) && (ty > y) && (ty < y + height);
    }

}
