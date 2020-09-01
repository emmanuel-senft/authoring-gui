import QtQuick 2.12
import QtQuick.Controls 1.4

Item{
    id: anchor
    property bool released: false
    property var objColor: "red"
    property var center: null
    x: center.x
    y: center.y
    z:30
    opacity: .5

    Rectangle{
        id: target
        x:-width/2
        y:-height/2
        width: 50
        height: width
        radius: width/2
        color: objColor
        border.color: "steelblue"
        border.width:width/3
    }

    MouseArea {
        id:mouseArea
        anchors.fill: target
        drag.target: parent
        drag.axis: Drag.XAndYAxis
        onPressed: {
            anchor.parent.selected(true)
        }
        onReleased: {
            anchor.released = true
        }
    }
    onXChanged: {
        released = false
    }
    function getCoord(){
        var imx = x /map.paintedWidth * map.sourceSize.width;
        var imy = y /map.paintedHeight * map.sourceSize.height;
        return parseInt(imx)+','+parseInt(imy)
    }
    function angle(p0,p1){
        var a = -(Math.atan2(p1.y-p0.y,p1.x-p0.x))//+3*Math.PI)%(2*Math.PI)-Math.PI
        if(a<0)
            a+=2*Math.PI
        return a
    }
    function normalise(p_minus, p_opp, p_plus){
        var p = anchor
        var a_minus = angle(p_opp,p_minus)
        var a = angle(p_opp,p)
        var a_plus = angle(p_opp,p_plus)
        var d_a_plus = (a-a_plus+3*Math.PI)%(2*Math.PI)-Math.PI
        var d_a_minus = (a-a_minus+3*Math.PI)%(2*Math.PI)-Math.PI

        if(d_a_minus<0){
            var d = Math.sqrt((p_opp.y-p.y)**2+(p_opp.x-p.x)**2)
            x=p_opp.x+d*Math.cos(a_minus)
            y=p_opp.y-d*Math.sin(a_minus)
        }
        if(d_a_plus>0){
            var d = Math.sqrt((p_opp.y-p.y)**2+(p_opp.x-p.x)**2)
            x=p_opp.x+d*Math.cos(a_plus)
            y=p_opp.y-d*Math.sin(a_plus)
        }

        var a_diag = angle(p_plus,p_minus)
        var a_point = angle(p_plus,p)
        var d_a_diag= (a_diag-a_point+3*Math.PI)%(2*Math.PI)-Math.PI
        if(d_a_diag>0){
            var d = Math.sqrt((p_plus.y-p.y)**2+(p_plus.x-p.x)**2)
            x=p_plus.x+d*Math.cos(a_diag)
            y=p_plus.y-d*Math.sin(a_diag)
        }
    }
}
