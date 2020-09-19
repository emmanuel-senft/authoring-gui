import QtQuick 2.12
import QtQuick.Controls 1.4

Item {
    id: actionDelegate
    width: map.width/4
    height: map.height/20

    Rectangle {
        id: dragRect
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: parent.height
        color: done ? "white" : "transparent"
        opacity: done ? .7 : 1
        //MouseArea{
        //    id: dragArea
        //    anchors.fill: parent
        //    property bool held: false
        //    drag.axis: Drag.YAxis
        //    onPressed: {
        //        parameterArea.visible = !parameterArea.visible
        //    }
        //}

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: parent.height*.8
            spacing: width/20

            Row {
                id: imageRow
                width: parent.width/3; height: parent.height
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
                        font.pixelSize: parent.width/2
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
                    Component.onCompleted: console.log(img2)
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
                        font.pixelSize: parent.width/2
                    }
                }
            }
            Text {
                text: name+' ' + targetDisplay
                width: parent.width*2/3.2
                height: parent.height
                wrapMode: Text.WordWrap
                font.italic: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: parent.height/2.5
            }
        }
        Rectangle{
           id: separator
           width:parent.width
           anchors.bottom: parent.bottom
           height: 2
           color: "grey"
       }

    }
    Item {
        id: parameterArea
        width: 600
        height: 200
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.right
        visible: false

        Canvas {
            id: parameterBubble
            antialiasing: true
            z:1
            anchors.fill: parent
            onPaint: {
                var ctx = parameterBubble.getContext('2d');
                var ref = parent
                var triangleSize = width/40
                var radius = width/10
                ctx.reset();
                var recHeight = .9 * height
                var recWidth = .9 * width
                var xoffset = (width-recWidth)/2
                var yoffset = (height-recHeight)/2

                ctx.lineJoin = "round"
                ctx.lineCap="round";

                ctx.lineWidth = 10

                ctx.strokeStyle = "#ffc27a";
                ctx.fillStyle = "#B0f8f8ff";

                ctx.beginPath();

                ctx.moveTo(xoffset, height/2);
                ctx.lineTo(xoffset+triangleSize, height/2-triangleSize);
                ctx.lineTo(xoffset+triangleSize, radius+yoffset);
                ctx.arc(xoffset+triangleSize+radius, radius+yoffset,radius, Math.PI,3*Math.PI/2)
                ctx.lineTo(xoffset+recWidth-radius, yoffset);
                ctx.arc(xoffset+recWidth-radius, radius+yoffset,radius, -Math.PI/2,0)
                ctx.lineTo(xoffset+recWidth, recHeight - radius+yoffset);
                ctx.arc(xoffset+recWidth-radius, recHeight-radius+yoffset,radius, 0, Math.PI/2)
                ctx.lineTo(xoffset+triangleSize+radius, recHeight+yoffset);
                ctx.arc(xoffset+triangleSize+radius, recHeight-radius+yoffset,radius, Math.PI/2, Math.PI)
                ctx.lineTo(xoffset+triangleSize, height/2+triangleSize);
                ctx.lineTo(xoffset, height/2);
                ctx.stroke();
                ctx.fill()
            }
        }
        Component.onCompleted: parameterBubble.requestPaint()
    }
}
