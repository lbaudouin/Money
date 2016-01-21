import QtQuick 2.0
import QtQuick.Window 2.0
import QtQuick.Controls 1.1

Rectangle {
    /*width: Screen.width
    height: Screen.height*/
    width: 480
    height: 640

    id: root

    property bool landscape: width>height

    Column{
        anchors.centerIn: parent

        width: 0.5*parent.width
        spacing: 10

        Button{
            text: qsTr("New receipt")
            width: parent.width

            onClicked: {
                loader.source = "ReceiptBuilder.qml"
            }
        }

        Button{
            text: qsTr("View receipts")
            width: parent.width

            onClicked: {
                loader.source = "ReceiptViewer.qml"
            }
        }

        Button{
            text: qsTr("Graph")
            width: parent.width

            onClicked: {
                loader.source = "Graph.qml"
            }
        }
    }


    Loader{
        id: loader

        width: parent.width
        height: 0

        anchors.verticalCenter: parent.verticalCenter

        state: ""
        states: [
            State { name: "loaded"; when: loader.status == Loader.Ready
                PropertyChanges { target: loader; height: root.height }
            }
        ]

        transitions: [
          Transition {
              from: ""; to: "loaded"
              NumberAnimation { properties: "height"; duration: 200 }

          }
        ]

        Connections {
            target: loader.item
            onBack: {
                loader.source = ""
            }
        }
    }
}
