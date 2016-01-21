import QtQuick 2.0
import QtQuick.Controls 1.4

Rectangle {

    signal back()
    signal accepted(string name, int quantity, double price, double promo)

    Column{
        id: column
        width: parent.width
        TextField{
            id: input
            width: parent.width

            Keys.onTabPressed: {
                var auto = sql.findArticle(input.text);
                if(auto!==""){
                    input.text = auto
                }
            }
        }
        SpinBox{
            id: quantitySpinBox
            width: parent.width
            minimumValue: 1
        }
        SpinBox {
            id: priceSpinBox
            decimals: 2
            maximumValue: 1500
        }
        SpinBox {
            id: promoSpinBox
            decimals: 2
            maximumValue: 1500
        }
    }

    ListView{
        anchors.top: column.bottom
        anchors.bottom: buttons.top

    }

    Item{
        id: buttons
        anchors.bottom: parent.bottom
        width: parent.width
        height: backButton.height
        Row{
            Button{
                id: backButton
                text: qsTr("Back")
                onClicked: back()
            }
            Button{
                id: validButton
                enabled: input.text !== ""
                text: qsTr("Add")
                onClicked: accepted(input.text, quantitySpinBox.value, priceSpinBox.value, promoSpinBox.value)
            }
        }
    }

}
