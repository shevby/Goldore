
import QtQuick 2.1
import QtQuick.Controls 2.1
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.LocalStorage 2.15

import "./screens" as Screens
import "./scripts" as Scripts
import "./components" as Components


Window {
    id: main
    width: 360
    height: 760
    visible: true
    title: "Goldore"
    Material.theme: Material.Dark

    property var colors: {
        "primary": "#455a64",
        "light": "#718792",
        "dark": "#1c313a",
        "grey": "#EEEEEE",
        "white": "#F5F5F5",
        "red": "#EF9A9A",
        "pink": "#F48FB1"
    }

    property var settings: {
        "primaryCurrency": ""
    }

    onClosing: {
        if(stackView.depth > 1) {
            close.accepted = false;
            stackView.pop();
            currentScreen.pop();
            main.screens[currentScreen[currentScreen.length - 1]].update();
        }
        else {
            close.accepted = true;
        }
    }




    property var mainScreen: Screens.MainScreen{}
    property var settingsScreen: Screens.SettingsScreen{}
    property var addCurrencyScreen: Screens.AddCurrencyScreen{}
    property var addNeedScreen: Screens.AddNeedScreen{}


    property var screens: {
        "main": mainScreen,
        "settings": settingsScreen,
        "addCurrency": addCurrencyScreen,
        "addNeed": addNeedScreen
    }

    property var db: undefined

    property var currentScreen: ["main"]

    function switchScreen(screenName) {

        if(Object.keys(screens).indexOf(screenName) < 0) {
            throw new Error("Screen \"" + screenName + "\" doesn't exist");
        }

        if(screenName === currentScreen[currentScreen.length - 1]) return;

        if(currentScreen.indexOf(screenName) >= 0) {
            while(currentScreen[currentScreen.length - 1] !== screenName) {
                stackView.pop();
                currentScreen.pop();
            }

            main.screens[currentScreen[currentScreen.length - 1]].update();

            return;
        }

        currentScreen.push(screenName);

        stackView.push(main.screens[screenName]);

        main.screens[currentScreen[currentScreen.length - 1]].update();

    }

    Component.onCompleted: {
        db = LocalStorage.openDatabaseSync("GoldoreDB", "", "Goldore Database", 1000000);

        db.transaction(
            function(tx) {
                let settings = Scripts.DB.initDB(tx);

                if(!settings) {
                    Scripts.DB.setSettings(tx, main.settings)
                }
                else {
                    main.settings = settings;
                }

            }
        );

        mainScreen.update();
    }

    Rectangle {
        id: mainHeader
        width: parent.width
        height: 60
        color: colors.dark
        Material.elevation: 1
        z: 5


        Menu {
            id: menu
            height: main.height

            Material.background: colors.primary
            Item {
                height: main.height * 0.4
            }

            Components.MMenuItem {
                text: "Main"
                onClicked: main.switchScreen("main")
            }

            Components.MMenuItem {
                text: "Settings"
                onClicked: main.switchScreen("settings")
            }


        }

        Row {
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0

            Button {
                id: button
                width: 57
                text: qsTr("≡")
                font.pointSize: 17

                Material.elevation: 0
                Material.foreground: colors.white

                onClicked: {
                    menu.open();
                }
            }
        }


    }

    StackView {
        id: stackView
        anchors.top: mainHeader.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        background: Pane {
            anchors.fill: parent
            Material.background: colors.light
        }

        initialItem: main.screens.main
    }



}
