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
import org.hildon.browser 1.0

Window {
    id: root

    title: qsTr("Bookmarks")

    ListView {
        id: view

        anchors.fill: parent
        focus: true
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: bookmarks
        delegate: BookmarkDelegate {
            onClicked: {
                window.url = bookmarks.data(view.currentIndex, BookmarksModel.UrlRole);
                windowStack.pop(window);
            }
            onPressAndHold: contextMenu.popup()
        }
    }
    
    Menu {
        id: contextMenu
        
        MenuItem {
            text: qsTr("Edit")
            onTriggered: dialogs.showEditDialog()
        }

        MenuItem {
            text: qsTr("Delete")
            onTriggered: bookmarks.removeBookmark(view.currentIndex)
        }
    }

    Label {
        anchors {
            fill: parent
            margins: platformStyle.paddingMedium
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: platformStyle.disabledTextColor
        text: qsTr("(No bookmarks)")
        visible: bookmarks.count === 0
    }

    QtObject {
        id: dialogs
        
        property EditBookmarkDialog editDialog
        
        function showEditDialog() {
            if (!editDialog) {
                editDialog = editDialogComponent.createObject(root);
            }
            
            editDialog.name = bookmarks.data(view.currentIndex, BookmarksModel.TitleRole);
            editDialog.address = bookmarks.data(view.currentIndex, BookmarksModel.UrlRole);
            editDialog.open();
        }
    }
    
    Component {
        id: editDialogComponent
        
        EditBookmarkDialog {}
    }
}
