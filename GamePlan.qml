import QtQuick 2.12
import QtQuick.Controls 1.4

Item {
    id: gamePlan

    anchors.fill: parent

    GuiButton{
        id: showPlanButton
        z:10
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: width/2
        anchors.top: parent.top
        anchors.topMargin: width/2
        color: "#ffc27a"
        onClicked:{
            actionTracker.visible = !actionTracker.visible
        }
    }

    Rectangle {
        id: actionTracker
        anchors.left: showPlanButton.left
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
            x:parent.width/10
            y:x/3
            font.pixelSize: 40
            height: map.height/30
            text: "Game plan"
            verticalAlignment: Text.AlignVCenter
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
            y: title.height*1.5
            anchors.horizontalCenter: parent.horizontalCenter
            width:.9*parent.width
            property var rowHeigth: 80
            color: "transparent"
            Component {
                id: actionDelegate

                Item {
                    width: parent.width; height: 1*container.rowHeigth
                    Column{
                        spacing: .2*container.rowHeigth
                        Item{
                            width: parent.width; height: .7*container.rowHeigth
                            Rectangle{
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: container.rowHeigth + list.spacing
                                visible: done
                                color: "white"
                                opacity: .7
                                z:5
                            }
                            Row {
                                anchors.fill: parent
                                Row {
                                    width: parent.width/2.2; height: parent.height
                                    spacing: width/40
                                    Item{
                                        width: parent.width/3.2
                                        height: parent.height
                                        Image{
                                           anchors.fill:parent
                                           source: "/res/"+img1.split("_")[0]+".png"
                                           fillMode: Image.PreserveAspectFit
                                        }
                                        Text{
                                            anchors.fill: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            text: img1.split("_")[1]
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 30
                                        }
                                    }
                                    Item{
                                        width: parent.width/3.2
                                        height: parent.height
                                        Image{
                                           anchors.fill:parent
                                           source: "/res/"+img2+".png"
                                           fillMode: Image.PreserveAspectFit
                                        }
                                    }
                                    Item{
                                        width: parent.width/3.2
                                        height: parent.height
                                        Image{
                                           anchors.fill:parent
                                           source: "/res/"+img3.split("_")[0]+".png"
                                           fillMode: Image.PreserveAspectFit
                                        }
                                        Text{
                                            anchors.fill: parent
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                            text: img3.split("_")[1]
                                            color: "white"
                                            font.bold: true
                                            font.pixelSize: 30
                                        }
                                    }
                                }
                                Text {
                                    text: name+' ' + targetDisplay
                                    width: actionTracker.width/2.2
                                    height: parent.height
                                    wrapMode: Text.WordWrap
                                    font.italic: true
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                        }
                         Rectangle{
                            id: separator
                            width:container.width
                            height: 2
                            color: "grey"
                        }

                    }
                }
            }

            ListView {
                id:list
                anchors.fill: parent
                model: actionList
                spacing: .1*container.rowHeigth
                delegate: actionDelegate
                focus: true
            }
        }
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
            var radius = actionTracker.width/10
            ctx.reset();

            if (ref.height === 0)
                return

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = but.borderWidth;

            ctx.strokeStyle = showPlanButton.color;
            ctx.fillStyle = "#B0f8f8ff";

            ctx.beginPath();

            ctx.moveTo(but.x+but.width/2-triangleSize/2, ref.y);
            ctx.lineTo(but.x+but.width/2, but.y+but.height);
            ctx.lineTo(but.x+but.width/2+triangleSize/2, ref.y);
            ctx.lineTo(ref.x+ref.width-radius, ref.y);
            ctx.arc(ref.x+ref.width-radius, ref.y+radius, radius, -Math.PI/2,0)
            ctx.lineTo(ref.x+ref.width, ref.y+ref.height-radius);
            ctx.arc(ref.x+ref.width-radius, ref.y+ref.height-radius,radius, 0,Math.PI/2)
            ctx.lineTo(ref.x+radius, ref.y+ref.height);
            ctx.arc(ref.x+radius, ref.y+ref.height-radius,radius, Math.PI/2, Math.PI)
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
                //console.log(action)
                actions = actions.concat(action)
            }
            //if(actions.length !== figures.children.length)
            //    return
            //actions.sort(compare)
            actionList.clear()
            for(var i=0;i<actions.length;i++){
                actionList.append(actions[i])
            }
            if (actions.length > 0){
                container.height = 1.1*container.rowHeigth*actions.length
                actionTracker.height = container.height+title.height*1.5+container.rowHeigth*.25
            }
            else{
                container.height = 0
                actionTracker.height = 0
            }

            if(globalStates.state === "drawing" && !moving){
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
