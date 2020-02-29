import QtQuick 2.12
import QtQuick.Controls 1.4
 import QtQuick.Controls.Styles 1.4

Button{
    id: button
    style: ButtonStyle {
        background: Rectangle {
            implicitWidth: 100
            implicitHeight: 25
            border.width: width/20
            border.color: "darkgoldenrod"
            radius: 30
            gradient: Gradient {
                GradientStop { position: 0 ; color: control.pressed ? "goldenrod" : "darkgoldenrod" }
                GradientStop { position: 1 ; color: control.pressed ? "darkgoldenrod" : "goldenrod" }
            }
        }
        label: Text {
          renderType: Text.NativeRendering
          verticalAlignment: Text.AlignVCenter
          horizontalAlignment: Text.AlignHCenter
          font.family: "Helvetica"
          font.pointSize: 15
          color: "black"
          font.bold: true
          text: button.text
        }
    }
}
