/*
 * Copyright (C) 2015 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 1.0
import org.hildon.components 1.0
import org.hildon.utils 1.0

Dialog {
    id: root

    property alias name: nameInput.text
    property alias address: addressInput.text

    height: grid.height + platformStyle.paddingMedium
    title: qsTr("Add bookmark")
    
    Grid {
        id: grid

        anchors {
            left: parent.left
            right: acceptButton.left
            rightMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        columns: 2
        spacing: platformStyle.paddingMedium

        Label {
            width: 100
            text: qsTr("Name")
            height: nameInput.height
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: nameInput

            width: parent.width - 100 - parent.spacing
        }

        Label {
            width: 100
            text: qsTr("Address")
            height: addressInput.height
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: addressInput

            width: parent.width - 100 - parent.spacing
        }
    }

    Button {
        id: acceptButton
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: qsTr("Save")
        enabled: (nameInput.text != "") && (addressInput.text != "")
        onClicked: root.accept()
    }
    
    StateGroup {
        states: State {
            name: "Portrait"
            when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation
            
            PropertyChanges {
                target: root
                height: grid.height + acceptButton.height + platformStyle.paddingMedium
            }
        
            AnchorChanges {
                target: grid
                anchors {
                    right: parent.right
                    bottom: button.top
                }
            }
        
            PropertyChanges {
                target: grid
                anchors {
                    rightMargin: 0
                    bottomMargin: platformStyle.paddingMedium
                }
            }
        
            PropertyChanges {
                target: acceptButton
                width: parent.width
            }
        }
    }

    onStatusChanged: if (status == DialogStatus.Open) nameInput.forceActiveFocus();
    onAccepted: {
        if (bookmarks.addBookmark(nameInput.text, screenshot.fileName, addressInput.text,
            webView.url.toString() == addressInput.text)) {
            screenshot.grab();
            informationBox.information(qsTr("Bookmark added"));
        }
        else {
            informationBox.information(qsTr("Cannot add bookmark"));
        }
        
        nameInput.clear();
        addressInput.clear();
    }
    onRejected: {
        nameInput.clear();
        addressInput.clear();
    }

    ScreenShot {
        id: screenshot

        width: 160
        height: 96
        //target: webView
        target: window
        targetHeight: Math.min(flicker.height, window.height * 0.6)
        fileName: "/home/user/.config/QMLBrowser/bookmarks/" + Qt.md5(webView.url) + ".jpg"
        overwriteExistingFile: true
        smooth: true
    }
}
