import QtQuick 2.14
import QtQuick.Controls 1.4

Item {

    id: item
    anchors.fill: parent
    property color objColor: "red"
    property string name: ""
    property int index: 0
    property var snappedPoi: null
    property bool currentItem: false
    property var snap: snapPoint
    property var indexes: null
    property var action: "undefined"
    property var target: "undefined"
    property var targetDisplay: "undefined"
    property bool done: false

    opacity: 1
    z:10
    visible: true
    Item{
        id: snapPoint
        x:0
        y:0
        Rectangle{
            id: snapRect
            color: objColor
            width: 20
            height: width
            radius: width/2
            x:-width/2
            y:-height/2
            opacity: 1
        }
        onXChanged: {
            timerTarget.start()
        }
    }
    Label{
        z:30
        id: actionDisplay
        text:action+" "+targetDisplay
        x:snapPoint.x-snapRect.width
        y:snapPoint.y-3*snapRect.height
        font.bold: true
        font.pixelSize: 40
        style: Text.Outline
        styleColor: "black"
        color: "white"
    }

    Timer{
        id:timerTarget
        interval: 100
        onTriggered: {
            if(snappedPoi !== null){
                target = snappedPoi.name+"_"+snappedPoi.index.toString()
            }
            else{
                target = getPoints()
            }
        }
    }

    function snapTo(x,y){
        snapPoint.x=x
        snapPoint.y=y
    }

    Component.onDestruction: {
        commandPublisher.text="remove;"+name+":"+parseInt(index)
        indexes.splice(indexes.indexOf(index), 1);
        timerUpdateActions.restart()
    }
    Component.onCompleted: {
        objColor = figures.colors[index]
        currentItem = true
    }

    function selected(val){
        currentItem = val
    }
    function setIndex(val){
        index = val
        currentItem = false
        currentItem = true
        timerUpdateActions.restart()
    }
    function setIndexes(val){
        indexes = val
    }

    onTargetChanged: {
        if (name === "surface")
            targetDisplay = figures.colorNames[index]+" Area"
        else
            targetDisplay = target.replace("_"," ")
        actionList.update()
    }

    onCurrentItemChanged: {
        if(currentItem){
            objColor = Qt.lighter(objColor,1.3)
            if(figures.currentItem !== null && figures.currentItem !== item)
                figures.currentItem.selected(false)
            figures.currentItem = item
            paint()
        }
        else{
            objColor = figures.colors[index]
            paint()
        }
    }
}
