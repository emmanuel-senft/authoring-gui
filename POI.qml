import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: poi
    x:center.x - width/2
    y:center.y - height/2
    property var type: "poi"
    property int index: 0
    property var name: type+"_"+index
    property bool updated: true
    property var objColor: "white"
    width: map.width/40
    height: width
    radius: type === "screw" ? width/2 : 0
    color: selected === poi ? "red" : objColor
    property var center: Qt.point(0,0)
    opacity: .5
    function update_shape(){
        width = 150*(1-pandaPose.z)
    }
}
