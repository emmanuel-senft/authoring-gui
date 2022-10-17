import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

Item {
    id: triggerPannel
    anchors.fill: parent
    property var k: map.width/1500
    property bool useState: triggerState.checked

    GuiButton{
        id: showPlanButton
        z:10
        visible: true
        anchors.right: backPannel.right
        anchors.top: parent.top
        anchors.topMargin: width/2
        color: "#ffc27a"
        onClicked:{
            gamePlan.visible = true
        }
    }

    Rectangle {
        id: backPannel
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 3*parent.width/8
        anchors.top: showPlanButton.bottom
        anchors.topMargin: showPlanButton.height/4
        height: parent.height/3
        width: parent.width / 5
        z:2
        color: "transparent"
        border.color: "transparent"
        border.width: showPlanButton.borderWidth
        Label{
            id: title
            x:parent.width/20
            y:x/2
            font.pixelSize: map.width/50
            height: map.width/50
            text: "Add a Trigger"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        ButtonGroup {
            id: triggerType
            buttons: triggers.children
            property var selected: []
            exclusive: false
        }

        Column {
            id: triggersCol
            height: parent.height/2
            y: (parent.height-height)/2
            width: parent.width*.8
            anchors.centerIn: parent
            spacing: height/5
            TriggerType{
                id: triggerPosition
                text:"Position Trigger"
                checked: true
            }
            TriggerType{
                id: triggerState
                text:"State Trigger"
            }
        }
    }
    onVisibleChanged: {
        if(!visible){
            triggers.currentTrig = null
        }
    }

    GuiButton{
        id: commandButton
        z:10
        width: map.width/25
        anchors.horizontalCenter: backPannel.horizontalCenter
        //anchors.rightMargin: width/2
        anchors.top: backPannel.bottom
        anchors.topMargin: -height*3/10
        //anchors.horizontalCenterOffset: -parent.width/4
        name: "add"
        enabled: triggers.currentTrig !== null && triggers.currentTrig.selected !==""
        onClicked:{
            updateTrigger()
        }
        visible: true
    }
    function updateTrigger(){
        var trigger = triggers.currentTrig.getTrigger(triggerPosition.checked, triggerState.checked)
        var p0 = triggers.currentTrig.p0Coord
        var p2 = triggers.currentTrig.p2Coord
        figures.createRect(p0.x,p0.y,p2.x-p0.x,p2.y-p0.y)
        gamePlan.visible = true
        print(trigger)
        behaviorDisplay.addTrigger(trigger)
        pubEvent("record")
        pubEvent(trigger)
        recordButton.name = "recording"
        recordButton.animate()
    }

    MouseArea{
        id:protectionArea
        width: 1.1*backPannel.width
        anchors.horizontalCenter: backPannel.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: backPannel.bottom
        anchors.bottomMargin: -1.2*commandButton.height
        visible:backPannel.visible
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        z:1
        visible: backPannel.visible
        onPaint: {
            var ctx = canvas.getContext('2d');
            var ref = backPannel
            var but = showPlanButton
            var triangleSize = but.width/8
            var radius = backPannel.width/12
            ctx.reset();

            if (ref.height === 0)
                return
            var h = ref.height +commandButton.height*4/5

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = but.borderWidth;

            ctx.strokeStyle = showPlanButton.color;
            ctx.fillStyle = "#E0f8f8ff";

            ctx.beginPath();

            ctx.moveTo(but.x+but.width/2-triangleSize/2, ref.y);
            ctx.lineTo(but.x+but.width/2, but.y+but.height);
            ctx.lineTo(but.x+but.width/2+triangleSize/2, ref.y);
            ctx.lineTo(ref.x+ref.width-radius, ref.y);
            ctx.arc(ref.x+ref.width-radius, ref.y+radius, radius, -Math.PI/2,0)
            ctx.lineTo(ref.x+ref.width, ref.y+h-radius);
            ctx.arc(ref.x+ref.width-radius, ref.y+h-radius,radius, 0,Math.PI/2)
            ctx.lineTo(ref.x+radius, ref.y+h);
            ctx.arc(ref.x+radius, ref.y+h-radius,radius, Math.PI/2, Math.PI)
            ctx.lineTo(ref.x, ref.y+radius);
            ctx.arc(ref.x+radius, ref.y+radius,radius, Math.PI, -Math.PI/2)
            ctx.lineTo(but.x+but.width/2-triangleSize/2, ref.y);
            ctx.stroke();
            ctx.fill()
        }
    }
}
