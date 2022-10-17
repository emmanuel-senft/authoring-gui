import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Shapes 1.15

Item{
    id: behaviorDisplay
    anchors.fill: parent
    ListView {
        anchors.left: behaviorDisplay.left
        anchors.leftMargin: parent.width/25
        anchors.top: parent.top
        anchors.topMargin: parent.height/4
        height: parent.height
        spacing: parent.width/15

        model: behaviorList
        delegate: behaviorDelegate
    }
    ListModel {
        id: behaviorList

        function addBehavior(trigger,list){
            print("adding")
            behaviorList.append({"trigger":trigger,"behavior":list})
        }
    }
    Component {
        id: actionDisplay
        Item{
            width: map.width/15; height: map.width/25
            Rectangle{
                anchors.fill: parent
                color: "white"
                opacity: .5
                radius: height/4
            }
            Row {
                id: imageRow
                anchors.centerIn: parent
                width: parent.width*.95
                height: parent.height
                spacing: width/32
                Item{
                    width: parent.width/3.2
                    height: parent.height
                    Image{
                       anchors.fill:parent
                       source: "/res/"+img1.split("_")[0]+".png"
                       fillMode: Image.PreserveAspectFit
                    }
                    //Text{
                    //    anchors.fill: parent
                    //    horizontalAlignment: Text.AlignHCenter
                    //    verticalAlignment: Text.AlignVCenter
                    //    text: img1.split("_")[1]
                    //    color: "white"
                    //    font.bold: true
                    //    font.pixelSize: parent.width/2
                    //}
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
                    //Text{
                    //    anchors.fill: parent
                    //    horizontalAlignment: Text.AlignHCenter
                    //    verticalAlignment: Text.AlignVCenter
                    //    text: img3.split("_")[1]
                    //    color: "white"
                    //    font.bold: true
                    //    font.pixelSize: parent.width/2
                    //}
                }
            }
        }
    }

    Component {
        id: behaviorDelegate
        Item{
            property var counter: 0
            GuiButton{
                id: bookButton
                x:0
                y:0
                z:10
                text: (counter+1).toString()
                color: figures.colors[counter]
                name: "bookmark"
                onClicked:{
                    pubCommand("play;behavior_"+counter.toString())
                    return
                    var l = behavior.split(";").slice(1).join(";")
                    print(l)
                    pubCommand("exec;"+l)
                }
            }
            ListView {
                anchors.left: bookButton.right
                anchors.leftMargin: bookButton.width/4
                anchors.verticalCenter: bookButton.verticalCenter
                width: 8*bookButton.width
                height: bookButton.height
                orientation: ListView.Horizontal
                spacing: anchors.leftMargin

                model: actionL
                delegate: actionDisplay
            }
            ListModel {
                id: actionL
                function addAction(act){
                    //Need to adapt to different format, reset and other
                    var img1 = act.split(":")[1].split("-")[0]
                    var img2 = act.split(":")[0]
                    var img3 = act.split(":")[1].split("-")[1]
                    actionL.append({"img1":img1,"img2":img2,"img3":img3})
                }
            }
            Component.onCompleted: {
                print(behavior)
                var entries = behavior.split(";")
                counter = parseInt(entries[0].split("_")[1])
                var acts = entries.slice(1,-1)
                print(acts)
                for(var i=0;i<acts.length;i++){
                    actionL.addAction(acts[i])
                }
            }
        }
    }
    function addTrigger(trigger){
        //behaviorList.addBehavior(trigger,"behavior_"+behaviorList.count.toString()+";Reset")
    }
    function addBehavior(behavior){
        behaviorList.append({"behavior":behavior})
        //behaviorList.addBehavior(trigger,"behavior_"+behaviorList.count.toString()+";Reset")
    }

    //Component.onCompleted: behaviorList.addBehavior("behavior_0;Move:screw_1-box_0;Reset")
    //Component.onCompleted: behaviorList.addBehavior("behavior_0;Reset")
}
