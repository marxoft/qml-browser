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

Window {
    id: window

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"), null);

        if (url) {
            browser.url = url;
        }
    }

    windowTitle: "Browser"
    tools: Action {
        text: qsTr("About")
        onTriggered: {
            loader.source = Qt.resolvedUrl("AboutDialog.qml");
            loader.item.open();
        }
    }

    ListView {
        id: view

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: toolBar.top
        }

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
                    loader.source = Qt.resolvedUrl("ConfirmDeleteDialog.qml");
                    loader.item.open();
                }
            }
        ]

        onClicked: window.loadBrowserWindow(bookmarks.data(view.currentIndex, BookmarksModel.UrlRole))
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
        color: platformStyle.secondaryTextColor
        text: qsTr("No bookmarks")
        visible: bookmarks.count === 0
    }

    ToolBar {
        id: toolBar

        height: 80
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        UrlInputField {
            id: urlInput

            height: 80
            onReturnPressed: {
                window.loadBrowserWindow(urlFromTextInput(text));
                clear();
            }
        }
    }

    InformationBox {
        id: infobox

        function showMessage(message) {
            label.text = message;
            open();
        }

        content: Label {
            id: label

            anchors.fill: parent
            alignment: Qt.AlignCenter
            color: platformStyle.notificationTextColor
        }
    }

    Loader {
        id: loader
    }
}