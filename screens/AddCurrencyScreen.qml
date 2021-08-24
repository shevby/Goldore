import QtQuick 2.15
import QtQuick.Controls.Material 2.12

import "../scripts" as Scripts

Item {
    height: stackView.height
    width: stackView.width

    function update() {}

    Column {
        anchors.fill: parent

        anchors.leftMargin: 10
        anchors.topMargin: 10
        spacing: 5
        Text {
            text: "Add Currency"
            font.pointSize: 20
            color: main.colors.white
        }

        Text {
            text: "Currency name:"
            font.pointSize: 14
            color: main.colors.white
        }

        TextField {
            id: currencyName
            Material.foreground: main.colors.white
            onTextChanged: {
                text = text.toUpperCase();
            }
        }

        Text {
            text: "Rate:"
            font.pointSize: 14
            color: main.colors.white
        }

        TextField {
            id: currencyRate
            Material.foreground: main.colors.white
            validator: RegularExpressionValidator {
               regularExpression: new RegExp("^-?[0-9]+([.][0-9]{1,2})?$")
            }
        }

    }

    Button {
        id: addButton
        text: "Add"
        font.pointSize: 14
        width: parent.width
        anchors.bottom: parent.bottom

        onClicked: {
            const name = currencyName.text;
            var rate = Number(currencyRate.text);
            rate = isNaN(rate) ? 0 : rate;

            if(name.length < 3) return;

            main.db.transaction(function(tx) {
                main.settings.primaryCurrency = name;
                Scripts.DB.insert(tx, Scripts.DB.CURRENCY_TABLE_NAME, ["name", "rate"], [name, rate]);
                Scripts.DB.setSettings(tx, main.settings);
                Scripts.DB.setLastUpdateTime(tx);
            });

            main.switchScreen("main");
        }
    }
}
