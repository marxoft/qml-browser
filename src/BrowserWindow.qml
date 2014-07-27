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
    property alias viewHistory: webView.history
    property alias viewSettings: webView.settings

    function loadBrowserWindow(url) {
        var browser = ObjectCreator.createObject(Qt.resolvedUrl("BrowserWindow.qml"), null);

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
            enabled: webView.status == WebView.Ready
            onTriggered: webView.reload()
        },

        Action {
            text: qsTr("Copy")
            enabled: (urlInput.selectedText) || (webView.selectedText)
            onTriggered: urlInput.selectedText ? urlInput.copy() : webView.copy()
        },

        Action {
            text: qsTr("Paste")
            enabled: clipboard.text != ""
            onTriggered: urlInput.focus ? urlInput.paste() : webView.paste()
        },

        Action {
            text: qsTr("Find on page")
            enabled: webView.status == WebView.Ready
            onTriggered: findToolBar.visible = true
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
            shortcut: "Ctrl+N"
            onTriggered: window.loadBrowserWindow()
        },

        Action {
            shortcut: "Ctrl+R"
            enabled: webView.status == WebView.Ready
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
        }
    ]

    WebView {
        id: webView

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: findToolBar.visible ? findToolBar.top : toolBar.visible ? toolBar.top : parent.bottom
        }
        interactive: !panningArea.pointerOn
        textSelectionEnabled: panningArea.panningOn
        settings.javascriptEnabled: qmlBrowserSettings.javaScriptEnabled
        newWindowComponent: Qt.createComponent(Qt.resolvedUrl("BrowserWindow.qml"))
        linkDelegationPolicy: WebView.DelegateAllLinks
        onLinkClicked: if ((!qmlBrowserSettings.useCustomURLHandlers) || (!launcher.launch(link))) url = link;
        onUrlChanged: {
            urlInput.text = url;
            urlInput.cursorPosition = 0;
            viewLoader.source = "";
        }
        onStatusChanged: if (status == WebView.Ready) screenshot.grab();

        PanningArea {
            id: panningArea

            anchors.fill: parent
        }

        ZoomArea {
            anchors {
                fill: parent
                margins: 10
            }
            enabled: !panningArea.pointerOn
            onZoomIn: webView.zoomFactor += 0.1
            onZoomOut: webView.zoomFactor -= 0.1
            onZoomAt: webView.zoomFactor = ((webView.zoomFactor < 1.0) || (webView.zoomFactor >= 2.0) ? 1.0 : Math.min(webView.zoomFactor + 1.0, 2.0))
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

        Label {
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            text: qsTr("Find") + ": "
        }

        TextField {
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
        visible: (!window.fullScreen) || (webView.status == WebView.Loading)

        ToolButton {
            icon: "browser_history"
            onPressed: historyTimer.restart()
            onReleased: {
                if (historyTimer.running) {
                    webView.back();
                }

                historyTimer.stop();
            }

            Timer {
                id: historyTimer

                interval: 800
                onTriggered: pageStack.push(Qt.resolvedUrl("RecentHistoryPage.qml"), {})
            }
        }

        Action {
            icon: "general_add"
            onTriggered: {
                loader.source = Qt.resolvedUrl("NewBookmarkDialog.qml");
                loader.item.name = webView.title;
                loader.item.address = webView.url;
                loader.item.open();
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
            onFocusChanged: if ((!focus) && ((viewLoader.item) && (!viewLoader.item.focus))) viewLoader.source = "";
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
            onTriggered: window.fullScreen = true
        }
    }

    FullscreenIndicator {
        visible: (!toolBar.visible) && ((webView.moving) || (webView.status != WebView.Ready))
        onClicked: window.fullScreen = false
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
}
