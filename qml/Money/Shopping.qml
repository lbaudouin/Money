import QtQuick 2.0
import QtQuick.Controls 1.1

Rectangle {
    id: shopping

    signal back();
    signal finished();

    Column{
        id: column
        width: parent.width
        Button{
            text: qsTr("Add")
            width: parent.width
            onClicked: loader.source = "ArticleSelector.qml"
        }
        Button{
            text: qsTr("Finished")
            width: parent.width
            onClicked: shopping.finished()
        }
        Button{
            text: qsTr("Back")
            width: parent.width
            onClicked: back()
        }
    }

    ShoppingList{
        anchors.top: column.bottom
        anchors.bottom: parent.bottom
        width: parent.width
    }

    Loader{
        id: loader
        anchors.fill: parent

        Connections {
            target: loader.item
            onBack: loader.source = ""
            onAccepted:{
                console.debug(name, quantity, price, promo)
                sql.addArticleToReceipt(receiptModel.receiptID, name, quantity, price, promo)
                loader.source = ""

                receiptModel.reload();
            }
        }

    }
}
