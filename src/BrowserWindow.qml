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

    windowTitle: webView.title ? webView.title : "Browser"
    tools: [
        Action {
            text: qsTr("New window")
            shortcut: "Ctrl+N"
            onTriggered: window.loadBrowserWindow()
        },

        Action {
            text: qsTr("Reload")
            shortcut: "Ctrl+R"
            enabled: webView.status == WebView.Ready
            onTriggered: webView.reload()
        }
    ]

    WebView {
        id: webView

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            bottom: toolBar.visible ? toolBar.top : parent.bottom
        }
        onUrlChanged: urlInput.text = url
        onStatusChanged: if (status == WebView.Ready) screenshot.grab();

        MouseArea {
            width: 5
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            onExited: if (mouseX <= 0) pageStack.push(Qt.resolvedUrl("RecentHistoryPage.qml"), {});
        }
    }

    ToolBar {
        id: toolBar

        height: 80
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        visible: (!window.fullScreen) || (webView.status == WebView.Loading)

        ToolButton {
            icon: "browser_history"
            onPressed: historyTimer.restart()
            onReleased: historyTimer.stop()
            onClicked: if (historyTimer.running) webView.back();

            Timer {
                id: historyTimer

                interval: 800
                onTriggered: pageStack.push(Qt.resolvedUrl("RecentHistoryPage.qml"), {})
            }
        }

        Action {
            icon: "general_add"
            shortcut: "Ctrl+D"
            onTriggered: {
                loader.source = Qt.resolvedUrl("NewBookmarkDialog.qml");
                loader.item.name = webView.title;
                loader.item.address = webView.url;
                loader.item.open();
            }
        }

        UrlInputField {
            id: urlInput            

            height: 80
            showProgressIndicator: webView.status == WebView.Loading
            progress: webView.progress
            onReturnPressed: webView.url = urlFromTextInput(text)
        }

        Action {
            icon: "general_stop"
            visible: webView.status == WebView.Loading
            onTriggered: webView.stop()
        }

        Action {
            icon: "general_mybookmarks_folder"
            shortcut: "Ctrl+B"
            onTriggered: pageStack.push(Qt.resolvedUrl("BookmarksPage.qml"), {})
        }

        Action {
            icon: "general_fullsize"
            onTriggered: window.fullScreen = true
        }
    }

    ToolButton {
        width: 70
        height: 70
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        icon: "general_fullsize"
        styleSheet: "background-color: transparent"
        visible: !toolBar.visible
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
        id: loader
    }
}
