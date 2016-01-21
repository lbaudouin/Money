import QtQuick 2.0

Rectangle {

    signal back()

    Component {
           id: sectionHeading
           Rectangle {
               width: ListView.view.width
               height: childrenRect.height
               color: "lightsteelblue"

               Text {
                   text: section
                   font.bold: true
                   font.pixelSize: 20
               }
           }
       }

    Component{
        id: listDelegate
        Rectangle{
            width: ListView.view.width
            height: childrenRect.height

            color: index%2?"lightgray":"white"


            Text{
                text: shop
                font.pointSize: 20
            }

            Text{
                anchors.right: parent.right
                text: total.toFixed(2) + " €"
                font.pointSize: 20
            }
        }
    }

    ListView{
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: buttonRect.top

        delegate: listDelegate

        model: ListModel{ id: listModel }

        section.property: "date"
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading
    }

    Rectangle{
        id: buttonRect
        width: parent.width
        height: backText.height * 1.5
        anchors.bottom: parent.bottom

        Text{
            id: backText
            text: qsTr("Back")
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
        }
        MouseArea{
            anchors.fill: parent
            onClicked: back();
        }
    }

    Component.onCompleted: {
        listModel.clear()
        var receipts = sql.getReceipts();
        for(var i=0;i<receipts.length;i++){
            listModel.append( receipts[i] )
        }
    }
}
