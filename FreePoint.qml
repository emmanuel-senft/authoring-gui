import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Shapes 1.15

Item{
    id: freePoint
    anchors.fill: parent
    property var center: Qt.point(0,0)
    property var radius: map.width/30
    property bool selected: true

    onCenterChanged: {
        start.midPoint = Qt.point(center.x,center.y-radius)
        start.radius = radius
        end.midPoint = Qt.point(center.x,center.y+radius)
        end.radius = radius
    }
    TriPoint{
        id:start
    }
    TriPoint{
        id:end
    }
    Shape {
        id:shape
        anchors.fill: parent
        z: 10
        ShapePath {
            strokeWidth: 5
            strokeColor: "black"
            strokeStyle: ShapePath.DashLine
            dashPattern: [ 1, 3 ]
            startX: start.midPoint.x; startY: start.midPoint.y
            PathLine { x: end.midPoint.x; y: end.midPoint.y}
        }
        ShapePath {
            id: p
            property var angle: Math.atan2(start.midPoint.y-end.midPoint.y,start.midPoint.x-end.midPoint.x)
            property var d: 40
            strokeWidth: 5
            strokeColor: "transparent"
            fillColor: "black"
            startX: end.midPoint.x; startY: end.midPoint.y
            PathLine { x: end.midPoint.x+p.d*Math.cos(p.angle+Math.PI/12); y: end.midPoint.y+p.d*Math.sin(p.angle+Math.PI/12)}
            PathLine { x: end.midPoint.x+p.d*Math.cos(p.angle-Math.PI/12); y: end.midPoint.y+p.d*Math.sin(p.angle-Math.PI/12)}
            PathLine { x: end.midPoint.x; y: end.midPoint.y}
        }
    }
    function getTarget(){
        var scaleX = map.sourceSize.width / map.paintedWidth
        var scaleY = map.sourceSize.height / map.paintedHeight
        return start.getCoord()+'_'+end.getCoord()
    }

/*
    function getAction(){
        var actions=[]
        target = snappedPoi.name
        for(var i=0;i<action.length;i++){
            var a={}
            a.img1 = "none_ "
            a.name = action[i]
            if(a.name.includes("Move")){
                if (origin.name === snappedPoi.name){
                    time = -1
                    return []
                }
                target = origin.name +"-"+snappedPoi.name
                a.img1 = origin.name
                a.img3 = snappedPoi.name
            }
            else{
                target = origin.name
                a.img3 = target
            }
            if(a.name.includes("Inspect")){
                a.img2 = "Inspect"
                if(!a.name.includes("Move")){
                    a.img1 = a.name.split("-")[1]+"_ "
                }
            }
            else
                a.img2 = a.name
            a.target = target
            a.targetDisplay = target.replace(/_/g," ").replace('-',' to ')
            a.order = i
            a.color = container.objColor
            a.done = false
            if(done.includes(a.name) || doneSim.includes(a.name))
                a.done = true

            if (time === -1 || time === null){
                var d = new Date()
                time = d.getTime()
            }

            a.time = time
            actions.push(a)
        }
        return actions
    }

    function testDone(act, t){
        if(action.includes(act) && target.split("-").includes(t.split("-")[0])){
            if(globalStates.state === "simulation")
                doneSim.push(act)
            else
                done.push(act)
            return true
        }
        return false
    }

    function testDelete(){
        if(action.includes("Move"))
            if (origin.name === snappedPoi.name)
                return true
        if(done.length>0)
            return true
        return false
    }*/
}
