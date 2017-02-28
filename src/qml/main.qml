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
import org.hildon.webkit 1.0
import org.hildon.browser 1.0

ApplicationWindow {
    id: window

    function loadBrowserWindow(url) {
        var component = Qt.createComponent(Qt.resolvedUrl("BrowserWindow.qml"));
        var browser = component.createObject(null);
        
        if (qmlBrowserSettings.openBrowserWindowsInFullScreen) {
            browser.showFullScreen();
        }
        else {
            browser.show();
        }

        if (url) {
            browser.url = url;
        }
    }

    visible: true
    title: "QML Browser"
    menuBar: MenuBar {
        MenuItem {
            action: openAction
        }

        MenuItem {
            text: qsTr("Downloads")
            onTriggered: popupManager.open(Qt.resolvedUrl("DownloadsDialog.qml"), window)
        }

        MenuItem {
            text: qsTr("Settings")
            onTriggered: popupManager.open(Qt.resolvedUrl("SettingsDialog.qml"), window)
        }

        MenuItem {
            text: qsTr("About")
            onTriggered: popupManager.open(Qt.resolvedUrl("AboutDialog.qml"), window)
        }
    }
    
    Action {
        id: openAction
        
        text: qsTr("Open file")
        shortcut: "Ctrl+O"
        onTriggered: popupManager.open(fileDialog, window)
    }

    ListView {
        id: view

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: toolBar.top
        }
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: bookmarks
        delegate: BookmarkDelegate {
            onClicked: window.loadBrowserWindow(bookmarks.data(index, BookmarksModel.UrlRole))
            onPressAndHold: popupManager.open(contextMenu, window)
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

    ToolBar {
        id: toolBar

        height: 75
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        UrlInputField {
            id: urlInput

            width: toolBar.width
            onAccepted: {
                window.loadBrowserWindow(urlFromTextInput(text));
                clear();
            }            
        }
    }

    InformationBox {
        id: informationBox

        function information(message) {
            informationLabel.text = message;
            open();
        }
        
        height: informationLabel.height + platformStyle.paddingLarge

        Label {
            id: informationLabel

            anchors {
                left: parent.left
                leftMargin: platformStyle.paddingLarge
                right: parent.right
                rightMargin: platformStyle.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            color: platformStyle.reversedTextColor
        }
    }
    
    Component {
        id: contextMenu
        
        Menu {            
            MenuItem {
                text: qsTr("Edit")
                onTriggered: popupManager.open(Qt.resolvedUrl("EditBookmarkDialog.qml"), window,
                {name: bookmarks.data(view.currentIndex, BookmarksModel.TitleRole),
                 address: bookmarks.data(view.currentIndex, BookmarksModel.UrlRole)})
            }
            
            MenuItem {
                text: qsTr("Delete")
                onTriggered: bookmarks.removeBookmark(view.currentIndex)
            }
        }
    }
    
    Component {
        id: fileDialog
        
        FileDialog {
            onAccepted: window.loadBrowserWindow("file://" + filePath)
        }
    }

    Component.onCompleted: {
        screen.orientationLock = (qmlBrowserSettings.rotationEnabled ? Qt.WA_Maemo5AutoOrientation
                                                                     : Qt.WA_Maemo5LandscapeOrientation);

        if (webHistory.count == 0) {
            webHistory.storageFileName = HISTORY_PATH;
            webHistory.load();
        }
    }
}
