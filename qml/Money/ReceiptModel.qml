import QtQuick 2.0

ListModel {
    property int shopID: -1
    property string shopName: ""

    property int receiptID: -1

    onReceiptIDChanged: reload()

    property date receiptDate: new Date();

    property double total: 0

    function reload(){
        if(receiptID>=0){
            var data = sql.getReceipt(receiptID);
            console.debug(JSON.stringify(data))

            clear()
            total = 0

            for(var d in data){
                append(data[d]);
                total += data[d].price - data[d].promo
            }
        }
    }
}
