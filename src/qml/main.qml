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
                loader.sourceComponent = fileDialog;
                loader.item.open();
            }
        },

        Action {
            text: qsTr("Downloads")
            onTriggered: {
                loader.sourceComponent = downloadsDialog;
                loader.item.open();
            }
        },

        Action {
            text: qsTr("Settings")
            onTriggered: {
                loader.sourceComponent = settingsDialog;
                loader.item.open();
            }
        },

        Action {
            text: qsTr("About")
            onTriggered: {
                loader.sourceComponent = aboutDialog;
                loader.item.open();
            }
        }
    ]

    actions: Action {
        shortcut: "Ctrl+O"
        onTriggered: {
            loader.sourceComponent = fileDialog;
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
        horizontalScrollMode: ListView.ScrollPerItem
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: bookmarks
        delegate: BookmarkDelegate {}
        actions: [
            Action {
                text: qsTr("Edit")
                onTriggered: {
                    loader.sourceComponent = bookmarkDialog;
                    loader.item.name = bookmarks.data(view.currentIndex, BookmarksModel.TitleRole);
                    loader.item.address = bookmarks.data(view.currentIndex, BookmarksModel.UrlRole);
                    loader.item.open();
                }
            },

            Action {
                text: qsTr("Delete")
                onTriggered: {
                    loader.sourceComponent = deleteDialog;
                    loader.item.open();
                }
            }
        ]

        onActivated: window.loadBrowserWindow(bookmarks.data(view.currentIndex, BookmarksModel.UrlRole))
    }

    Label {
        anchors {
            fill: parent
            margins: platformStyle.paddingMedium
        }
        alignment: Qt.AlignCenter
        color: platformStyle.disabledTextColor
        text: qsTr("(No bookmarks)")
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
            onComboboxTriggered: viewLoader.sourceComponent = (viewLoader.item ? undefined : historyView)
            onTextEdited: {
                if (text) {
                    viewLoader.sourceComponent = searchView;
                    viewLoader.item.query = text;
                }
                else {
                    viewLoader.sourceComponent = undefined;
                }
            }
            onFocusChanged: if ((!focus) && ((viewLoader.item) && (!viewLoader.item.focus))) viewLoader.sourceComponent = undefined;
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
    
    Component {
        id: historyView
        
        HistoryView {}
    }
    
    Component {
        id: searchView
        
        SearchEngineView {}
    }
    
    Component {
        id: downloadsDialog
        
        DownloadsDialog {}
    }
    
    Component {
        id: settingsDialog
        
        SettingsDialog {}
    }
    
    Component {
        id: fileDialog
        
        OpenFileDialog {}
    }
    
    Component {
        id: bookmarkDialog
        
        EditBookmarkDialog {}
    }
    
    Component {
        id: deleteDialog
        
        ConfirmBookmarkDeleteDialog {}
    }
    
    Component {
        id: aboutDialog
        
        AboutDialog {}
    }

    Component.onCompleted: {
        screen.orientationLock = (qmlBrowserSettings.rotationEnabled ? Screen.AutoOrientation : Screen.LandscapeOrientation);

        if (webHistory.count == 0) {
            webHistory.storageFileName = "/home/user/.config/QMLBrowser/history";
            webHistory.load();
        }
    }
}
