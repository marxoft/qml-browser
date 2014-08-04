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
    property alias regExp: regexpInput.text
    property alias command: commandInput.text

    height: window.inPortrait ? 440 : 340
    windowTitle: qsTr("Add custom URL handler")
    content: Column {
        id: column

        anchors.fill: parent

        Label {
            text: qsTr("Name")
        }

        TextField {
            id: nameInput

            focus: true
        }

        Label {
            text: qsTr("Regular expression")
        }

        TextField {
            id: regexpInput
        }

        Label {
            text: qsTr("Command") + " (" + qsTr("replace URL with") + " '%URL%')"
        }

        TextField {
            id: commandInput
        }
    }

    buttons: Button {
        text: qsTr("Save")
        enabled: (nameInput.text != "") && (regexpInput.text != "") && (commandInput.text != "")
        onClicked: root.accept()
    }

    onAccepted: {
        if (launcher.addHandler(nameInput.text, regexpInput.text, commandInput.text)) {
            infobox.showMessage(qsTr("URL handler added"));
        }
        else {
            infobox.showMessage(qsTr("Cannot add URL handler"));
        }

        nameInput.clear();
        regexpInput.clear();
        commandInput.clear();
        nameInput.focus = true;
    }
    onRejected: {
        nameInput.clear();
        regexpInput.clear();
        commandInput.clear();
        nameInput.focus = true;
    }
}
