/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU Lesser General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for
 * more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

import org.hildon.components 1.0

Dialog {
    id: root

    property alias fileName: nameInput.text
    property string location
    property variant request

    height: window.inPortrait ? 250 : 150
    windowTitle: qsTr("Save file")
    content: Column {
        id: column

        anchors.fill: parent

        TextField {
            id: nameInput

            focus: true
        }

        ValueButton {
            id: locationButton

            text: qsTr("Location")
            valueText: root.location ? root.location : "N900"
            onClicked: locationDialog.open()
        }
    }

    buttons: Button {
        text: qsTr("Save")
        enabled: nameInput.text != ""
        onClicked: /[\/]/g.test(nameInput.text) ? infobox.showMessage("'/' " + qsTr("character not allowed")) : root.accept()
    }

    onAccepted: {
        downloads.addDownload(request.url, request.headers, (root.location ? root.location : "/home/user/MyDocs/") + nameInput.text);
        nameInput.clear();
        root.location = "";
        nameInput.focus = true;
    }
    onRejected: {
        nameInput.clear();
        root.location = "";
        nameInput.focus = true;
    }

    FolderDialog {
        id: locationDialog

        onSelected: root.location = (folder[folder.length - 1] == "/" ? folder : folder + "/")
    }
}
