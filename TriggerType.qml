import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

CheckBox {
    id: control
    contentItem: Text {
        text: parent.text
        font.pixelSize: triggersCol.width/12
        color: "#696969"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
        font.family: "Helvetica"
        font.bold: true
    }
    indicator: Rectangle {
        id: ind
        implicitWidth: triggersCol.width/15
        implicitHeight: triggersCol.width/15
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        border.color: control.down ? "#dark" : "#grey"

        Rectangle {
            width: ind.width/2
            height: ind.width/2
            x: (ind.width-width)/2
            y: x
            color: control.down ? "#dark" : "#grey"
            visible: control.checked
        }
    }
}
