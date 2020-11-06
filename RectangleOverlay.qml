import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

Item{
    id: overlay
    property var action: ""
    property var target: ""
    property bool additionalVisible: true
    property bool toolTipVisible: false
    property int toolTipIndex: 0
    property var tips: [""]

    function nextTip(){
        if(toolTipIndex<tips.length-1){
            toolTipIndex+=1
            toolTipVisible = true
        }
        else{
            toolTipIndex = 0
            toolTipVisible = false
        }
    }

    ButtonGroup {
        id: objectType
        buttons: objects.children
        property var selected: ""
        onSelectedChanged: {
            selectedPois()
            timerHint.restart()
            updateObjects()
            toolTipIndex = 0
            toolTipVisible = false
            target = selected

            move.checked = false
            loosen.checked = false
            tighten.checked = false
            wipe.checked = false
            pull.checked = false

            if(target === "screws"){
                move.visible = true
                loosen.visible = true
                tighten.visible = true
                wipe.visible = false
                pull.visible = false
                push.visible = false
                if(actionType.selected !== "Loosen" && actionType.selected !== "Tighten")
                    actionType.selected = ["Move"]
                tips = ["","To move an object, drag the colored handle to the desired position",
                        "You can change the actions and the order by checking the boxes on the left or clicking the small arrow up button",
                        "The series of actions will be applied to every object of the selected type"]
            }
            if(target === "drawers"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                wipe.visible = false
                pull.visible = true
                push.visible = true
                actionType.selected = ["Pull"]
                tips = ["","To change the selected objects, move the corners of the area","You can change the action by checking and unchecking the buttons on the left"]
            }
            if(target === "area"){
                move.visible = false
                loosen.visible = false
                tighten.visible = false
                wipe.visible = true
                pull.visible = false
                push.visible = false
                actionType.selected = ["Wipe"]
                wipe.checked = true
                console.log(actionType.selected)
                target = figures.colorNames[index]+" Area"
                tips = ["","The robot will wipe the selected area with the object located at the handle"]
            }
            if(target === "object"){
                move.visible = true
                loosen.visible = false
                tighten.visible = false
                wipe.visible = false
                pull.visible = false
                push.visible = false
                actionType.selected = ["Move"]
                tips = ["","The robot will move the object from the starting handle to the goal one",
                        "The right (R) and left (L) handles represent the fingers of the robot and can be rotated"]
            }

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
        anchors.leftMargin: 25*k
        property int objectLength: objectsColumn.objectLength
        z:240
        ColumnLayout {
            id: objectsColumn
            property int objectLength: 5
            GuiRadioButton {
                text: "Screws"
                group: objectType
            }
            //GuiRadioButton {
            //    text: "Holes"
            //    group: objectType
            //}
            GuiRadioButton {
                text: "Pushers"
                group: objectType
            }
            GuiRadioButton {
                text: "Object"
                group: objectType
            }
            GuiRadioButton {
                text: "Area"
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
    anchors.topMargin: 25*k
    anchors.left:overlay.left
    checked: false
    //visible:objects.visible
    visible: false
    indicator: Rectangle {
        implicitWidth: 26*k
        implicitHeight: 26*k
        x: inspect.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3*k
        border.color: inspect.down ? "#696969" : "black"

        Rectangle {
            width: 14*k
            height: 14*k
            x: 6*k
            y: 6*k
            radius: 2*k
            color: inspect.down ? "#696969" : "black"
            visible: inspect.checked
        }
    }
    contentItem: Text {

        text: "Inspect"
        font.family: "Helvetica"
        font.pointSize: 15*k
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
        z:500
        id: actionDisplay
        text:action+" "+target
        anchors.bottom: overlay.top
        anchors.bottomMargin: 25*k
        anchors.left: overlay.left
        font.bold: true
        font.pointSize: 15*k
        style: Text.Outline
        styleColor: "black"
        color: "white"
    }

    Rectangle {
        id: backTitle
        anchors.top: actionDisplay.top
        anchors.topMargin: -10*k
        anchors.bottom: actionDisplay.bottom
        anchors.bottomMargin: -10*k
        anchors.right:actionDisplay.right
        anchors.rightMargin: -10*k
        anchors.left: actionDisplay.left
        anchors.leftMargin: -10*k
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
        MouseArea{
            anchors.fill: parent
        }
    }
    Label{
        z:50
        id: toolTip
        visible: additionalVisible && toolTipVisible
        wrapMode: Text.WordWrap
        text: tips[toolTipIndex]
        anchors.top: overlay.bottom
        anchors.topMargin: 25*k
        anchors.left: overlay.left
        anchors.right: overlay.right
        anchors.rightMargin: 10*k
        color: "white"
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica"
        font.pointSize: 17*k
        font.bold: true
        style: Text.Outline
        styleColor: "black"
    }
    Label{
        z:50
        id: tipCounter
        visible: additionalVisible && toolTipVisible
        text: toolTipIndex.toString()+"/"+(tips.length-1).toString()
        anchors.bottom: backToolTip.bottom
        anchors.bottomMargin: 5*k
        anchors.right: backToolTip.right
        anchors.rightMargin: 5*k
        color: "white"
        verticalAlignment: Text.AlignVCenter
        font.family: "Helvetica"
        font.pointSize: 17*k
        font.bold: true
        style: Text.Outline
        styleColor: "black"
    }

    Rectangle {
        id: backToolTip
        visible: toolTip.visible
        anchors.top: toolTip.top
        anchors.topMargin: -10*k
        anchors.bottom: toolTip.bottom
        anchors.bottomMargin: -25*k
        anchors.right:overlay.right
        anchors.left: toolTip.left
        anchors.leftMargin: -10*k
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
        MouseArea{
            anchors.fill: parent
        }
    }
    Item {
        id: actions
        visible:objects.visible
        anchors.top: overlay.top
        anchors.right:overlay.left
        anchors.rightMargin: width/10
        width: 150*k
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
        onActionLengthChanged: console.log(actionLength)
    }

    Rectangle {
        id: backActions
        anchors.top: overlay.top
        anchors.right:actions.right
        anchors.rightMargin: -10*k
        anchors.left: actions.left
        anchors.leftMargin: -10*k
        height: loosen.height * 1.1 * actions.actionLength
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
        MouseArea{
            anchors.fill: parent
        }
    }
    Rectangle {
        id: backObjects
        anchors.top: overlay.top
        anchors.right:objects.right
        anchors.rightMargin: -10*k
        anchors.left: objects.left
        anchors.leftMargin: -10*k
        height: loosen.height * 1.1 * objects.objectLength
        color: "grey"
        z:2
        opacity: .5
        radius: map.width/130
        visible: additionalVisible
        MouseArea{
            anchors.fill: parent
        }
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
