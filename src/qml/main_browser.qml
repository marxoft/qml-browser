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
import org.hildon.utils 1.0
import "CreateObject.js" as ObjectCreator

ApplicationWindow {
    id: window

    property alias url: webView.url
    property alias html: webView.html
    property alias text: webView.text
    property alias history: webView.history
    property alias settings: webView.settings

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"), null);
        
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
    title: webView.title ? webView.title : "QML Browser"
    menuBar: MenuBar {
        MenuItem {
            text: qsTr("New window")
            onTriggered: window.loadBrowserWindow()
        }

        MenuItem {
            text: qsTr("Reload")
            enabled: (webView.status == WebView.Ready) || (webView.status == WebView.Error)
            onTriggered: webView.reload()
        }
        
        MenuItem {
            text: qsTr("Copy")
            enabled: (urlInput.hasSelectedText) || (webView.hasSelection)
            onTriggered: urlInput.hasSelectedText ? urlInput.copy() : webView.copy()
        }

        MenuItem {
            text: qsTr("Paste")
            enabled: clipboard.hasText
            onTriggered: urlInput.focus ? urlInput.paste() : webView.paste()
        }

        MenuItem {
            text: qsTr("Find on page")
            enabled: webView.status == WebView.Ready
            onTriggered: findToolBar.visible = true
        }

        MenuItem {
            text: qsTr("View source")
            enabled: (webView.status == WebView.Ready) && (webView.html)
            onTriggered: windowStack.push(Qt.resolvedUrl("ViewSourceWindow.qml"), {title: "view-source: " + webView.url,
                                                                                   source: webView.html})
        }

        MenuItem {
            text: qsTr("Downloads")
            onTriggered: dialogs.showDownloadsDialog()
        }

        MenuItem {
            text: qsTr("Settings")
            onTriggered: dialogs.showSettingsDialog()
        }
    }

    Flickable {
        id: flicker
        
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: findToolBar.visible ? findToolBar.top : toolBar.visible ? toolBar.top : parent.bottom
        }
        contentWidth: webView.width
        contentHeight: webView.height
        pressDelay: 100000
        
        WebView {
            id: webView

            function openUrl(u) {
                if ((!qmlBrowserSettings.useCustomURLHandlers) || (!launcher.launch(u))) {
                    url = u;
                }
            }

            preferredWidth: flicker.width
            userAgent: qmlBrowserSettings.userAgentString
            settings {
                pluginsEnabled: true
                privateBrowsingEnabled: qmlBrowserSettings.privateBrowsingEnabled
                autoLoadImages: qmlBrowserSettings.autoLoadImages
                javascriptEnabled: qmlBrowserSettings.javaScriptEnabled
                zoomTextOnly: qmlBrowserSettings.zoomTextOnly
                defaultFontSize: qmlBrowserSettings.defaultFontSize
            }
            newWindowComponent: Qt.createComponent(Qt.resolvedUrl("BrowserWindow.qml"))
            forwardUnsupportedContent: true
            linkDelegationPolicy: WebPage.DelegateAllLinks
            onUrlChanged: {
                urlInput.text = url;
                urlInput.cursorPosition = 0;
                viewLoader.sourceComponent = undefined;
            }
            onStatusChanged: {
                if (status == WebView.Ready) {
                    screenshot.grab();
                    bookmarks.urlVisited(url);
                }
            }
            onDownloadRequested: {
                var fileName = request.url.toString().substring(request.url.toString().lastIndexOf("/") + 1);
                dialogs.showSaveFileDialog(fileName, request);
            }
            onUnsupportedContent: {
                var fileName;

                if (content.headers["Content-disposition"]) {
                    fileName = content.headers["Content-disposition"].toString().replace(/\"/g, "").split("filename=")[1];
                }
                else {
                    fileName = content.url.toString().substring(content.url.toString().lastIndexOf("/") + 1);
                }

                dialogs.showSaveFileDialog(fileName, content);
            }
        }
        
        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Up:
                if (event.modifiers == Qt.ShiftModifier) {
                    contentY = 0;
                }
                else {
                    contentY = Math.max(0, contentY - 20);
                }

                break;
            case Qt.Key_Down:
                if (event.modifiers == Qt.ShiftModifier) {
                    contentY = contentHeight - height;
                }
                else {
                    contentY = Math.min(contentY + 20, contentHeight - height);
                }

                break;
            case Qt.Key_Left:
                if (event.modifiers == Qt.ShiftModifier) {
                    contentX = 0;
                }
                else {
                    contentX = Math.max(0, contentX - 20);
                }

                break;
            case Qt.Key_Right:
                if (event.modifiers == Qt.ShiftModifier) {
                    contentX = contentWidth - width;
                }
                else {
                    contentX = Math.min(contentX + 20, contentWidth - width);
                }

                break;
            case Qt.Key_Backspace:
                if (event.modifiers == Qt.ShiftModifier) {
                    webView.forward();
                }
                
                break;
            case Qt.Key_R:
                if (event.modifiers == Qt.ControlModifier) {
                    webView.reload();
                }
                
                break;
            case Qt.Key_F:
                if (event.modifiers == Qt.ControlModifier) {
                    findToolBar.visible = true;
                }
                
                break;
            case Qt.Key_N:
                if (event.modifiers == Qt.ControlModifier) {
                    window.loadBrowserWindow();
                }
                
                break;
            case Qt.Key_B:
                if (event.modifiers == Qt.ControlModifier) {
                    windowStack.push(Qt.resolvedUrl("BookmarksWindow.qml"));
                }
                
                break;
            case Qt.Key_O:
                if (event.modifiers == Qt.ControlModifier) {
                    dialogs.showFileDialog();
                }
                
                break;
            case Qt.Key_D:
                if (event.modifiers == Qt.ControlModifier) {
                    dialogs.showBookmarkDialog(webView.title, webView.url);
                }
                
                break;
            case Qt.Key_F8:
                webView.zoomFactor -= 0.1;
                break;
            case Qt.Key_F7:
                webView.zoomFactor += 0.1;
                break;
            default:
                return;
            }

            event.accepted = true;
        }
    }
    
    /*PanningArea {
        id: panningArea

        anchors.fill: parent
    }
    
    PanningIndicator {
        id: panningIndicator

        visible: panningArea.pointerOn
        panningOn: panningArea.panningOn
        onClicked: panningArea.panningOn = !panningArea.panningOn
    }*/
    
    ToolBar {
        id: findToolBar

        anchors.bottom: toolBar.visible ? toolBar.top : parent.bottom
        visible: false
        onVisibleChanged: if (visible) findInput.forceActiveFocus();

        Label {
            height: 70
            width: 70
            verticalAlignment: Text.AlignVCenter
            text: qsTr("Find") + ": "
        }

        TextField {
            id: findInput

            width: parent.width - 140
            onAccepted: if (!webView.findText(text)) informationBox.information(qsTr("No matches found"));
        }

        ToolButton {
            iconName: "general_close"
            onClicked: {
                webView.findText("");
                findToolBar.visible = false;
            }
        }
    }    

    ToolBar {
        id: toolBar

        height: 75
        anchors.bottom: parent.bottom
        visible: (!window.fullScreen) || ((webView.status == WebView.Loading)
                                          && (qmlBrowserSettings.forceToolBarVisibleWhenLoading))

        Timer {
            id: historyTimer

            interval: 800
            onTriggered: windowStack.push(Qt.resolvedUrl("RecentHistoryWindow.qml"))
        }

        ToolButton {
            width: 75
            height: 75
            iconName: "general_back"
            onPressedChanged: {
                if (pressed) {
                    historyTimer.restart();
                }
                else {
                    if (historyTimer.running) {
                        webView.back();
                    }

                    historyTimer.stop();
                }
            }
        }

        ToolButton {
            width: 75
            height: 75
            iconName: "general_forward"
            onPressedChanged: {
                if (pressed) {
                    historyTimer.restart();
                }
                else {
                    if (historyTimer.running) {
                        webView.forward();
                    }

                    historyTimer.stop();
                }
            }
        }

        UrlInputField {
            id: urlInput

            width: parent.width - (webView.status == WebView.Loading ? 375 : 300)
            showProgressIndicator: webView.status == WebView.Loading
            progress: webView.progress
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
            onFocusChanged: if ((!focus) && (viewLoader.item)
                                && (!viewLoader.item.focus)) viewLoader.sourceComponent = undefined;
            onAccepted: webView.url = urlFromTextInput(text)

            Timer {
                interval: 50
                running: urlInput.focus
                onTriggered: urlInput.selectAll()
            }
        }

        ToolButton {
            width: 75
            height: 75
            iconName: "general_stop"
            visible: webView.status == WebView.Loading
            onClicked: webView.stop()
        }

        ToolButton {
            width: 75
            height: 75
            iconName: "general_mybookmarks_folder"
            onClicked: windowStack.push(Qt.resolvedUrl("BookmarksWindow.qml"))
        }

        ToolButton {
            width: 75
            height: 75
            iconName: "general_fullsize"
            onClicked: window.fullScreen ? window.showNormal() : window.showFullScreen()
        }
    }

    FullscreenIndicator {}

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

    ScreenShot {
        id: screenshot

        //target: webView
        target: window
        targetHeight: Math.min(flicker.height, window.height * 0.6)
        fileName: "/home/user/.config/QMLBrowser/.cache/" + Qt.md5(webView.url) + ".jpg"
        overwriteExistingFile: true
        smooth: true
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
        property SaveFileDialog saveFileDialog
        property NewBookmarkDialog bookmarkDialog
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
        
        function showSaveFileDialog(fileName, request) {
            if (!saveFileDialog) {
                saveFileDialog = saveFileDialogComponent.createObject(window);
            }
            
            saveFileDialog.fileName = fileName;
            saveFileDialog.request = request;
            saveFileDialog.open();
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
            onAccepted: webView.url = "file://" + filePath
        }
    }
    
    Component {
        id: saveFileDialogComponent
        
        SaveFileDialog {}
    }
    
    Component {
        id: bookmarkDialogComponent
        
        NewBookmarkDialog {}
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

        if (qmlBrowserSettings.zoomWithVolumeKeys) {
            volumeKeys.grab(window);
        }

        if (webHistory.count == 0) {
            webHistory.storageFileName = "/home/user/.config/QMLBrowser/history";
            webHistory.load();
        }
        
        webView.linkClicked.connect(webView.openUrl);
    }
    
    Component.onDestruction: {
        volumeKeys.release(window);
        webHistory.save();
    }
}
