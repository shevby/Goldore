import QtQuick 2.15
import QtQuick.Controls.Material 2.12

import "../scripts" as Scripts

Item {
    height: stackView.height
    width: stackView.width

    function update() {
        gridView.model.clear();
        gridView.selected = -1;

        let icons;

        main.db.transaction(function(tx) {
            icons = Scripts.DB.getAllIcons(tx);
        });

        icons.forEach((icon)=>{
                          gridView.model.append(icon);
                      });
    }

    Column {
        id: addNeedColumn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right

        anchors.leftMargin: 10
        anchors.topMargin: 10

        spacing: 5

        Text {
            text: "Add Need"
            font.pointSize: 20
            color: main.colors.white
        }

        Text {
            text: "Need name:"
            font.pointSize: 14
            color: main.colors.white
        }

        TextField {
            id: needName
            Material.foreground: main.colors.white
        }

        Text {
            text: "Icon:"
            font.pointSize: 14
            color: main.colors.white
        }

    }

    GridView {
        id: gridView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: addNeedColumn.bottom
        anchors.bottom: addNeedButton.top

        cellWidth: cWidth
        cellHeight: cHeight
        model: ListModel{}

        property var cWidth: parent.width / 3
        property var cHeight: parent.width / 3

        property var selected: -1

        delegate:  MouseArea {

            onClicked: {
                gridView.selected = model.index;
            }

            width: gridView.cWidth
            height: gridView.cHeight

            Rectangle {
                width: gridView.cWidth - 5
                height: gridView.cHeight - 5
                anchors.centerIn: parent
                color: model.index == gridView.selected ? main.colors.pink : main.colors.primary



                Image {
                    width: gridView.cWidth - 10
                    height: gridView.cHeight - 10
                    sourceSize: Qt.size(100, 100)
                    source: "data:image/svg+xml;utf8," + model.svg
                    anchors.horizontalCenter: parent.horizontalCenter
                }

            }


        }
    }

    Button {
        id: addNeedButton
        text: "Add"
        font.pointSize: 14
        width: parent.width
        anchors.bottom: parent.bottom
        enabled: gridView.selected >= 0 && needName.text.length >= 3


        onClicked: {
            var added = true;
            main.db.transaction(function(tx) {
                var needNames = Scripts.DB.select(tx, ["name"], Scripts.DB.NEEDS_TABLE_NAME).map((need)=>need.name);

                if(needNames.indexOf(needName.text.toString()) >= 0) {
                    messageDialog.open();
                    added = false;
                    return;
                }

                Scripts.DB.insert(tx, Scripts.DB.NEEDS_TABLE_NAME, ["name", "icon"], [needName.text, gridView.model.get(gridView.selected).rowid]);



            });

            if(added) {
                main.switchScreen("main");
            }

        }
    }

    Dialog {
        id: messageDialog
        title: "Need already registered!"
        width: parent.width
        height: 200
        anchors.centerIn: parent

        Component.onCompleted: visible = true

        Item {
            anchors.fill: parent

            Button{
                text: "Ok"
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: {
                    messageDialog.close();
                }
            }
        }
    }

}
