import QtQuick 2.12
import QtQuick.Controls 1.4

Item {
    id: templateLoader
    property var templates: ""

    anchors.fill: parent

    GuiButton{
        id: templateButton
        name: 'template'
        z:10
        visible: true
        anchors.left: parent.left
        anchors.leftMargin: 6*width
        anchors.top: parent.top
        anchors.topMargin: width/2
        color: "#008080"
        onClicked:{
            templateTracker.visible = !templateTracker.visible
            //loadTemplate(templates[0])
        }
    }

    Component.onCompleted: {
        var data=fileio.read("/src/authoring-gui/res/templates.json")
        templates = JSON.parse(data)
        for(var i = 0;i<templates.length;i++){
            templateList.append(templates[i])
        }
    }

    function loadTemplate(id){
        var actions = templates[id]['actions']
        for(var i = 0; i<actions.length;i++){
            var action = actions[i]
            var name = 'rect'
            var component = Qt.createComponent("DragRectangle.qml");
            var p0=Qt.point(0,0)
            var p1=Qt.point(200,0)
            var p2=p0
            var p3=p0
            var figure = component.createObject(figures, {name:name,index:figures.getIndex(name),p0Coord:p0,p1Coord:p1,p2Coord:p2,p3Coord:p3,action:action['type']});
            figure.init(action['targets'])
        }
    }


    Rectangle {
        id: templateTracker
        visible: false
        anchors.left: templateButton.left
        anchors.top: templateButton.bottom
        anchors.topMargin: templateButton.height/4
        height: 210+85*(templates.length)
        width: parent.width / 5
        z:2
        color: "transparent"
        border.color: "transparent"
        border.width: templateButton.borderWidth
        Label{
            id: title
            visible: true
            x:parent.width/10
            y:x/3
            font.pixelSize: 40
            height: map.height/30
            text: "Templates"
            verticalAlignment: Text.AlignVCenter
        }
        onVisibleChanged:  canvas.requestPaint()

        Rectangle {
            id: container
            height: rowHeigth*templates.length
            y: title.height*1.5
            anchors.horizontalCenter: parent.horizontalCenter
            width:.9*parent.width
            property var rowHeigth: 80
            color: "transparent"
            Component {
                id: templateDelegate
                Item {
                    width: parent.width; height: 1*container.rowHeigth
                    Column{
                        spacing: .2*container.rowHeigth
                        Item{
                            width: parent.width; height: .7*container.rowHeigth
                            Row {
                                anchors.fill: parent
                                spacing: width/40
                                Item{
                                    width: parent.width/2.2
                                    height: parent.height
                                    Image{
                                       anchors.fill:parent
                                       source: "/res/"+name+".png"
                                       fillMode: Image.PreserveAspectFit
                                    }
                                }
                                Item{
                                    width: parent.width/2.2
                                    height: parent.height
                                    Text{
                                        anchors.fill: parent
                                        horizontalAlignment: Text.AlignHCenter
                                        verticalAlignment: Text.AlignVCenter
                                        text: name
                                        color: "black"
                                        font.bold: true
                                        font.pixelSize: 40
                                    }
                                }
                            }
                            MouseArea{
                                anchors.fill: parent
                                onClicked: {
                                    console.log(name)
                                    console.log(n)
                                    loadTemplate(n)
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
                model: templateList
                spacing: .1*container.rowHeigth
                delegate: templateDelegate
                focus: true
            }
        }
        GuiButton{
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            name: "save"
            width: 100
            color: templateButton.color
            onClicked: {
                var template ={}
                template["name"]="New template"
                template["n"]=templates.length
                var actions = []
                for(var i=0;i<figures.children.length;i++){
                    if(figures.children[i].name === 'rect'){
                        var action = figures.children[i].getTemplate()
                        actions.push(action)
                    }
                }
                template["actions"]=actions
                var t =[]
                for(var j =0;j<templates.length;j++)
                    t.push(templates[j])
                templateList.append(template)
                t.push(template)
                templates = t
                canvas.requestPaint()
                var string = JSON.stringify(t)
                fileio.write("/src/authoring-gui/res/templates.json",string)
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true
        z:1
        visible: templateTracker.visible
        onPaint: {
            var ctx = canvas.getContext('2d');
            var ref = templateTracker
            var but = templateButton
            var triangleSize = but.width/8
            var radius = templateTracker.width/10
            ctx.reset();

            if (ref.height === 0)
                return

            ctx.lineJoin = "round"
            ctx.lineCap="round";

            ctx.lineWidth = but.borderWidth;

            ctx.strokeStyle = templateButton.color;
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
        id: templateList
    }
}
