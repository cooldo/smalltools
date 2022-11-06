import QtQuick 2.6
import QtQuick.Window 2.2

Window {
    visible: true
    width: Screen.width
    height: Screen.height
    color: "red"
    visibility: Window.FullScreen

    MouseArea {
        anchors.fill: parent
    }
    Text {
        anchors.centerIn: parent
        text: "Please touch the screen for calibration!"
        font.family: "Helvetica"
        font.pointSize: 30
        color: "white"
    }

}
