import QtQuick 2.0
import "PCA.js" as PCA

Item{
    id: figures
    property var listFigure: []
    property var arrow: null
    property var pca: new PCA.PCA();


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
            figure = component.createObject(figures, {x:x,y:y,width:width,height:width,z:10,radius:width/2});
            //figures.listFigure.push(figure);
            if (figure === null) {
                // Error Handling
                console.log("Error creating object");
            }
        }
        if (name === "rec"){
            component = Qt.createComponent("DragRectangle.qml");
            figure = component.createObject(figures, {x:x,y:y,width:width,height:height,z:10});
            //figures.listFigure.push(figure);
            if (figure === null) {
                // Error Handling
                console.log("Error creating object");
            }
        }
        if (name === "surface"){
            component = Qt.createComponent("DragRectangle.qml");
            figure = component.createObject(figures, {color: "red",opacity:0.5,x:x,y:y,width:width,height:height,z:10});

            //figures.listFigure.push(figure);
            if (figure === null) {
                // Error Handling
                console.log("Error creating object");
            }
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

            end.x+=origin.x
            end.y+=origin.y
            component = Qt.createComponent("DragArrow.qml");
            figure = component.createObject(figures, {x:x,y:y,width:width,height:height,origin:origin,end:end,z:10});
            //figures.listFigure.push(figure);
            if (figure === null) {
                // Error Handling
                console.log("Error creating object");
            }
            /* if using pca:
                var vectors = pca.getEigenVectors(data);
                console.log("vector")
                console.log(vectors[0].vector[0])
                console.log(vectors[0].vector[1])
                var rot = Math.atan2(-vectors[0].vector[1],vectors[0].vector[0])*360/(2*Math.PI)
                console.log(rot)
            */
        }
    }
    function getImagePosition(x,y){
        var off_x = (map.width-map.paintedWidth)/2
        var off_y = (map.height-map.paintedHeight)/2
        var imx = (x - off_x)/map.paintedWidth * map.sourceSize.width;
        var imy = (y - off_y)/map.paintedHeight * map.sourceSize.height;
        var str = "x:"+parseInt(imx)+":y:"+parseInt(imy)
        commandPublisher.text=str
        console.log(str)
    }

}
