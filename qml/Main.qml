import QtQuick 2.7
import QtQuick.Layouts 1.1
import Qt.labs.settings 1.0
import Ubuntu.Components 1.3
import io.thp.pyotherside 1.2

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'ethereumprice.ropod7'
    automaticOrientation: false
    //width: units.gu(45)
    //height: units.gu(75)
    property int tableWith: 18

    Image {
        source: "../assets/ethereum_bkg.png"
        anchors.centerIn: parent
        scale: 1.5
    }

    Page {
        anchors.fill: parent
        header: PageHeader {
            width: parent.width
            //height: units.dp(5)
            title: i18n.tr('Ethereum Market Price')
            z: 15
        }

        Label {
            id: labelUSD
            anchors.centerIn: parent
            text: i18n.tr('Loading...')
            height: units.gu(7)
            anchors.verticalCenterOffset: units.gu(-10)
            font.family: "Ubuntu"
            font.bold: true
            font.wordSpacing: units.gu(tableWith - text.length)
            font.underline: false
            color: "white"
            visible: true
        }

        Label {
            id: labelEUR
            anchors.centerIn: parent
            text: i18n.tr('Loading...')
            height: labelUSD.height
            anchors.verticalCenterOffset: units.gu(-6)
            font {
                family: labelUSD.font.family
                bold: labelUSD.font.bold
                underline: labelUSD.font.underline
                wordSpacing: units.gu(tableWith - text.length)
            }
            color: labelUSD.color
            visible: false
        }

        Label {
            id: labelBTC
            anchors.centerIn: parent
            text: i18n.tr('Loading...')
            height: labelUSD.height
            anchors.verticalCenterOffset: units.gu(-2)
            font {
                family: labelUSD.font.family
                bold: labelUSD.font.bold
                underline: labelUSD.font.underline
                wordSpacing: units.gu(tableWith - text.length)
            }
            color: labelUSD.color
            visible: false
        }

        Button {
            id: refresh
            anchors.centerIn: parent
            anchors.verticalCenterOffset: units.gu(15)
            z: 15
            height: units.dp(50)
            Label {
                id: buttonText
                color: "black"
                text: i18n.tr('Refresh')
                anchors.centerIn: parent
                font.family: "Ubuntu"
                font.bold: true
            }

            gradient: Gradient {
                        GradientStop { position: 0.0; color: "lightgray" }
                        GradientStop { position: 0.1; color: "gray" }
                    }

            MouseArea {
                id: mousearea
                anchors.fill: parent

                onPressed: {
                    python.call('priceHandler.handle', ["kraken"], function(prices) {
                        python.handle(prices);
                    })
                    python.setDiffResult(i18n.tr("Refreshing..."));
                }
            }

            states:
                State {
                    id: statePressed
                    name: "pressed"; when: mousearea.pressed
                    PropertyChanges { target: refresh; color: "black" }
                    PropertyChanges { target: buttonText; color: "darkgray" }
                }
            transitions: Transition {
                    ColorAnimation { duration: 1000 }
                }
        }
    }

    Python {
        id: python

        function setDiffResult(result) {
            labelUSD.font.wordSpacing = units.gu(.4);
            labelUSD.text = result;
            labelUSD.font.underline = false;
            labelEUR.visible = false;
            labelBTC.visible = false;
        }

        function handle(prices) {
            var result;
            if (prices === "none") {
                python.setDiffResult("No network connection.");
            } else {
                try {
                    labelUSD.text = "USD: " + JSON.parse(prices).usd;
                    labelEUR.text = "EUR: " + JSON.parse(prices).eur;
                    labelBTC.text = "BTC: " + JSON.parse(prices).btc;
                    labelUSD.font.wordSpacing = units.gu(root.tableWith - labelUSD.text.length);
                    labelUSD.font.underline = true;
                    labelEUR.visible = true;
                    labelBTC.visible = true;
                } catch (e) {
                    console.log("JS exception: " + e);
                    python.setDiffResult("Unknown error.");
                }
            }
        }

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../src/'));

            importModule('priceHandler', function() {
                python.call('priceHandler.handle', ["kraken"], function(prices) {
                    handle(prices);
                })
            })
        }

        onError: {
            console.log('python error: ' + traceback);
        }
    }
}

