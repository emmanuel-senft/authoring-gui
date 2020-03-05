import QtQuick 2.12
import QtQuick.Controls 2.12

RadioButton {
    id: control
    property var group: null
    property var name: text.toLowerCase().slice(0,-1)

    text: qsTr("RadioButton")
    checked: false

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 7
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
        font.pointSize: 15
        font.bold: true
        style: Text.Outline
        styleColor: "black"
    }

    onCheckedChanged: {
        if (checked && group !== null)
            group.selected = name
    }
}
