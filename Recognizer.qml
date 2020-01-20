import QtQuick 2.2
import "QClassifier.js" as QClassifier

Item {
    id:recogniser
    property var _points: new Array();
    property var _strokeID: 0
    property var _r: new QClassifier.QDollarRecognizer();

    function addGesture(name){
        _r.AddGesture(name,_points)
        _strokeID = 0
    }

    function recognize(){
        if (_points.length >= 10) {
            var result = _r.Recognize(_points);
            console.log("Result: " + result.Name + " (" + Math.round(result.Score,2) + ") in " + result.Time + " ms.");
        }
        else {
            console.log("Too little input made. Please try again.");
        }
        _strokeID = 0
        createFigure(result.Name, _points)
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
}
