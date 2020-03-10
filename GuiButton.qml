import QtQuick 2.12
import QtQuick.Controls 1.4
 import QtQuick.Controls.Styles 1.4

Button{
    id: button
    width: parent.width/10
    height: parent.height/15
    property var color: "yellowgreen"
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 25
            border.width: 0
            border.color: "transparent"
            radius: 30
            color: button.color
        }
        label: Text {
          renderType: Text.NativeRendering
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          font.family: "Helvetica"
          font.pointSize: 15
          color: "white"
          font.bold: true
          text: button.text
        }
    }
}
