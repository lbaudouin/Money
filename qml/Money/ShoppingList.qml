import QtQuick 2.0

Item {
    Component{
        id: listDelegate
        Rectangle{
            width: ListView.view.width
            height: childrenRect.height

            color: index%2?"lightgray":"white"

            Text{
                text: name
                font.pointSize: 20
            }

            Text{
                anchors.right: parent.right
                text: (price-promo).toFixed(2) + " €"
                font.pointSize: 20
            }
        }
    }


    ListView{
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: line.top

        model: receiptModel

        delegate: listDelegate
    }

    Rectangle{
        id: line
        color: "black"
        height: 3
        width: parent.width
        anchors.bottom: totalRect.top
    }

    Rectangle{
        id: totalRect
        width: parent.width
        height: childrenRect.height
        anchors.bottom: parent.bottom

        Text{
            text: qsTr("Total")
            width: parent.width
            font.pointSize: 20
        }

        Text{
            id: total
            text: receiptModel.total.toFixed(2) + " €"
            font.pointSize: 20
            anchors.right: parent.right
        }
    }
}
