import QtQuick 2.0

Item{
    id: rect
    anchors.fill:parent
    property var p0Coord: null
    property var p1Coord: null
    property var p2Coord: null
    property var p3Coord: null
    property int index: 0
    property int minSize: map.width/100
    property var k: map.width/1500
    property var selected: objectList.selected
    property var state: stateList.selected

    visible: currentTrig == rect
    Rectangle{
        id:rec
        x: p0.x
        y: p0.y
        width: p2.x-p0.x
        height: p2.y-p0.y
        color: "transparent"
        border.width: map.width/500
        border.color: colors[index]
    }
    Item{
        id:corners
        DragAnchor{
            id:p0
            center: p0Coord
            onUpdated: {
                p0.x = Math.min(p0.x,p2.x-minSize)
                p0.y = Math.min(p0.y,p2.y-minSize)

                p1.y=p0.y
                p3.x=p0.x
                updateItems()
            }
        }
        DragAnchor{
            id:p1
            center: p1Coord
            onUpdated: {
                p1.x = Math.max(p1.x,p3.x+minSize)
                p1.y = Math.min(p1.y,p3.y-minSize)
                p0.y=p1.y
                p2.x=p1.x
                updateItems()
            }
        }
        DragAnchor{
            id:p2
            center: p2Coord
            onUpdated: {
                p2.x = Math.max(p2.x,p0.x+minSize)
                p2.y = Math.max(p2.y,p0.y+minSize)
                p3.y=p2.y
                p1.x=p2.x
                updateItems()
                print(p2.x)
            }
        }
        DragAnchor{
            id:p3
            center: p3Coord
            onUpdated: {
                p3.x = Math.min(p3.x,p1.x-minSize)
                p3.y = Math.max(p3.y,p1.y+minSize)
                p2.y=p3.y
                p0.x=p3.x
                updateItems()
            }
        }
    }

    Column{
        id: objectList
        property var selected: ""
        anchors.left: rec.right
        anchors.top:rec.top
        GuiRadioButton{
            id:screw
            text:"Screw"
            visible: false
            group: objectList
        }
        GuiRadioButton{
            id:hole
            text:"Hole"
            visible: false
            group: objectList
        }
    }
    Column{
        id:stateList
        property var selected: ""
        anchors.right: rec.left
        anchors.top:rec.top
        GuiRadioButton{
            id:screwed
            text:"Screwed"
            visible: screw.checked && triggerPannel.useState
            group: stateList
        }
        GuiRadioButton{
            id:unscrewed
            text:"Unscrewed"
            visible: screw.checked && triggerPannel.useState
            group: stateList
        }
    }
    function updateItems(){

        var objectTypes=[]
        for(var i=0; i<pois.children.length; i++){
            var poi = pois.children[i]
            if (poi.enabled && poi.type && inHull(poi)){
                if(objectTypes.indexOf(poi.type)===-1)
                    objectTypes.push(poi.type)
            }
        }
        screw.visible = (objectTypes.indexOf("screw")!==-1)
        hole.visible = (objectTypes.indexOf("hole")!==-1)

        p0Coord.x = p0.x
        p1Coord.x = p1.x
        p2Coord.x = p2.x
        p3Coord.x = p3.x
        p0Coord.y = p0.y
        p1Coord.y = p1.y
        p2Coord.y = p2.y
        p3Coord.y = p3.y
    }
    function inHull(poi){
        if(poi.x>p0.x && poi.x<p1.x && poi.y>p0.y && poi.y<p3.y)
            return true
        return false
    }
    function getTrigger(pos,state){
        var msg ="trigger_"+index.toString()+";"+selected+";"
        var p0_coord = p0.getCoord().split(",")
        var p2_coord = p2.getCoord().split(",")

        if(pos)
            msg+="pix_pose:"+p0_coord[0]+"-"+p2_coord[0]+"_"+p0_coord[1]+"-"+p2_coord[1]
        if(state && pos)
            msg+=","
        if(state)
            msg+="state:"+stateList.selected

        return msg;
    }

    Component.onCompleted: updateItems()
    function selected(val){
    }
}
