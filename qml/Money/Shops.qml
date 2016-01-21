import QtQuick 2.0
import QtQuick.Controls 1.1

Rectangle {
    id: shops
    width: 100
    height: 62

    signal back();
    onBack: console.debug("back")

    signal selected( date receiptDate, int shopID )


    Connections{
        target: receiptModel
        onReceiptDateChanged: dateInput.text = receiptModel.receiptDate.toLocaleDateString();
    }

    CalendarDialog{
        id: calendarDialog

        onSelected: receiptModel.receiptDate = date;
    }

    TextField{
        id: dateInput
        width: parent.width

        readOnly: true

        MouseArea{
            anchors.fill: parent
            onClicked: {
                calendarDialog.open()
            }
        }

        Component.onCompleted: {
            dateInput.text = receiptModel.receiptDate.toLocaleDateString();
        }
    }

    Selector{
        width: parent.width
        anchors.top: dateInput.bottom
        anchors.bottom: buttonRect.top

        columns: root.landscape?9:5

        onSelected: {
            console.debug(code,text)
            if(code===0){
                console.debug("Create shop")
            }else{
                shops.selected(receiptModel.receiptDate, code)
            }
        }

        Component.onCompleted: {
            model.clear()
            var shops = sql.getShops();
            for(var i=0;i<shops.length;i++){
                model.append( shops[i] )
            }
        }
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
            onClicked: shops.back();
        }
    }
}
