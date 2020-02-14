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
            console.log("pressed")
            var obj = figures.childAt(x, y);
            if(obj !== null && figures.toDelete){
                obj.destroy()
                figures.toDelete = false
            }
            else if (drawingarea.drawEnabled) {
                currentStroke = [];
                color = drawingarea.fgColor;
                drawing = true;
                console.log("new stroke")
                drawingarea.newStroke()
                currentStroke.push(Qt.point(x,y));
                recognizer.addPoint(x, y)
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
}
