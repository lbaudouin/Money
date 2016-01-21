import QtQuick 2.0

Rectangle {
    id: selector

    property alias model: listModel
    property int columns: 3

    signal selected(int code, string text);

    ListModel {
        id: listModel
    }

    Grid{
        id: grid
        anchors.fill: parent
        columns: selector.columns

        Repeater{
            model: listModel

            Rectangle{
                width: grid.width / grid.columns
                height: width

                color: "white"

                border.width: 2
                border.color: "black"

                Image{
                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    source: image===""?"":("images/"+image)
                }

                Text{
                    text: image===""?name:""
                    anchors.centerIn: parent
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {
                        selected(code,name)
                    }
                }
            }
        }
    }
}
