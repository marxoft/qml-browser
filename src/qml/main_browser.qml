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

ApplicationWindow {
    id: window

    property alias url: webView.url
    property alias html: webView.html
    property alias text: webView.text
    property alias history: webView.history
    property alias settings: webView.settings

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
    title: webView.title ? webView.title : "QML Browser"
    menuBar: MenuBar {
        MenuItem {
            action: newAction
        }

        MenuItem {
            action: reloadAction
        }

        MenuItem {
            action: findAction
        }

        MenuItem {
            text: qsTr("View source")
            enabled: (webView.status == WebView.Ready) && (webView.html)
            onTriggered: windowStack.push(Qt.resolvedUrl("ViewSourceWindow.qml"), {title: "view-source: " + webView.url,
                                                                                   source: webView.html})
        }

        MenuItem {
            text: qsTr("Downloads")
            onTriggered: popupManager.open(Qt.resolvedUrl("DownloadsDialog.qml"), window)
        }

        MenuItem {
            text: qsTr("Settings")
            onTriggered: popupManager.open(Qt.resolvedUrl("SettingsDialog.qml"), window)
        }
    }
    
    Action {
        id: newAction
        
        text: qsTr("New window")
        shortcut: qsTr("Ctrl+N")
        autoRepeat: false
        onTriggered: window.loadBrowserWindow()
    }
    
    Action {
        id: openAction
        
        text: qsTr("Open file")
        shortcut: qsTr("Ctrl+O")
        autoRepeat: false
        onTriggered: popupManager.open(fileDialog, window)
    }
    
    Action {
        id: reloadAction
        
        text: qsTr("Reload")
        shortcut: qsTr("Ctrl+R")
        autoRepeat: false
        enabled: (webView.status == WebView.Ready) || (webView.status == WebView.Error)
        onTriggered: webView.reload()
    }
    
    Action {
        id: findAction
        
        text: qsTr("Find on page")
        shortcut: qsTr("Ctrl+F")
        autoRepeat: false
        enabled: webView.status == WebView.Ready
        onTriggered: findLoader.sourceComponent = findToolBar
    }
    
    Action {
        id: bookmarksAction
        
        text: qsTr("Bookmarks")
        iconName: "general_mybookmarks_folder"
        shortcut: qsTr("Ctrl+B")
        autoRepeat: false
        onTriggered: windowStack.push(Qt.resolvedUrl("BookmarksWindow.qml"))
    }
    
    Action {
        id: bookmarkAction
        
        text: qsTr("Add bookmark")
        iconName: "general_add"
        shortcut: qsTr("Ctrl+D")
        autoRepeat: false
        onTriggered: popupManager.open(Qt.resolvedUrl("NewBookmarkDialog.qml"), window,
        {name: webView.title, address: webView.url});
    }
    
    Action {
        id: forwardAction
        
        text: qsTr("Go forward")
        iconName: "general_forward"
        shortcut: qsTr("Shift+Backspace")
        autoRepeat: false
        onTriggered: webView.forward()
    }
    
    Flickable {
        id: flickable
        
        anchors.fill: parent
        contentWidth: webView.width
        contentHeight: webView.height + (findLoader.item ? findLoader.item.height : 0)
        + (toolLoader.item ? toolLoader.item.height : 0) + (fullscreenLoader.item ? fullscreenLoader.item.height : 0)
        pressDelay: 1000
        
        WebView {
            id: webView

            preferredWidth: flickable.width
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
            linkDelegationPolicy: WebPage.DelegateAllLinks
            onLinkClicked: if ((!qmlBrowserSettings.useCustomURLHandlers) || (!urlopener.open(link))) url = link;
            onStatusChanged: if (status == WebView.Ready) bookmarks.urlVisited(url);
            onDownloadRequested: popupManager.open(Qt.resolvedUrl("SaveFileDialog.qml"), window, {request: request})
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
    
    Loader {
        id: findLoader
        
        anchors {
            left: parent.left
            right: parent.right
            bottom: toolLoader.top
        }
    }
    
    Loader {
        id: toolLoader
        
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        sourceComponent: (!window.fullScreen) || ((webView.status == WebView.Loading)
        && (qmlBrowserSettings.forceToolBarVisibleWhenLoading)) ? toolBar : undefined
    }
    
    Loader {
        id: fullscreenLoader
        
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: -10
        }
        sourceComponent: toolLoader.item ? undefined : fullscreenIndicator
    }
    
    Component {
        id: findToolBar
        
        ToolBar {
            id: bar
                        
            Label {
                height: 70
                width: 70
                verticalAlignment: Text.AlignVCenter
                text: qsTr("Find") + ": "
            }
            
            TextField {
                id: findInput
                
                width: bar.width - 140
                onAccepted: if (!webView.findText(text)) informationBox.information(qsTr("No matches found"));
            }
            
            ToolButton {
                iconName: "general_close"
                onClicked: {
                    webView.findText("");
                    findLoader.sourceComponent = undefined;
                }
            }
            
            Component.onCompleted: findInput.forceActiveFocus()
        }
    }
    
    Component {
        id: toolBar
        
        ToolBar {
            id: bar
            
            height: 75
            
            Timer {
                id: historyTimer
                
                interval: 800
                onTriggered: windowStack.push(Qt.resolvedUrl("HistoryWindow.qml"))
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
                
                width: bar.width - (webView.status == WebView.Loading ? 375 : 300)
                showProgressIndicator: webView.status == WebView.Loading
                progress: webView.progress
                onAccepted: webView.url = urlFromTextInput(text)
                
                Timer {
                    interval: 50
                    running: urlInput.focus
                    onTriggered: urlInput.selectAll()
                }
                
                Connections {
                    target: webView
                    onUrlChanged: {
                        urlInput.text = webView.url;
                        urlInput.cursorPosition = 0;
                    }
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
                action: bookmarksAction
            }
            
            ToolButton {
                width: 75
                height: 75
                iconName: "general_fullsize"
                onClicked: window.fullScreen ? window.showNormal() : window.showFullScreen()
            }            
            
            Component.onCompleted: {
                urlInput.text = webView.url;
                urlInput.cursorPosition = 0;
            }
        }
    }
    
    Component {
        id: fullscreenIndicator
        
        FullscreenIndicator {}
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
        id: fileDialogComponent
        
        FileDialog {
            onAccepted: webView.url = "file://" + filePath
        }
    }
    
    Component.onCompleted: {
        screen.orientationLock = (qmlBrowserSettings.rotationEnabled ? Qt.WA_Maemo5AutoOrientation
                                                                     : Qt.WA_Maemo5LandscapeOrientation);

        if (qmlBrowserSettings.zoomWithVolumeKeys) {
            volumeKeys.grab(window);
        }

        if (webHistory.count == 0) {
            webHistory.storageFileName = HISTORY_PATH;
            webHistory.load();
        }
    }
    
    Component.onDestruction: {
        volumeKeys.release(window);
        webHistory.save();
    }
}
