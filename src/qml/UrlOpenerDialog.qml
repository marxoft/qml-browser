/*
 * Copyright (C) 2016 Stuart Howarth <showarth@marxoft.co.uk>
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

    property alias regExp: regexpField.text
    property alias command: commandField.text

    height: column.height + platformStyle.paddingMedium
    title: qsTr("URL handler")
    
    Column {
        id: column

        anchors {
            left: parent.left
            right: button.left
            rightMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        spacing: platformStyle.paddingMedium

        Label {
            width: parent.width
            text: qsTr("Regular expression")
        }

        TextField {
            id: regexpField
            
            width: parent.width
        }

        Label {
            width: parent.width
            text: qsTr("Command (%u for URL)")
        }

        TextField {
            id: commandField
            
            width: parent.width
        }
    }

    Button {
        id: button
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        style: DialogButtonStyle {}
        text: qsTr("Done")
        enabled: (regexpField.text != "") && (commandField.text != "")
        onClicked: root.accept()
    }
    
    Component.onCompleted: regexpField.forceActiveFocus()
}
