import QtQuick 2.0
import "PCA.js" as PCA

Item{
    id: figures
    property var listFigure: []
    property var arrow: null
    property var pca: new PCA.PCA();
    property int index: 0
    property var types: []
    property bool toDelete: false
    anchors.fill:parent

    function createFigure(name, points){
        var x=window.width
        var y= window.height
        var max_x=0
        var max_y= 0
        var data=[]
        for (var i=0;i<points.length;i++){
            x=Math.min(x,points[i].X)
            max_x=Math.max(max_x,points[i].X)
            y=Math.min(y,points[i].Y)
            max_y=Math.max(max_y,points[i].Y)
            data.push([points[i].X,points[i].Y])
        }


        var component = null
        var figure = null

        var width = (max_x-x)
        var height = (max_y-y)
        if (name === "circle"){
            component = Qt.createComponent("DragRectangle.qml");
            width = Math.max(width,height)
            figure = component.createObject(figures, {name:"circle",index=index,objX:x,objY:y,objWidth:width,objHeight:width,z:10,radius:width/2});
        }
        if (name === "rec"){
            component = Qt.createComponent("DragRectangle.qml");
            figure = component.createObject(figures, {name:"rect",index=index,objX:x,objY:y,objWidth:width,objHeight:height,z:10});
        }
        if (name === "surface"){
            component = Qt.createComponent("DragRectangle.qml");
            figure = component.createObject(figures, {name:"surface",index=index,rectColor: "red",opacity:0.5,objX:x,objY:y,objWidth:width,objHeight:height,z:10});
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

            console.log(angle*360/(2*Math.PI))
            end.x+=origin.x
            end.y+=origin.y
            component = Qt.createComponent("DragArrow.qml");
            figure = component.createObject(figures, {name:"arrow",index=index,objX:origin.x-width/2*(1-Math.cos(angle)),objY:origin.y-height/2+width/2*Math.sin(angle),objWidth:width,objHeight:height,rotation:angle*360/(2*Math.PI),z:10});

              /* if using pca:
                var vectors = pca.getEigenVectors(data);
                console.log("vector")
                console.log(vectors[0].vector[0])
                console.log(vectors[0].vector[1])
                var rot = Math.atan2(-vectors[0].vector[1],vectors[0].vector[0])*360/(2*Math.PI)
                console.log(rot)
            */
        }
        if (figure === null) {
            // Error Handling
            console.log("Error creating object");
        }
        else {
            figures.index += 1
            sendCommand("viz")
        }
    }

    function getStringItem(item){
        var width = item.objWidth*item.scale/map.paintedWidth * map.sourceSize.width
        var height = item.objHeight*item.scale/map.paintedWidth * map.sourceSize.width
        var mid = getImagePosition(item.x+item.width/2,item.y+item.height/2)
        return item.name+":"+parseInt(item.index)+":"+parseInt(mid.x)+":"+parseInt(mid.y)+":"+parseInt(width)+":"+parseInt(height)+":"+parseInt(item.rotation)
    }

    function sendCommand(type){
        var str=type
        for (var i = 0; i < figures.children.length; i++) {
            var item = figures.children[i]
            str+=";"+getStringItem(figures.children[i])
        }
        commandPublisher.text=str

    }

    function getImagePosition(x,y){
        var off_x = (map.width-map.paintedWidth)/2
        var off_y = (map.height-map.paintedHeight)/2
        var imx = (x - off_x)/map.paintedWidth * map.sourceSize.width;
        var imy = (y - off_y)/map.paintedHeight * map.sourceSize.height;
        return Qt.point(imx,imy)
    }
}
