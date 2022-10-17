import QtQuick 2.0

Item{
    id: triggers
    //from: https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
    //property var colors: ["#e6194B", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#42d4f4", "#f032e6", "#bfef45", "#fabebe", "#469990", "#e6beff", "#9A6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#a9a9a9", "#ffffff", "#000000"]
    property var colors: ["#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#42d4f4", "#f032e6", "#bfef45", "#fabebe", "#469990", "#e6beff", "#9A6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#a9a9a9", "#ffffff", "#000000"]
    property var colorNames:["Green", "Yellow", "Blue", "Orange","Purple", "Cyan", "Magenta", "Lime", "Pink","Teal", "Lavender", "Brown", "Beige", "Maroon", "Mint", "Navy", "Grey", "White", "Black"]
    property int trigNum: 0
    property var currentTrig: null
    anchors.fill:parent


    function createTrig(x,y,width,height){
        var component = Qt.createComponent("TriggerArea.qml");
        var p0=Qt.point(x,y)
        var p1=Qt.point(x+width,y)
        var p2=Qt.point(x+width,y+height)
        var p3=Qt.point(x,y+height)
        var trigger = component.createObject(triggers, {index:trigNum,p0Coord:p0,p1Coord:p1,p2Coord:p2,p3Coord:p3});
        currentTrig = trigger
        trigNum +=1
    }
}
