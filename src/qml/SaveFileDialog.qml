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

    property string location
    property variant request

    height: column.height + platformStyle.paddingMedium
    title: qsTr("Save file")
    
    Column {
        id: column

        anchors {
            left: parent.left
            right: acceptButton.left
            rightMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        spacing: platformStyle.paddingMedium

        TextField {
            id: nameInput
            
            width: parent.width
        }

        ValueButton {
            id: locationButton
            
            width: parent.width
            text: qsTr("Location")
            valueText: root.location ? root.location : "N900"
            onClicked: popupManager.open(fileDialog, root)
        }
    }
    
    Button {
        id: acceptButton
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        style: DialogButtonStyle {}
        text: qsTr("Save")
        enabled: nameInput.text != ""
        onClicked: /[\/]/g.test(nameInput.text) ? informationBox.information("'/' " + qsTr("character not allowed"))
                                                : root.accept()
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
    
    Component {
        id: fileDialog
        
        FileDialog {            
            selectFolder: true
            onAccepted: root.location = (folder[folder.length - 1] == "/" ? folder : folder + "/")
        }
    }
    
    onRequestChanged: {
        if (request) {
            try {
                var header = request.rawHeader("Content-Disposition");
                nameInput.text = /(filename=|filename\*=UTF-8''|filename\*= UTF-8'')([^;]+)/.exec(header)[2];
            }
            catch(e) {
                var url = request.url.toString();
                nameInput.text = url.substring(url.lastIndexOf("/") + 1);
            }
        }
    }
                
    onAccepted: downloads.addDownload(request, (root.location ? root.location : "/home/user/MyDocs/") + nameInput.text)
    
    Component.onCompleted: nameInput.forceActiveFocus()
}
