import QtQuick 2.0
import QtQuick.Controls 1.1

Rectangle {
    id: receiptBuilder
    width: 100
    height: 62

    signal back();
    onBack: console.debug("back")

    ReceiptModel{ id: receiptModel }



    Shops{
        id: shops
        width: parent.width
        height: parent.height

        onSelected: {
            receiptModel.receiptID = sql.createReceipt(shopID, receiptDate)
            receiptModel.shopID = shopID
            receiptModel.shopName = sql.getShopName(shopID)
            receiptModel.receiptDate = receiptDate
        }

        onBack: receiptBuilder.back()
    }

    Shopping{
        id: shopping
        width: parent.width
        height: parent.height

        x: width

        onBack:{
            sql.removeReceipt(receiptModel.receiptID)
            receiptModel.shopID = -1
            receiptModel.receiptID = -1
        }

        onFinished:{
            receiptBuilder.back();
        }
    }

    states: [
        State{
            name: "list"
            when: receiptModel.receiptID >= 0
            PropertyChanges { target: shops; x: -shops.width }
            PropertyChanges { target: shopping; x: 0 }
        }
    ]

    transitions:[
        Transition {
            NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad }
        }
    ]
}
