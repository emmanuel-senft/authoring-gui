import QtQuick 2.0

import Box2D 2.0

import Ros 1.0

TouchPoint {

    id: touch

    property string name: "touch"
    property bool drawing: false

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

    property MouseJoint joint: MouseJoint {
        bodyA: anchor
        dampingRatio: 1
        maxForce: 1
    }

    onXChanged: {
        // (only add stroke point in one dimension (Y) to avoid double drawing)
    }

    onYChanged: {
        if (drawing) {
            currentStroke.push(Qt.point(x,y));
            drawingarea.update();
        }
    }
    onPressedChanged: {

        if (pressed) {
            getImagePosition(x,y)
            return
            console.log("pressed")
            var obj = drawingarea.childAt(x, y);
            console.log(obj.objectName)

            if (drawingarea.drawEnabled) {
                currentStroke = [];
                color = drawingarea.fgColor;
                drawing = true;
                console.log("new stroke")
                drawingarea.newStroke()
                currentStroke.push(Qt.point(x,y));
                drawingarea.update();
            }

        }
        else { // released
            console.log("release")
            if(drawing) {
                drawing = false;
                if (drawingarea.drawEnabled) {
                    drawingarea.finishStroke(currentStroke);
                }
                currentStroke = [];
            }
        }
    }
    function getImagePosition(x,y){
        var off_x = (map.width-map.paintedWidth)/2
        var off_y = (map.height-map.paintedHeight)/2
        var imx = (x - off_x)/map.paintedWidth * map.sourceSize.width;
        var imy = (y - off_y)/map.paintedHeight * map.sourceSize.height;
        var str = "x:"+parseInt(imx)+":y:"+parseInt(imy)
        commandPublisher.text=str
    }
}

