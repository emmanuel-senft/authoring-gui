import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: poi
    x:centerX - width/2
    y:centerY - height/2
    property var type: "poi"
    property int index: 0
    property var name: type+"_"+index
    property var objColor: "white"
    property var enabled: true
    border.color: "black"
    border.width: width/15

    visible: enabled
    width: map.width/40
    height: width
    radius: type === "screw" ? width/2 : 0
    color: selected === poi ? "red" : objColor
    property var centerX: 100
    property var centerY: 100
    opacity: .5
    function update_shape(){
        if(type !== "box"){
            width = 150*(1-pandaZ)
        }
        else
            width = 550*(1-pandaZ)
    }
}
