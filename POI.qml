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
    width: type === "box" ? map.width/40 : (type === "screw" ? map.width/80:map.width/180)

    Rectangle{
        id: marker
        x:-width/2
        y:-height/2
        width: parent.width
        height: width
        radius: poi.type === "screw" ? width/2 : 0
        color: parent.color
        border.color: "black"
        border.width: width/15
        opacity: .5
    }
    Text {
        id: name
        anchors.fill: marker
        renderType: Text.NativeRendering
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.family: "Helvetica"
        font.pixelSize: marker.width*2/3
        color: "black"
        text: type === "screw" ? index : ""
    }
    onPulledChanged: {
        console.log(pulled)
    }
}
