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
import org.hildon.webkit 1.0
import org.hildon.browser 1.0
import "CreateObject.js" as ObjectCreator

Window {
    id: window

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"));
        browser.fullScreen = qmlBrowserSettings.openBrowserWindowsInFullScreen;

        if (url) {
            browser.url = url;
        }
    }

    windowTitle: "QML Browser"
    tools: [
        Action {
            text: qsTr("Open file")
            onTriggered: {
                loader.source = Qt.resolvedUrl("OpenFileDialog.qml");
                loader.item.open();
            }
        },

        Action {
            text: qsTr("Downloads")
            onTriggered: {
                loader.source = Qt.resolvedUrl("DownloadsDialog.qml");
                loader.item.open();
            }
        },

        Action {
            text: qsTr("Settings")
            onTriggered: {
                loader.source = Qt.resolvedUrl("SettingsDialog.qml");
                loader.item.open();
            }
        },

        Action {
            text: qsTr("About")
            onTriggered: {
                loader.source = Qt.resolvedUrl("AboutDialog.qml");
                loader.item.open();
            }
        }
    ]

    actions: Action {
        shortcut: "Ctrl+O"
        onTriggered: {
            loader.source = Qt.resolvedUrl("OpenFileDialog.qml");
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
                    loader.source = Qt.resolvedUrl("ConfirmBookmarkDeleteDialog.qml");
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
        color: platformStyle.disabledTextColor
        text: qsTr("No bookmarks")
        visible: bookmarks.count === 0
    }

    ToolBar {
        id: toolBar

        height: 75
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        movable: false

        UrlInputField {
            id: urlInput

            comboboxEnabled: webHistory.count > 0
            onComboboxTriggered: viewLoader.source = (viewLoader.item ? "" : Qt.resolvedUrl("HistoryView.qml"))
            onTextEdited: {
                if (text) {
                    viewLoader.source = Qt.resolvedUrl("SearchEngineView.qml");
                    viewLoader.item.query = text;
                }
                else {
                    viewLoader.source = "";
                }
            }
            onFocusChanged: if ((!focus) && ((viewLoader.item) && (!viewLoader.item.focus))) viewLoader.source = "";
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
            color: platformStyle.reversedTextColor
        }
    }

    Loader {
        id: viewLoader
    }

    Loader {
        id: loader
    }

    onVisibleChanged: {
        // Temporary solution until the attached Component property is exposed
        if (visible) {
            screen.orientationLock = (qmlBrowserSettings.rotationEnabled ? Screen.AutoOrientation : Screen.LandscapeOrientation);

            if (webHistory.count == 0) {
                webHistory.storageFileName = "/home/user/.config/QMLBrowser/history";
                webHistory.load();
            }
        }
        else {
            webHistory.save();
        }
    }
}
