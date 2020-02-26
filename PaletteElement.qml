import QtQuick 2.12
import QtQuick.Controls 1.4

Rectangle{
    id: anchor
    width:50
    height: width
    radius: width/2
    property int index: 0
    color: figures.colors[index]
    MouseArea{
        anchors.fill: parent
        onClicked: {figures.currentItem.setIndex(index)}
    }
}
