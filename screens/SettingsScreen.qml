import QtQuick 2.15
import QtQuick.Controls.Material 2.12
import "../scripts" as Scripts

Item {
    height: stackView.height
    width: stackView.width

    Column {
        width: parent.width
        height: parent.height
        spacing: 5
        anchors.leftMargin: 10
        anchors.rightMargin: 10

        Item {
            height: parent.height * 0.4
            width: parent.width
            Text {

                font.pointSize: 40
                text: "Goldore"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

            }
        }

        Button {
            width: parent.width
            font.pointSize: 14
            text: "Add Income"
        }

        Button {
            width: parent.width
            font.pointSize: 14
            text: "Add Need"
            onClicked: main.switchScreen("addNeed")
        }

        Button {
            width: parent.width
            font.pointSize: 14
            text: "Add Currency"
        }
        Button {
            width: parent.width
            font.pointSize: 14
            text: "Drop DB"
            onClicked: {
                main.db.transaction((tx)=>{
                    Scripts.DB.dropDB(tx);
                    Scripts.DB.initDB(tx);
                });

                main.switchScreen("main");
            }
        }





    }
}
