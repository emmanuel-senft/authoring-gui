import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

Item{
    id: overlay
    property var action: ""
    property var target: ""
    property bool additionalVisible: false

    ButtonGroup {
        id: objectType
        buttons: objects.children
        property var selected: ""
        onSelectedChanged: {
            selectedPois()
            target = selected
            if(target === "screws"){
                move.visible = true
                loosen.visible = true
                tighten.visible = true
                wipe.visible = false
                pull.visible = false
                if(actionType.selected !== "Loosen" && actionType.selected !== "Tighten")
                    actionType.selected = ["Move"]
            }
            if(target === "pushers"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                wipe.visible = false
                pull.visible = false
                actionType.selected = ["Push"]
            }
            if(target === "drawers"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                wipe.visible = false
                pull.visible = true
                actionType.selected = ["Pull"]
            }
            if(target === "surface"){
                console.log("in surface")
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                wipe.visible = true
                pull.visible = false
                actionType.selected = ["Wipe"]
                wipe.checked = true
                console.log(actionType.selected)
                target = figures.colorNames[index]+" Area"
            }
            if(target === "unknown"){
                move.visible = true
                loosen.visible = false
                tighten.visible = false
                wipe.visible = false
                pull.visible = false
                actionType.selected = ["Move"]
            }
            console.log(actionType.selected)
            for(var i =0; i<actions.children.length;i++){
                if(actionType.selected.includes(actions.children[i].name)){
                    actions.children[i].checked = true
                }
                else{
                    actions.children[i].checked = false
                }
            }
        }
    }
    Column {
        id: objects
        visible:overlay.additionalVisible
        anchors.top: overlay.top
        anchors.left:overlay.right
        anchors.leftMargin: 25
        property int objectLength: 5
        z:240
        ColumnLayout {
            GuiRadioButton {
                text: "Screws"
                group: objectType
            }
            GuiRadioButton {
                text: "Holes"
                group: objectType
            }
            GuiRadioButton {
                text: "Pushers"
                group: objectType
            }
            GuiRadioButton {
                text: "Unknown"
                group: objectType
            }
            GuiRadioButton {
                text: "Surface"
                group: objectType
            }
            GuiRadioButton {
                text: "Drawers"
                group: objectType
            }
        }
        onVisibleChanged: {
            delayDisplay.start()
        }
        Timer{
            id:delayDisplay
            interval:20
            repeat: false
            onTriggered: actionType.updateOrder()
        }
    }
    ButtonGroup {
        id: actionType
        buttons: actions.children
        property var selected: []
        exclusive: false
        onSelectedChanged: {
            update()
        }
        function up(index){
            for(var i=0; i<actions.children.length;i++)
                if(actions.children[i].order === index){
                   actions.children[i].order = index+1
                   break
                }
        }
        function updateSelected(){
            var sel = []
            var order = []
            var final_sel = []
            for(var i=0; i<actions.children.length;i++){
                if( actions.children[i].checked){
                    sel.push(actions.children[i].name)
                    order.push(actions.children[i].order)
                }
            }
            for(var i=0; i<order.length;i++){
                final_sel.push(sel[order.indexOf(i+1)])
            }
            selected = final_sel
        }

        function update(){
            for(var i=0; i<actions.children.length;i++){
                var item = actions.children[i]
                var index = selected.indexOf(item.name)+1
                if(index === 0){
                    if(item.checked){
                        item.checked = false
                    }

                }
                else{
                    item.checked = true
                    item.order = index
                }
            }
            updateOrder()
        }
        function updateOrder(){
            for(var i=0; i<actions.children.length;i++){
                var itema = actions.children[i]
                if(itema.order === null){
                    itema.position = 0
                    for(var j=0; j<actions.children.length;j++){
                        var itemb = actions.children[j]
                        if (itemb.checked || (itemb.visible && j < i)) {
                            itema.position +=1
                        }
                    }
                }
                else
                    actions.children[i].position = actions.children[i].order-1
            }
            updateAction()
        }

    }
    CheckBox {
    id: inspect
    anchors.top: overlay.bottom
    anchors.topMargin: 25
    anchors.left:overlay.left
    checked: false
    //visible:objects.visible
    visible: false
    indicator: Rectangle {
        implicitWidth: 26
        implicitHeight: 26
        x: inspect.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        border.color: inspect.down ? "#696969" : "black"

        Rectangle {
            width: 14
            height: 14
            x: 6
            y: 6
            radius: 2
            color: inspect.down ? "#696969" : "black"
            visible: inspect.checked
        }
    }
    contentItem: Text {

        text: "Inspect"
        font.family: "Helvetica"
        font.pointSize: 15
        font.bold: true
        style: Text.Outline
        styleColor: "black"
        color: "white"
        verticalAlignment: Text.AlignVCenter
        leftPadding: inspect.indicator.width + inspect.spacing
    }
    onCheckedChanged: updateAction()
    }
    Label{
        z:50
        id: actionDisplay
        text:action+" "+target
        anchors.bottom: overlay.top
        anchors.bottomMargin: 25
        anchors.left: overlay.left
        font.bold: true
        font.pixelSize: 30
        style: Text.Outline
        styleColor: "black"
        color: "white"
    }

    Item {
        id: actions
        visible:objects.visible
        anchors.top: overlay.top
        anchors.right:overlay.left
        anchors.rightMargin: width/10
        width: 240
        property int actionLength: 0
        z:3
        GuiCheckBox {
            id: move
            text: "Move"
            group: actionType
            name:text
            index: 0
        }
        GuiCheckBox {
            id: tighten
            text: "Tighten"
            group: actionType
            name:text
            index: 1
        }
        GuiCheckBox {
            id: pull
            text: "Pull"
            group: actionType
            name:text
            index: 1
        }
        GuiCheckBox {
            id: loosen
            text: "Loosen"
            group: actionType
            name:text
            index: 2
        }
        GuiCheckBox {
            id: push
            text: "Push"
            group: actionType
            visible: pull
            name:text
            index: 3
        }
        GuiCheckBox {
            id: wipe
            text: "Wipe"
            group: actionType
            name:text
            index: 4
        }
    }

    Rectangle {
        id: backActions
        anchors.top: overlay.top
        anchors.right:actions.right
        anchors.rightMargin: -10
        anchors.left: actions.left
        anchors.leftMargin: -10
        height: loosen.height * 1.1 * actions.actionLength
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
    }
    Rectangle {
        id: backObjects
        anchors.top: overlay.top
        anchors.right:objects.right
        anchors.rightMargin: -10
        anchors.left: objects.left
        anchors.leftMargin: -10
        height: loosen.height * 1.1 * objects.objectLength
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
        visible: additionalVisible
    }

    function setObjectSelected(sel){
        objectType.selected = sel
    }
    function getObjectSelected(){
        return objectType.selected
    }
    function getActionsSelected(){
        return actionType.selected
    }

    function getObjects(){
        return objects
    }
    function getActions(){
        return actions
    }
    function getInspect(){
        return inspect.checked
    }
    function setInspect(val){
        inspect.checked = val
    }
}
