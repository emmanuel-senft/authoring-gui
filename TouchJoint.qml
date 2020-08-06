import QtQuick 2.0
import Ros 1.0

TouchPoint {

    id: touch

    property string name: "touch"
    property bool drawing: false

    // when used to draw on the background:
    property var currentStroke: []
    property color color: "black"

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
            var obj = figures.childAt(x, y);
            if (drawingarea.drawEnabled) {
                for(var i = 0;i<figures.children.length;i++){
                    if(figures.children[i].name === "rect" && figures.children[i].inHull(Qt.point(x,y)))
                        return
                }
                currentStroke = [];
                color = drawingarea.fgColor;
                drawing = true;
                drawingarea.newStroke()
                currentStroke.push(Qt.point(x,y));
                recognizer.addPoint(x, y)
                drawingarea.update();
            }

        }
        else {
            if(drawing) {
                drawing = false;
                if (drawingarea.drawEnabled) {
                    drawingarea.finishStroke(currentStroke);
                }
                currentStroke = [];
            }
        }
    }
}

