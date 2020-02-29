import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: poi
    property var name: "poi"
    property int index: 0
    property color color: "red"
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
