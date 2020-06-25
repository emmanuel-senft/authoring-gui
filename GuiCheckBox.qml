import QtQuick 2.12
import QtQuick.Controls 2.12

CheckBox {
    id: control
    property var group: null
    property var name: text.toLowerCase().slice(0,-1)
    property var order: ""

    text: qsTr("CheckBox")
    checked: false

    indicator: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        x: control.leftPadding
        y: parent.height / 2 - height / 2
/*
        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            color: control.down ? "#17a81a" : "black"
            visible: control.checked
        }
*/
        Text {
            text: order
            visible: control.checked
            color: "black"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.family: "Helvetica"
            font.pointSize: 12
            font.bold: true
            style: Text.Outline
            styleColor: "black"
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
        if(group !== null){
            if (checked){
                if(group.selected.indexOf(name) === -1){
                    console.log("Adding "+name)
                    group.selected.push(name)
                }
                else
                    console.log("Already there")
                group.update()
            }
            else
                for( var i = 0; i < group.selected.length; i++)
                    if ( group.selected[i] === name) {
                        group.selected.splice(i, 1)
                        group.update()
                        break
                    }
        }

    }
}
