import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: poi
    property var type: "poi"
    property int index: 0
    property var name: type+"_"+index
    property color color: "red"
    property bool updated: true
    width: 20
    Rectangle{
        x:-width/2
        y:-height/2
        width: parent.width
        height: width
        radius: width/2
        color: parent.color
    }
    opacity: .5
}
