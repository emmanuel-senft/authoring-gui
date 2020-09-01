import QtQuick 2.12
import QtQuick.Controls 2.12

CheckBox {
    id: control
    property var group: null
    property var name: text.toLowerCase().slice(0,-1)
    property var order: null
    property var index: 0
    property int position: index
    anchors.left: parent.left
    width: parent.width
    y:position*1.1*height
    visible: true

    text: qsTr("CheckBox")
    checked: false

    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
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
            text: order === null ? "" : order.toString()
            visible: control.checked
            color: "#696969"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            anchors.fill: parent
            font.family: "Helvetica"
            font.pointSize: 12
            font.bold: false
            style: Text.Outline
            styleColor: color
        }
    }

    contentItem: Text {
        text: control.text
        opacity: enabled ? 1.0 : 0.3
        color: "white"
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing

        font.family: "Helvetica"
        font.pointSize: 17
        font.bold: true
        styleColor: "black"
    }

    onCheckedChanged: {
        if(!checked)
            order=null
        if(group !== null){
            if (checked){
                if(group.selected.indexOf(name) === -1){
                    group.selected.push(name)
                }
                group.update()
            }
            else{
                for( var i = 0; i < group.selected.length; i++){
                    if ( group.selected[i] === name) {
                        group.selected.splice(i, 1)
                        group.update()
                        break
                    }
                }
            }
            group.updateSelected()
        }
    }
    Behavior on y { PropertyAnimation { properties: "y"; easing.type: Easing.InOutQuad } }
    MouseArea{
        anchors.right: parent.right
        width: parent.width/2
        height: parent.height
    }
    Rectangle{
        id: button
        visible: order === 1 ? false : checked
        width: parent.width/8
        height: width
        radius: width/2
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        property var borderWidth: width/20
        border.color: "Gainsboro"
        color: "GhostWhite"

        Image{
           id:img
           width: button.width/1.41
           height: button.height/1.41
           source: "/res/up.png"
           anchors.horizontalCenter: button.horizontalCenter
           anchors.verticalCenter: button.verticalCenter

           fillMode: Image.PreserveAspectFit
        }
        MouseArea{
            anchors.fill: parent
            onPressed:{
                if(order === 1)
                    return
                group.up(order-1)
                order-=1
                group.updateSelected()
                group.updateOrder()
            }
        }
    }
}
