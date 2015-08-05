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
import "CreateObject.js" as ObjectCreator

ApplicationWindow {
    id: window

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"));
        
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
            text: qsTr("Open file")
            onTriggered: dialogs.showFileDialog()
        }

        MenuItem {
            text: qsTr("Downloads")
            onTriggered: dialogs.showDownloadsDialog()
        }

        MenuItem {
            text: qsTr("Settings")
            onTriggered: dialogs.showSettingsDialog()
        }

        MenuItem {
            text: qsTr("About")
            onTriggered: dialogs.showAboutDialog()
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
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: bookmarks
        delegate: BookmarkDelegate {
            onClicked: window.loadBrowserWindow(bookmarks.data(index, BookmarksModel.UrlRole))
            onPressAndHold: contextMenu.popup()
        }
        
        Keys.onPressed: {
            if ((event.key == Qt.Key_O) && (event.modifiers == Qt.ControlModifier)) {
                dialogs.showFileDialog();
                event.accepted = true;
            }
        }
    }
    
    Menu {
        id: contextMenu
        
        MenuItem {
            text: qsTr("Edit")
            onTriggered: dialogs.showBookmarkDialog(bookmarks.data(view.currentIndex, BookmarksModel.TitleRole),
                                                    bookmarks.data(view.currentIndex, BookmarksModel.UrlRole))
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

    ToolBar {
        id: toolBar

        height: 75
        anchors.bottom: parent.bottom

        UrlInputField {
            id: urlInput

            width: parent.width
            comboboxEnabled: webHistory.count > 0
            onComboboxTriggered: viewLoader.sourceComponent = (viewLoader.item ? undefined : historyView)
            onTextChanged: {
                if (text) {
                    viewLoader.sourceComponent = searchView;
                    viewLoader.item.query = text;
                }
                else {
                    viewLoader.sourceComponent = undefined;
                }
            }
            onFocusChanged: if ((!focus) && ((viewLoader.item) && (!viewLoader.item.focus))) viewLoader.sourceComponent = undefined;
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

    Loader {
        id: viewLoader
        
        anchors {
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            right: parent.right
            rightMargin: platformStyle.paddingMedium
            bottom: toolBar.top
        }
        height: item ? Math.min(item.count * 70, 280) : 0
    }
    
    QtObject {
        id: dialogs
        
        property DownloadsDialog downloadsDialog
        property SettingsDialog settingsDialog
        property FileDialog fileDialog
        property EditBookmarkDialog bookmarkDialog
        property NewSearchEngineDialog searchEngineDialog
        property AboutDialog aboutDialog
        
        function showDownloadsDialog() {
            if (!downloadsDialog) {
                downloadsDialog = downloadsDialogComponent.createObject(window)
            }
            
            downloadsDialog.open();
        }
        
        function showSettingsDialog() {
            if (!settingsDialog) {
                settingsDialog = settingsDialogComponent.createObject(window);
            }
            
            settingsDialog.open();
        }
        
        function showFileDialog() {
            if (!fileDialog) {
                fileDialog = fileDialogComponent.createObject(window);
            }
            
            fileDialog.open();
        }
        
        function showBookmarkDialog(name, address) {
            if (!bookmarkDialog) {
                bookmarkDialog = bookmarkDialogComponent.createObject(window);
            }
            
            bookmarkDialog.name = name;
            bookmarkDialog.address = address;
            bookmarkDialog.open();
        }
        
        function showSearchEngineDialog() {
            if (!searchEngineDialog) {
                searchEngineDialog = searchEngineDialogComponent.createObject(window);
            }
            
            searchEngineDialog.open();
        }
        
        function showAboutDialog() {
            if (!aboutDialog) {
                aboutDialog = aboutDialogComponent.createObject(window);
            }
            
            aboutDialog.open();
        }
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
        id: downloadsDialogComponent
        
        DownloadsDialog {}
    }
    
    Component {
        id: settingsDialogComponent
        
        SettingsDialog {}
    }
    
    Component {
        id: fileDialogComponent
        
        FileDialog {
            onAccepted: window.loadBrowserWindow("file://" + filePath)
        }
    }
    
    Component {
        id: bookmarkDialogComponent
        
        EditBookmarkDialog {}
    }
    
    Component {
        id: searchEngineDialogComponent
        
        NewSearchEngineDialog {}
    }
    
    Component {
        id: aboutDialogComponent
        
        AboutDialog {}
    }

    Component.onCompleted: {
        screen.orientationLock = (qmlBrowserSettings.rotationEnabled ? Qt.WA_Maemo5AutoOrientation
                                                                     : Qt.WA_Maemo5LandscapeOrientation);

        if (webHistory.count == 0) {
            webHistory.storageFileName = "/home/user/.config/QMLBrowser/history";
            webHistory.load();
        }
    }
}
