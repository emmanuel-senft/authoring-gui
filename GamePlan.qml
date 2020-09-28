import QtQuick 2.12
import QtQuick.Controls 1.4

Item {
    id: gamePlan
    anchors.fill: parent

    GuiButton{
        id: showPlanButton
        z:10
        visible: true
        anchors.right: actionTracker.right
        anchors.top: parent.top
        anchors.topMargin: width/2
        color: "#ffc27a"
        onClicked:{
            if(actionTracker.height !== 0)
                actionTracker.visible = !actionTracker.visible
        }
    }

    Rectangle {
        id: actionTracker
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 3*parent.width/8
        anchors.top: showPlanButton.bottom
        anchors.topMargin: showPlanButton.height/4
        height: 0
        width: parent.width / 5
        z:2
        color: "transparent"
        border.color: "transparent"
        border.width: showPlanButton.borderWidth
        Label{
            id: title
            visible: false
            x:parent.width/20
            y:x/3
            font.pixelSize: map.width/50
            height: map.height/30
            text: "Game plan"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
        }
        onHeightChanged: {
            if(height === 0)
                title.visible = false
            else
                title.visible = true
            canvas.requestPaint()

        }

        Rectangle {
            id: container
            y: title.height*1.2
            anchors.horizontalCenter: parent.horizontalCenter
            width:.9*parent.width
            property var rowHeight: map.height/30
            color: "transparent"


            ListView {
                id:list
                anchors.fill: parent
                model: actionList
                spacing: 0
                delegate: ActionDelegate{
                    width: container.width;
                    height: container.rowHeight
                }
                focus: true
                interactive: false
            }
        }
    }

    GuiButton{
        id: commandButton
        z:10
        width: map.width/25
        anchors.horizontalCenter: actionTracker.horizontalCenter
        //anchors.rightMargin: width/2
        anchors.top: actionTracker.bottom
        anchors.topMargin: -height*3/10
        //anchors.horizontalCenterOffset: -parent.width/4
        name: "play"
        enabled: !(warningReach.visible || warningDepth.visible)
        onClicked:{
            gamePlan.sendCommand("exec");
            globalStates.state = "execution"
            pauseButton.name = "pause"
        }
        visible: actionTracker.height !== 0 && actionTracker.visible && !pauseButton.visible
    }
    GuiButton{
        id: pauseButton
        z:9
        visible: executionGui.visible && actionTracker.height !== 0 && actionTracker.visible
        anchors.horizontalCenter: commandButton.horizontalCenter
        anchors.verticalCenter: commandButton.verticalCenter
        name: "pause"
        color: "orange"
        onClicked:{
            commandPublisher.text = name
            if(name === "pause"){
                name = "play"
                color = "yellowgreen"
            }
            else{
                name = "pause"
                color = "orange"
            }
        }
    }
    MouseArea{
        id:protectionArea
        width: 1.1*actionTracker.width
        anchors.horizontalCenter: actionTracker.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: actionTracker.bottom
        anchors.bottomMargin: -1.2*pauseButton.height
        visible:actionTracker.visible
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        z:1
        visible: actionTracker.visible
        onPaint: {
            var ctx = canvas.getContext('2d');
            var ref = actionTracker
            var but = showPlanButton
            var triangleSize = but.width/8
            var radius = actionTracker.width/12
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

    ListModel {
        id: actionList
        function update(){
            var actions = []
            actions.length = 0
            for(var i=0;i<figures.children.length;i++){
                var action = figures.children[i].getAction()
                actions = actions.concat(action)
            }
            actionList.clear()
            for(var i=0;i<actions.length;i++){
                actionList.append(actions[i])
            }
            if (actions.length > 0){
                container.height = 1*container.rowHeight*actions.length
                actionTracker.height = container.height+title.height*1.5+container.rowHeight*.25
            }
            else{
                container.height = 0
                actionTracker.height = 0
            }

            if(globalStates.state === "command" && !moving){
                sendCommand("viz")
            }
            if(globalStates.state === "edit")
                sendCommand("edit")
        }
        function compare(a, b) {
            if(a.order<b.order)
                return -1
            if(a.order>b.order)
                return 1
            var order = ["Move","Pick","Screw","Place","Wipe","Inspect"]
            if(order.indexOf(a.name)<order.indexOf(b.name))
                return -1
            return 1
        }
    }
    function update(){
        actionList.update()
    }
    function sendCommand(type,actionToInsert=""){
        var str=type
        if(actionToInsert !== "")
            str+=';'+actionToInsert
        for (var i=0;i<actionList.count;i++) {
            var a = actionList.get(i)
            if(!a.done){
                if(a.name.includes("-")){
                    str+=";"+a.name.split("-")[0]+":"+actionList.get(i).target
                    str+=";"+a.name.split("-")[1]+":"+actionList.get(i).target
                }
                else
                    str+=";"+actionList.get(i).name+":"+actionList.get(i).target
            }
        }
        str+=";Reset"
        commandPublisher.text=str
    }
}
