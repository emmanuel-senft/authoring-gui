import QtQuick 2.0

Item{
    id: figures
    property var listFigure: []
    property var arrow: null
    property var indexArrows: []
    property var indexCircles: []
    property var indexSpirals: []
    property var indexCrosses: []
    property var indexRects: []
    property var indexSurfaces: []
    property var types: []
    property var currentItem: null
    //from: https://sashat.me/2017/01/11/list-of-20-simple-distinct-colors/
    //property var colors: ["#e6194B", "#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#42d4f4", "#f032e6", "#bfef45", "#fabebe", "#469990", "#e6beff", "#9A6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#a9a9a9", "#ffffff", "#000000"]
    property var colors: ["#3cb44b", "#ffe119", "#4363d8", "#f58231", "#911eb4", "#42d4f4", "#f032e6", "#bfef45", "#fabebe", "#469990", "#e6beff", "#9A6324", "#fffac8", "#800000", "#aaffc3", "#808000", "#ffd8b1", "#000075", "#a9a9a9", "#ffffff", "#000000"]
    property var colorNames:["Green", "Yellow", "Blue", "Orange","Purple", "Cyan", "Magenta", "Lime", "Pink","Teal", "Lavender", "Brown", "Beige", "Maroon", "Mint", "Navy", "Grey", "White", "Black"]
    anchors.fill:parent

    function createFigure(name, points){
        var x= 0
        var y= 0
        var max_x=0
        var max_y= 0
        var nx = 0
        var ny = 0
        var alpha = displayView.rotation/180*Math.PI
        for (var i=0;i<points.length;i++){
            nx = points[i].X*Math.cos(alpha)-points[i].Y*Math.sin(alpha)
            ny = points[i].X*Math.sin(alpha)+points[i].Y*Math.cos(alpha)
            if(i===0){
                max_x=nx
                max_y=ny
                x=nx
                y=ny
            }

            x=Math.min(x,nx)
            max_x=Math.max(max_x,nx)
            y=Math.min(y,ny)
            max_y=Math.max(max_y,ny)
        }
        var width = (max_x-x)
        var height = (max_y-y)
        nx = x*Math.cos(-alpha)-y*Math.sin(-alpha)// + (-Math.sin(-alpha)-1+Math.cos(-alpha))*width/2
        ny = x*Math.sin(-alpha)+y*Math.cos(-alpha)// + (Math.sin(-alpha)-1+Math.cos(-alpha))*height/2
        x=nx
        y=ny
        if (name === "arrow")
            name = "rect"
        var component = null
        var figure = null
        var center=Qt.point(x+width/2 + (-Math.sin(-alpha)-1+Math.cos(-alpha))*width/2 ,y+width/2 + (Math.sin(-alpha)-1+Math.cos(-alpha))*height/2)
        if (name === "circle"){
            component = Qt.createComponent("DragCircle.qml");
            width = Math.max(width,height)
            figure = component.createObject(figures, {name:name,index:getIndex(name),centerCoord:center,rMax:width/2});
        }
        if (name === "rect"){
            component = Qt.createComponent("DragRectangle.qml");
            var p0=Qt.point(x,y)
            var p1=Qt.point(x+width*Math.cos(alpha),y-width*Math.sin(alpha))
            var p2=Qt.point(x+width*Math.cos(alpha)+height*Math.sin(alpha),y+height*Math.cos(alpha)-width*Math.sin(alpha))
            var p3=Qt.point(x+height*Math.sin(alpha),y+height*Math.cos(alpha))
            figure = component.createObject(figures, {name:name,index:getIndex(name),p0Coord:p0,p1Coord:p1,p2Coord:p2,p3Coord:p3});
        }
        if (name === "surface"){
            component = Qt.createComponent("DragSurface.qml");
            var p0=Qt.point(x,y)
            var p1=Qt.point(x+width,y)
            var p2=Qt.point(x+width,y+height)
            var p3=Qt.point(x,y+height)
            figure = component.createObject(figures, {name:name,index:getIndex(name),p0Coord:p0,p1Coord:p1,p2Coord:p2,p3Coord:p3});
        }
        if (name === "spiral"){
            component = Qt.createComponent("DragSpiral.qml");
            figure = component.createObject(figures, {name:name,index:getIndex(name),centerCoord:center,rMax:width/2});
        }
        if (name === "cross"){
            component = Qt.createComponent("DragCross.qml");
            figure = component.createObject(figures, {name:name,index:getIndex(name),centerCoord:center,radius:width/2});
        }
        if (name === "arrow"){
            var origin=Qt.point(points[0].X,points[0].Y)
            var end=Qt.point(0,0)

            for (var i=0;i<points.length;i++){
                if((points[i].X-origin.x)*(points[i].X-origin.x) + (points[i].Y-origin.y)*(points[i].Y-origin.y) > end.x*end.x+end.y*end.y){
                    end.x=points[i].X-origin.x
                    end.y=points[i].Y-origin.y
                }
            }

            var angle = Math.atan2(end.y,end.x)
            width = Math.sqrt(end.x*end.x+end.y*end.y)
            height = 150

            end.x+=origin.x
            end.y+=origin.y
            component = Qt.createComponent("DragArrow.qml");
            figure = component.createObject(figures, {name:"arrow",index:getIndex(name),originCoord:origin,endCoord:end});
        }
        if (figure === null) {
            // Error Handling
            console.log("Error creating object");
        }
        else {
            figure.setIndexes(getIndexes(name))
        }
    }

    function createRect(x,y,width,height){
        var component = Qt.createComponent("DragRectangle.qml");
        var p0=Qt.point(x,y)
        var p1=Qt.point(x+width,y)
        var p2=Qt.point(x+width,y+height)
        var p3=Qt.point(x,y+height)
        var figure = component.createObject(figures, {name:"rect",index:getIndex("rect"),p0Coord:p0,p1Coord:p1,p2Coord:p2,p3Coord:p3});
        figure.setIndexes(getIndexes("rect"))
    }


    function getImagePosition(x,y){
        var imx = x/map.paintedWidth * map.sourceSize.width;
        var imy = y/map.paintedHeight * map.sourceSize.height;
        return Qt.point(imx,imy)
    }
    function getIndexes(name){
        if (name === "circle")
            return indexCircles
        if (name === "rect")
            return indexRects
        if (name === "arrow")
            return indexArrows
        if (name === "surface")
            return indexSurfaces
        if (name === "spiral")
            return indexSpirals
        if (name === "cross")
            return indexCrosses
        return null
    }

    function getIndex(name){
        var indexes = getIndexes(name)

        for(var i = 0;i< indexes.length+1;i++)
            if (indexes.indexOf(i)<0){
                indexes.push(i)
                return i
            }
    }
}
