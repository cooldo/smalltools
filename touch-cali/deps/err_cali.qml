import QtQuick 2.6
import QtQuick.Window 2.2
import performancemonitor 1.0

Window {
    visible: true
    width: Screen.width
    height: Screen.height
    color: "yellow"
    visibility: Window.FullScreen

    MouseArea {
        anchors.fill: parent
    }

    Text {
        id: myText
        anchors.centerIn: parent
        font.family: "Helvetica"
        font.pointSize: 30
        color: "black"
    }

    function stopTimerAndQuit() {
        startTimer.running = false
        startTouchTimer.running = false
        quitTimer.running = true

    }

    Process {
        id: detectMouse
        property string hasMouse: "false"
        onReadyReadStandardOutput: {
            hasMouse = readAllStandardOutput()
            if (hasMouse.indexOf("true") != -1) {
                hasMouse = "true"
                stopTimerAndQuit()
                hasMouse = "true"
                quitTimer.running = true
                myText.text = "A MOUSE IS DETECTED, EXIT TOUCH CALI"
                myText.color = "red"
                myText.font.bold = true
            }
        }
    }

    Process {
        id: detectTouchNum
        property int touchNum: 0
        onReadyReadStandardOutput: {
            touchNum = readAllStandardOutput()
            if (touchNum >= detectScreenNum.screenNum) {
                stopTimerAndQuit()
                myText.text = "Screen numbers("+detectScreenNum.screenNum+")"+" match event numbers("+touchNum+") "+",please wait!!"
                myText.color = "red"
                myText.font.bold = true
            }
            else {
                if ( detectMouse.hasMouse !== "true" ) {
                    myText.text = "Screen numbers("+detectScreenNum.screenNum+")"+" cannot match event numbers("+touchNum+") "+",please check USB!!"
                }
            }
        }
    }

    Process {
        id: detectScreenNum
        property int screenNum: 0
        onReadyReadStandardOutput: {
            screenNum = readAllStandardOutput()
            startTouchTimer.running = true
        }
        Component.onCompleted: {
            start("/bin/bash /opt/touch-cali/deps/screen_number.sh" );
        }
    }

    Timer {
        id: startTouchTimer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: false
        onTriggered: {
            detectTouchNum.start("/bin/bash /opt/touch-cali/deps/touch_number.sh" );
        }
    }

    Timer {
        id: startTimer
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: true
        onTriggered: {
            detectMouse.start("/bin/bash /opt/touch-cali/deps/mouse_detect.sh" );
        }
    }

    Timer {
        id: quitTimer
        interval: 3000
        repeat: false
        running: false
        onTriggered: {
            Qt.quit()
        }
    }
}
