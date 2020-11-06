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
        implicitWidth: 26*k
        implicitHeight: 26*k
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 13*k

        Rectangle {
            width: 14*k
            height: 14*k
            x: 6*k
            y: 6*k
            radius: 7*k
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
        font.pointSize: 12*k
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
