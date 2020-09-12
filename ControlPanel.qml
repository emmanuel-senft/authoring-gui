import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.12

Item{
    id: controlPanel
    anchors.fill: parent

    ArrowPad{
        id: trans
        z:11
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width / 15 + width/2
        anchors.verticalCenter: resetButton.verticalCenter
        visible: commandGui.visible
    }
    ArrowPad{
        id: other
        z:11
        type: "other"
        visible: commandGui.visible
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: resetButton.verticalCenter
    }
    ArrowPad{
        id: rot
        z:11
        visible: commandGui.visible
        type: "rotation"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -parent.width / 15 - width/2
        anchors.verticalCenter: resetButton.verticalCenter
    }

    GuiButton{
        id: grasp
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width/2 + 5/4 *height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width/4
        name: 'Grasp'
        color: "steelblue"
        onClicked: {
            commandPublisher.text = "direct;"+name
        }
    }
    GuiButton{
        id: release
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width/2 - height/5
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: parent.width/4
        name: 'Release'
        color: "steelblue"
        onClicked: {
            commandPublisher.text = "direct;"+name
        }
    }

    GuiButton{
        id: resetButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 3*parent.width/8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: width
        z:10
        name: "reset"
        onClicked:{
            commandPublisher.text = "reset_position"
        }
        visible: globalStates.state === "command"
    }

    GuiButton{
        id: stopButton
        z:10
        anchors.horizontalCenter: resetButton.horizontalCenter
        anchors.verticalCenter: resetButton.verticalCenter
        name: "stop"
        color: "red"
        onClicked:{
            commandPublisher.text = "stop"
            globalStates.state = "drawing"
        }
        visible: globalStates.state === "execution"
    }
    function filter_button(panda_pose){
        trans.setEnabled("up", panda_pose[0]**2 + panda_pose[1]**2 + panda_pose[2]**2 < .56)
        other.setEnabled("down", panda_pose[0]**2 + panda_pose[1]**2 + panda_pose[2]**2 < .56)
        other.setEnabled("up", panda_pose[2]>.1)
    }
}
