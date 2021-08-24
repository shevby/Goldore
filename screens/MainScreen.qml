import QtQuick 2.15

import "../scripts" as Scripts


Item {
    id: mainScreen
    height: stackView.height
    width: stackView.width
    visible: true

    property real cWidth: (mainScreen.width / 2)
    property real cHeight: 200

    property var icons: []


    function update() {
        let currency;

        main.db.transaction(function(tx){
            currency = Scripts.DB.select(tx, ["*"], Scripts.DB.CURRENCY_TABLE_NAME);

        });

        if(currency.length < 1) {
            main.switchScreen("addCurrency");
            return;
        }

        let needs;

        main.db.transaction(function(tx){
            needs = Scripts.DB.select(tx, ["*"], Scripts.DB.NEEDS_TABLE_NAME);
            currency = Scripts.DB.getCurrency(tx);
        });

        for(let i = 0; i < needs.length; i++) {
            let expenses;
            if(!icons[needs[i].icon]) {
                main.db.transaction(function(tx){
                    mainScreen.icons[needs[i].icon] = Scripts.DB.getIconById(tx, needs[i].icon);

                    expenses = Scripts.DB.getAllExpensesWithNeed(tx, needs[i].name);
                });

                needs[i].primaryCurrency = main.settings.primaryCurrency;

                var primarySum = 0;

                for(let i = 0; i < expenses.length; i++) {
                    if(main.settings.primaryCurrency === expenses[i].currency) {
                        primarySum += expenses[i].value;
                    }
                    else {
                        let currencyValue = currency[expenses[i].currency];

                        if(!currency) {
                            currencyValue = 1;
                        }

                        primarySum += (expenses[i].value / currencyValue) * currency[main.settings.primaryCurrency];
                    }
                }

                needs[i].primarySum = primarySum;
                needs[i].usdSum = primarySum / currency[main.settings.primaryCurrency];

                gridView.model.append(needs[i]);
            }

        }

    }

    GridView {
        id: gridView
        anchors.fill: parent
        topMargin: 10
        cellWidth: cWidth
        cellHeight: cHeight
        model: ListModel{}

        delegate:  Item {
            width: cWidth
            height: cHeight

            Rectangle {
                width: cWidth - 5
                height: cHeight - 5
                anchors.centerIn: parent
                color: main.colors.primary


                Column {
                    anchors.fill: parent
                    anchors.topMargin: 15
                    anchors.leftMargin: 10
                    Image {
                        height: 100
                        width: 100
                        sourceSize: Qt.size(100, 100)
                        source: "data:image/svg+xml;utf8," + mainScreen.icons[model.icon]
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: model.name
                        color: main.colors.white
                        font.pointSize: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Row {

                        Text {
                            font.pointSize: 14
                            color: main.colors.white
                            text: model.primaryCurrency + ": "
                        }

                        Text {
                            font.pointSize: 14
                            color: main.colors.white
                            text: model.primarySum.toFixed(2)
                        }
                    }

                    Row {

                        Text {
                            font.pointSize: 14
                            color: main.colors.white
                            text: "USD: "
                        }

                        Text {
                            font.pointSize: 14
                            color: main.colors.white
                            text: model.usdSum.toFixed(2)
                        }
                    }
                }

            }
        }


    }
}
