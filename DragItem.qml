import QtQuick 2.12
import QtQuick.Controls 1.4

Item {

    id: item
    anchors.fill: parent
    property color objColor: "red"
    property string name: ""
    property int index: 0
    property var snappedPoi: null
    property bool currentItem: false
    property var snap: snapRect
    property var indexes: null

    opacity: 1
    z:10
    visible: true

    Rectangle{
        id: snapRect
        color: objColor
        width: 20
        height: width
        radius: width/2
        x:center.x
        y:center.y
        opacity: 1
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
        console.log(val)
        currentItem = val
    }
    function setIndex(val){
        index = val
        currentItem = false
        currentItem = true
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
            console.log("resetting color")
        }
    }
}
