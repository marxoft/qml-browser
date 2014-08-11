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
import org.hildon.utils 1.0
import "CreateObject.js" as ObjectCreator

Window {
    id: window

    property alias url: webView.url
    property alias html: webView.html
    property alias text: webView.text
    property alias history: webView.history
    property alias settings: webView.settings

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"), null);
        browser.fullScreen = qmlBrowserSettings.openBrowserWindowsInFullScreen;

        if (url) {
            browser.url = url;
        }
    }

    windowTitle: webView.title ? webView.title : "QML Browser"
    tools: [
        Action {
            text: qsTr("New window")
            onTriggered: window.loadBrowserWindow()
        },

        Action {
            text: qsTr("Reload")
            enabled: (webView.status == WebView.Ready) || (webView.status == WebView.Error)
            onTriggered: webView.reload()
        },

        Action {
            text: qsTr("Copy")
            enabled: (urlInput.hasSelectedText) || (webView.hasSelection)
            onTriggered: urlInput.hasSelectedText ? urlInput.copy() : webView.copy()
        },

        Action {
            text: qsTr("Paste")
            enabled: clipboard.hasText
            onTriggered: internal.menuFocusItem.paste()
        },

        Action {
            text: qsTr("Find on page")
            enabled: webView.status == WebView.Ready
            onTriggered: findToolBar.visible = true
        },

        Action {
            text: qsTr("View source")
            enabled: (webView.status == WebView.Ready) && (webView.html)
            onTriggered: pageStack.push(Qt.resolvedUrl("ViewSourcePage.qml"), { windowTitle: "view-source: " + webView.url, source: webView.html })
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
        }
    ]

    actions: [
        Action {
            shortcut: "Ctrl+O"
            onTriggered: {
                loader.source = Qt.resolvedUrl("OpenFileDialog.qml");
                loader.item.open();
            }
        },

        Action {
            shortcut: "Ctrl+N"
            onTriggered: window.loadBrowserWindow()
        },

        Action {
            shortcut: "Ctrl+R"
            enabled: (webView.status == WebView.Ready) || (webView.status == WebView.Error)
            onTriggered: webView.reload()
        },

        Action {
            shortcut: "Ctrl+F"
            enabled: webView.status == WebView.Ready
            onTriggered: findToolBar.visible = true
        },

        Action {
            shortcut: "Ctrl+D"
            onTriggered: {
                loader.source = Qt.resolvedUrl("NewBookmarkDialog.qml");
                loader.item.name = webView.title;
                loader.item.address = webView.url;
                loader.item.open();
            }
        },

        Action {
            shortcut: "Ctrl+B"
            onTriggered: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {})
        },

        Action {
            shortcut: "Shift+Backspace"
            enabled: webView.focus
            onTriggered: webView.forward()
        }
    ]

    QtObject {
        id: internal

        property variant menuFocusItem: urlInput
    }

    WebView {
        id: webView

        property variant hitContent

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: findToolBar.visible ? findToolBar.top : toolBar.visible ? toolBar.top : parent.bottom
        }
        contextMenuPolicy: panningArea.panningOn ? Qt.NoContextMenu : Qt.ActionsContextMenu
        interactive: !panningArea.pointerOn
        textSelectionEnabled: panningArea.panningOn
        userAgent: qmlBrowserSettings.userAgentString
        settings {
            pluginsEnabled: true
            privateBrowsingEnabled: qmlBrowserSettings.privateBrowsingEnabled
            autoLoadImages: qmlBrowserSettings.autoLoadImages
            javascriptEnabled: qmlBrowserSettings.javaScriptEnabled
            zoomTextOnly: qmlBrowserSettings.zoomTextOnly
            defaultFontSize: qmlBrowserSettings.defaultFontSize
            defaultTextEncoding: qmlBrowserSettings.defaultTextEncoding
        }
        newWindowComponent: Qt.createComponent(Qt.resolvedUrl("BrowserWindow.qml"))
        forwardUnsupportedContent: true
        linkDelegationPolicy: WebView.DelegateAllLinks
        onLinkClicked: if ((!qmlBrowserSettings.useCustomURLHandlers) || (!launcher.launch(link))) url = link;
        onUrlChanged: {
            urlInput.text = url;
            urlInput.cursorPosition = 0;
            viewLoader.source = "";
        }
        onStatusChanged: if (status == WebView.Ready) screenshot.grab();
        onFocusChanged: if (focus) internal.menuFocusItem = webView;
        onDownloadRequested: {
            loader.source = Qt.resolvedUrl("SaveFileDialog.qml");
            loader.item.fileName = request.url.toString().substring(request.url.toString().lastIndexOf("/") + 1);
            loader.item.request = request;
            loader.item.open();
        }
        onUnsupportedContent: {
            loader.source = Qt.resolvedUrl("SaveFileDialog.qml");
            var fileName;

            if (content.headers["Content-disposition"]) {
                fileName = content.headers["Content-disposition"].toString().replace(/\"/g, "").split("filename=")[1];
            }
            else {
                fileName = content.url.toString().substring(content.url.toString().lastIndexOf("/") + 1);
            }

            loader.item.fileName = fileName;
            loader.item.request = content;
            loader.item.open();
        }

        actions: [
            Action {
                text: (webView.hitContent) && (launcher.canLaunch(webView.hitContent.linkUrl)) ? qsTr("Open link with") + " " + launcher.handler(webView.hitContent.linkUrl)
                                                                                               : qsTr("Open with") + " " + launcher.handler(webView.url)
                visible: (launcher.canLaunch(webView.url)) || ((webView.hitContent) && (launcher.canLaunch(webView.hitContent.linkUrl))) ? true : false
                onTriggered: launcher.canLaunch(webView.hitContent.linkUrl) ? launcher.launch(webView.hitContent.linkUrl)
                                                                            : launcher.launch(webView.url)
            },

            Action {
                text: (webView.hitContent) && (webView.hitContent.linkUrl.toString()) ? qsTr("Open link in new window") : qsTr("Open in new window")
                onTriggered: window.loadBrowserWindow(webView.hitContent.linkUrl.toString() ? webView.hitContent.linkUrl : webView.url)
            },

            Action {
                text: qsTr("Add bookmark")
                onTriggered: {
                    loader.source = Qt.resolvedUrl("NewBookmarkDialog.qml");
                    loader.item.name = webView.hitContent.linkText ? webView.hitContent.linkText : webView.title;
                    loader.item.address = webView.hitContent.linkUrl.toString() ? webView.hitContent.linkUrl : webView.url;
                    loader.item.open();
                }
            },

            Action {
                text: qsTr("Copy link address")
                visible: (webView.hitContent) && (webView.hitContent.linkUrl.toString()) ? true : false
                onTriggered: clipboard.text = webView.hitContent.linkUrl
            },

            Action {
                text: qsTr("Save link as")
                visible: (webView.hitContent) && (webView.hitContent.linkUrl.toString()) ? true : false
                onTriggered: {
                    loader.source = Qt.resolvedUrl("SaveFileDialog.qml");
                    loader.item.fileName = webView.hitContent.linkUrl.toString().substring(webView.hitContent.linkUrl.toString().lastIndexOf("/") + 1);
                    loader.item.request = { "url": webView.hitContent.linkUrl };
                    loader.item.open();
                }
            }
        ]

        Keys.onPressed: {
            switch (event.key) {
            case Qt.Key_Up:
                if (event.modifiers & Qt.ShiftModifier) {
                    webView.contentY = 0;
                }
                else {
                    webView.contentY = Math.max(0, webView.contentY - 20);
                }

                break;
            case Qt.Key_Down:
                if (event.modifiers & Qt.ShiftModifier) {
                    webView.contentY = 100000000;
                }
                else {
                    webView.contentY += 20;
                }

                break;
            case Qt.Key_Left:
                if (event.modifiers & Qt.ShiftModifier) {
                    webView.contentX = 0;
                }
                else {
                    webView.contentX = Math.max(0, webView.contentX - 20);
                }

                break;
            case Qt.Key_Right:
                if (event.modifiers & Qt.ShiftModifier) {
                    webView.contentX = 100000000;
                }
                else {
                    webView.contentX += 20;
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

        PanningArea {
            id: panningArea

            anchors.fill: parent
        }

        ZoomArea {
            anchors {
                fill: parent
                margins: 10
            }
            visible: !panningArea.pointerOn
            onZoomIn: webView.zoomFactor += 0.1
            onZoomOut: webView.zoomFactor -= 0.1
            onZoomAt: webView.zoomFactor = ((webView.zoomFactor < 1.0) || (webView.zoomFactor >= 2.0) ? 1.0 : Math.min(webView.zoomFactor + 1.0, 2.0))

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                onPressed: webView.hitContent = webView.hitTestContent(mouseX, mouseY)
                onReleased: webView.hitContent = undefined
            }
        }
    }

    PanningIndicator {
        id: panningIndicator

        visible: panningArea.pointerOn
        panningOn: panningArea.panningOn
        onClicked: panningArea.panningOn = !panningArea.panningOn
    }

    ToolBar {
        id: findToolBar

        anchors {
            left: parent.left
            right: parent.right
            bottom: toolBar.visible ? toolBar.top : parent.bottom
        }
        movable: false
        visible: false
        onVisibleChanged: if (visible) findInput.focus = true;

        Label {
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            text: qsTr("Find") + ": "
        }

        TextField {
            id: findInput

            onReturnPressed: if (!webView.findText(text)) infobox.showMessage(qsTr("No matches found"));
        }

        Action {
            icon: "general_close"
            onTriggered: {
                webView.findText("");
                findToolBar.visible = false;
            }
        }
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
        visible: (!window.fullScreen) || ((webView.status == WebView.Loading) && (qmlBrowserSettings.forceToolBarVisibleWhenLoading))

        Timer {
            id: historyTimer

            interval: 800
            onTriggered: pageStack.push(Qt.resolvedUrl("RecentHistoryPage.qml"), {})
        }

        ToolButton {
            icon: "general_back"
            onPressed: historyTimer.restart()
            onReleased: {
                if (historyTimer.running) {
                    webView.back();
                }

                historyTimer.stop();
            }
        }

        ToolButton {
            icon: "general_forward"
            onPressed: historyTimer.restart()
            onReleased: {
                if (historyTimer.running) {
                    webView.forward();
                }

                historyTimer.stop();
            }
        }

        UrlInputField {
            id: urlInput

            showProgressIndicator: webView.status == WebView.Loading
            progress: webView.progress
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
            onFocusChanged: {
                if (focus) {
                    internal.menuFocusItem = urlInput;
                }
                else if ((viewLoader.item) && (!viewLoader.item.focus)) {
                    viewLoader.source = "";
                }
            }
            onReturnPressed: webView.url = urlFromTextInput(text)

            Timer {
                interval: 50
                running: urlInput.focus
                onTriggered: urlInput.selectAll()
            }
        }

        Action {
            icon: "general_stop"
            visible: webView.status == WebView.Loading
            onTriggered: webView.stop()
        }

        Action {
            icon: "general_mybookmarks_folder"
            onTriggered: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {})
        }

        Action {
            icon: "general_fullsize"
            onTriggered: window.fullScreen = !window.fullScreen
        }
    }

    FullscreenIndicator {}

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

    ScreenShot {
        id: screenshot

        target: webView
        fileName: "/home/user/.config/QMLBrowser/.cache/" + Qt.md5(webView.url) + ".jpg"
        overwriteExistingFile: true
        smooth: true
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
            if (qmlBrowserSettings.zoomWithVolumeKeys) {
                volumeKeys.grab(window);
            }
        }
        else {
            volumeKeys.release(window);
        }
    }
}
