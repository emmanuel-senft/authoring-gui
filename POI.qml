import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: poi
    property var type: "poi"
    property int index: 0
    property var name: type+"_"+index
    property bool updated: true
    width: map.width/50
    height: width
    radius: width/2
    opacity: .5
}
