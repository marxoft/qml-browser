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

    property alias name: nameInput.text
    property alias address: addressInput.text
    property alias icon: iconSelector.iconPath

    height: window.inPortrait ? 420 : 320
    windowTitle: qsTr("Add search engine")
    content: Column {
        id: column

        anchors.fill: parent

        Label {
            text: qsTr("Name")
        }

        TextField {
            id: nameInput
        }

        Label {
            text: qsTr("Address") + " (" + qsTr("replace query string with") + " '%QUERY%')"
        }

        TextField {
            id: addressInput
        }

        ValueButton {
            id: iconSelector

            property string iconPath

            text: qsTr("Icon path (optional)")
            valueText: iconPath ? iconPath : qsTr("None chosen")
            onClicked: fileDialog.open()
        }
    }

    buttons: Button {
        text: qsTr("Save")
        enabled: (nameInput.text != "") && (addressInput.text != "")
        onClicked: root.accept()
    }

    onAccepted: {
        searchEngines.addSearchEngine(nameInput.text, iconSelector.iconPath, addressInput.text);
        infobox.showMessage(qsTr("Search engine added"));
        nameInput.clear();
        addressInput.clear();
        iconSelector.iconPath = "";
    }
    onRejected: {
        nameInput.clear();
        addressInput.clear();
        iconSelector.iconPath = "";
    }

    FileDialog {
        id: fileDialog

        onSelected: iconSelector.iconPath = filePath
    }
}
