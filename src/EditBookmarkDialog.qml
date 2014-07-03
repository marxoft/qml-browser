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
import org.hildon.browser 1.0

Dialog {
    id: root

    property alias name: nameInput.text
    property alias address: addressInput.text

    height: window.inPortrait ? 260 : 160
    windowTitle: qsTr("Edit bookmark")
    content: Grid {
        id: grid

        anchors.fill: parent
        columns: 2

        Label {
            text: qsTr("Name")
            height: nameInput.height
            alignment: Qt.AlignVCenter
        }

        TextField {
            id: nameInput

            width: parent.width - 100
            focus: true
        }

        Label {
            text: qsTr("Address")
            height: addressInput.height
            alignment: Qt.AlignVCenter
        }

        TextField {
            id: addressInput

            width: parent.width - 100
        }
    }

    buttons: Button {
        text: qsTr("Save")
        enabled: (nameInput.text != "") && (addressInput.text != "")
        onClicked: root.accept()
    }

    onAccepted: {
        if ((!bookmarks.setData(view.currentIndex, name, BookmarksModel.TitleRole)) || (!bookmarks.setData(view.currentIndex, address, BookmarksModel.UrlRole))) {
            infobox.showMessage(qsTr("Cannot edit bookmark"));
        }
    }    
}
