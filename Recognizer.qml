import QtQuick 2.2
import "QClassifier.js" as QClassifier

Item {
    id:recognizer
    property var _points: new Array();
    property var _strokeID: 0
    property var _r: new QClassifier.QDollarRecognizer();

    function addGesture(name){
        _r.AddGesture(name,_points)
        _strokeID = 0
    }

    function recognize(){
        if (_points.length >= 5) {
            var result = _r.Recognize(_points);
            console.log("Result: " + result.Name + " (" + result.Score.toFixed(2) + ") in " + result.Time + " ms.");
            figures.createFigure(result.Name, _points)
        }
        else {
            console.log("Too little input made. Please try again.");
        }
        _strokeID = 0
    }

    function newStroke(x,y){
         if (_strokeID == 0) { // starting a new gesture
             _points.length = 0;
         }
         ++_strokeID;
    }

    function addPoint(x,y){
        _points[_points.length] = new QClassifier.Point(x, y, _strokeID); // append
    }
    Component.onCompleted: {
        var data=fileio.read("/src/authoring-gui/res/gestures.json")
        figures.types = _r.Init(data);
    }

    Component.onDestruction: {
        var string = recognizer._r.GetUserGestures()
        fileio.write("/src/authoring-interface/res/gestures2.json",string)
    }
}
