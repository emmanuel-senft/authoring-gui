import QtQuick 2.12
import QtQuick.Controls 2.12

RadioButton {
    id: control
    property var group: null
    property var name: text.toLowerCase()
    property bool lastVisible: true
    visible: true

    text: qsTr("RadioButton")
    checked: false

    indicator: Rectangle {
        implicitWidth: 15*k
        implicitHeight: 15*k
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: implicitHeight/2

        Rectangle {
            width: parent.implicitWidth/2
            height: width
            anchors.centerIn: parent
            radius: width/2
            color: control.down ? "#17a81a" : "black"
            visible: control.checked
        }
    }

    contentItem: Text {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: "white"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        font.family: "Helvetica"
        font.pixelSize: 16*k
        font.bold: true
        style: Text.Outline
        styleColor: "black"
    }

    onCheckedChanged: {
        if (checked && group !== null)
            group.selected = name
    }
    onVisibleChanged: {
        if(lastVisible !== visible){
            if (visible)
                parent.objectLength+=1
            else
                parent.objectLength-=1
        }
        lastVisible = visible
    }
}
