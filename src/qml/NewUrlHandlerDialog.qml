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

Dialog {
    id: root

    property alias name: nameInput.text
    property alias regExp: regexpInput.text
    property alias command: commandInput.text

    height: column.height + platformStyle.paddingMedium
    title: qsTr("Add custom URL handler")
    
    Column {
        id: column

        anchors {
            left: parent.left
            right: acceptButton.left
            rightMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        spacing: platformStyle.paddingMedium

        Label {
            width: parent.width
            text: qsTr("Name")
        }

        TextField {
            id: nameInput
            
            width: parent.width
        }

        Label {
            width: parent.width
            text: qsTr("Regular expression")
        }

        TextField {
            id: regexpInput
            
            width: parent.width
        }

        Label {
            width: parent.width
            text: qsTr("Command") + " (" + qsTr("replace URL with") + " '%URL%')"
        }

        TextField {
            id: commandInput
            
            width: parent.width
        }
    }
    
    Button {
        id: acceptButton
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: qsTr("Save")
        enabled: (nameInput.text != "") && (regexpInput.text != "") && (commandInput.text != "")
        onClicked: root.accept()
    }
    
    StateGroup {
        states: State {
            name: "Portrait"
            when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation
            
            PropertyChanges {
                target: root
                height: column.height + acceptButton.height + platformStyle.paddingMedium
            }
        
            AnchorChanges {
                target: column
                anchors {
                    right: parent.right
                    bottom: button.top
                }
            }
        
            PropertyChanges {
                target: column
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
        if (launcher.addHandler(nameInput.text, regexpInput.text, commandInput.text)) {
            informationBox.information(qsTr("URL handler added"));
        }
        else {
            informationBox.information(qsTr("Cannot add URL handler"));
        }
        
        nameInput.clear();
        regexpInput.clear();
        commandInput.clear();
    }
    onRejected: {
        nameInput.clear();
        regexpInput.clear();
        commandInput.clear();
    }
}
