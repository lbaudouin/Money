import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4

Dialog {
    id: dialog

    signal selected(date date);

    contentItem: Calendar{
        width: 256
        height: 256

        onClicked: {
            dialog.selected(date)
            dialog.close()
        }
    }
}
