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
import "CreateObject.js" as ObjectCreator

Page {
    id: page

    windowTitle: qsTr("Bookmarks")    

    ListView {
        id: view

        anchors.fill: parent
        contextMenuPolicy: Qt.ActionsContextMenu
        model: bookmarks
        iconSize: "150x64"
        actions: [
            Action {
                text: qsTr("Edit")
                onTriggered: {
                    loader.source = Qt.resolvedUrl("EditBookmarkDialog.qml");
                    loader.item.name = bookmarks.data(view.currentIndex, BookmarksModel.TitleRole);
                    loader.item.address = bookmarks.data(view.currentIndex, BookmarksModel.UrlRole);
                    loader.item.open();
                }
            },

            Action {
                text: qsTr("Delete")
                onTriggered: {
                    loader.source = Qt.resolvedUrl("ConfirmBookmarkDeleteDialog.qml");
                    loader.item.open();
                }
            }
        ]

        onClicked: {
            window.url = bookmarks.data(view.currentIndex, BookmarksModel.UrlRole);
            pageStack.pop(window);
        }
    }

    Label {
        anchors {
            fill: parent
            margins: 10
        }
        alignment: Qt.AlignCenter
        font {
            bold: true
            pixelSize: 40
        }
        color: platformStyle.disabledTextColor
        text: qsTr("No bookmarks")
        visible: bookmarks.count === 0
    }

    Loader {
        id: loader
    }
}
