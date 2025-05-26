/***************************************************************************
 * Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 * OR OTHER DEALINGS IN THE SOFTWARE.
 *
 ***************************************************************************/

import QtQuick 2.0
import SddmComponents 2.0


Rectangle {
    id: container
    anchors.fill: parent  // fill the available window

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }
        onLoginFailed: {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    Image {
        id: bgimage
        anchors.fill: parent
        source: "pxfuel.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    // Clock Layer (just above the background)
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 100
        text: Qt.formatTime(new Date(), "hh:mm")
        font.pixelSize: 1100
        font.family: "Ostrich Sans"
        renderType: Text.NativeRendering
        color: "#FFFFFF"
        opacity: 0.2
        y: 300
    }


    Rectangle {
        anchors.fill: parent
        color: "#00000040"

        // ---- Username and Session Section at Top Right ----
        Column {
            id: userSessionSection
            spacing: 20
            width: Math.min(parent.width * 0.6, 300)
            anchors.top: parent.top
            anchors.topMargin: 60
            anchors.right: parent.right
            anchors.rightMargin: 10

            Column {
                spacing: 6

                Text {
                    id: lblName
                    text: textConstants.userName
                    font.bold: true
                    font.pixelSize: 14
                    color: "white"
                }

                TextBox {
                    id: name
                    width: 250
                    height: 34
                    text: userModel.lastUser
                    font.pixelSize: 14
                    KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password
                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(name.text, password.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            Column {
                spacing: 12
                width: parent.width

                Column {
                    z: 100
                    width: 250
                    spacing : 4
                    // anchors.top: parent.bottom

                    Text {
                        id: lblSession
                        width: parent.width
                        text: textConstants.session
                        wrapMode: TextEdit.WordWrap
                        font.bold: true
                        font.pixelSize: 12
                        color: "white"
                    }

                    ComboBox {
                        id: session
                        width: parent.width; height: 30
                        font.pixelSize: 14

                        arrowIcon: "angle-down.png"

                        model: sessionModel
                        index: sessionModel.lastIndex

                        KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                    }
                }

                // Column {
                //     spacing: 4
                //     width: parent.width * 0.5
                //
                //     Text {
                //         id: lblLayout
                //         text: textConstants.layout
                //         font.bold: true
                //         font.pixelSize: 12
                //         color: "white"
                //     }
                //
                //     LayoutBox {
                //         id: layoutBox
                //         width: 250
                //         height: 30
                //         font.pixelSize: 14
                //         arrowIcon: "angle-down.png"
                //         KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                //     }
                // }
            }
        }


        // ---- Password Section Centered ----
        Column {
            id: passwordSection
            spacing: 6
            width: 1800
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Text {
                id: lblPassword
                text: textConstants.password
                font.bold: true
                font.pixelSize: 14
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Rectangle {
                id: passwordBoxBg
                width: 1800
                height: 450
                radius: 6
                color: "transparent"
                border.color: "transparent"
                border.width: 1

                Text {
                    id: placeholder
                    text: "Hello, " + userModel.lastUser
                    anchors.centerIn: parent
                    font.pixelSize: 200
                    font.family: "URW Gothic"
                    font.weight: Font.Black
                    color: "#aaaaaa"
                    visible: passwordInput.text.length === 0
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 2
                    echoMode: TextInput.Password
                    font.pixelSize: 200
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "black"
                    cursorVisible: true
                    focus: true

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            sddm.login(name.text, passwordInput.text, sessionIndex)
                            event.accepted = true
                        }
                    }
                }
            }

            Text {
                id: errorMessage
                text: textConstants.prompt
                font.pixelSize: 11
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }



        // ---- Bottom Right Buttons ----
        Row {
            spacing: 10
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 20

            property int btnWidth: Math.max(loginButton.implicitWidth,
                                            shutdownButton.implicitWidth,
                                            rebootButton.implicitWidth, 80) + 8

                                            Button {
                                                id: loginButton
                                                text: textConstants.login
                                                width: parent.btnWidth
                                                onClicked: sddm.login(name.text, password.text, sessionIndex)
                                                KeyNavigation.backtab: layoutBox; KeyNavigation.tab: shutdownButton
                                            }

                                            Button {
                                                id: shutdownButton
                                                text: textConstants.shutdown
                                                width: parent.btnWidth
                                                onClicked: sddm.powerOff()
                                                KeyNavigation.backtab: loginButton; KeyNavigation.tab: rebootButton
                                            }

                                            Button {
                                                id: rebootButton
                                                text: textConstants.reboot
                                                width: parent.btnWidth
                                                onClicked: sddm.reboot()
                                                KeyNavigation.backtab: shutdownButton; KeyNavigation.tab: name
                                            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
            else
                password.focus = true
    }
}
