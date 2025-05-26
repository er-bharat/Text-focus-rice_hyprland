import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Window {
    id: root
    visible: true
    visibility: Window.FullScreen
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool

    property string suggestionText: ""

    // Background click-to-close area
    Rectangle {
        anchors.fill: parent
        color: "transparent" // optional: "#00000088" for dim effect
        z: -1

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Item {
            width: parent.width
            height: 200
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                id: ghost
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 150
                textFormat: Text.RichText
                font.family: "URW Gothic"
                font.weight: Font.Bold
                opacity: 0.5
                visible: input.text.length > 0 && root.suggestionText.length > 0
                text: {
                    let inputText = input.text
                    let full = root.suggestionText
                    let idx = full.toLowerCase().indexOf(inputText.toLowerCase())

                    if (idx === -1) return ""

                        let before = full.slice(0, idx)
                        let match = full.slice(idx, idx + inputText.length)
                        let after = full.slice(idx + inputText.length)

                        return `<span style="color:#FFFFFF4D">${before}</span>` +
                        `<span style="color:white">${match}</span>` +
                        `<span style="color:#FFFFFF4D">${after}</span>`
                }
                z: 0
            }

            // Custom placeholder text on top of input, only visible when input is empty
            Text {
                id: placeholderText
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 150
                font.family: "URW Gothic"
                font.weight: Font.Bold
                color: "#888888"
                visible: input.text.length === 0
                z: 2
                text: "Search apps"
            }

            TextField {
                id: input
                anchors.fill: parent
                font.pixelSize: 150
                color: "white"  // always white so cursor visible
                placeholderText: "Search apps..."
                placeholderTextColor: "#888888"
                selectionColor: "white"
                cursorVisible: true
                z: 1
                font.family: "URW Gothic"
                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                focus: true
                background: null

                onTextChanged: {
                    let suggestion = launcher.getAutocomplete(text)
                    root.suggestionText = suggestion
                }

                Keys.onReturnPressed: {
                    if (root.suggestionText !== "")
                        launcher.launch_app(root.suggestionText)
                        else
                            launcher.launch_app(text)
                            Qt.quit()
                }
            }

        }

        Keys.onEscapePressed: {
            Qt.quit()
        }

    }
}
