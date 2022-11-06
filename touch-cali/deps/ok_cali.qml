import QtQuick 2.6
import QtQuick.Window 2.2

Window {
    visible: true
    width: Screen.width
    height: Screen.height
    color: "green"
    visibility: Window.FullScreen

    MouseArea {
        anchors.fill: parent
    }
    Text {
        anchors.centerIn: parent
        text: "Aleady Calibrated!"
        font.family: "Helvetica"
        font.pointSize: 30
        color: "white"
    }
}
