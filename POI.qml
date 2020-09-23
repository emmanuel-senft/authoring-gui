import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: poi
    property var type: "poi"
    property int index: 0
    property var name: type+"_"+index
    property color color: "red"
    property bool enabled: true
    property bool pulled: false
    visible: enabled
    width: type === "hole" ? 10 : map.width/40

    Rectangle{
        x:-width/2
        y:-height/2
        width: parent.width
        height: width
        radius: poi.type === "screw" ? width/2 : 0
        color: parent.color
        border.color: "black"
        border.width: width/15
    }
    opacity: .5
}
