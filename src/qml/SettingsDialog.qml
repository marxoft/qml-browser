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

Dialog {
    id: root

    height: window.inPortrait ? 680 : 360
    windowTitle: qsTr("Settings")
    content: Flickable {
        id: flicker

        anchors.fill: parent

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }

            Label {
                text: qsTr("General")
            }

            CheckBox {
                id: rotationCheckbox

                text: qsTr("Enable rotation")
                checked: qmlBrowserSettings.rotationEnabled
            }

            CheckBox {
                id: volumeKeysCheckbox

                text: qsTr("Use volume keys to zoom")
                checked: qmlBrowserSettings.zoomWithVolumeKeys
            }

            CheckBox {
                id: fullScreenCheckbox

                text: qsTr("Open browser windows in fullscreen")
                checked: qmlBrowserSettings.openBrowserWindowsInFullScreen
            }

            CheckBox {
                id: forceToolbarCheckbox

                text: qsTr("ToolBar always visible when loading")
                checked: qmlBrowserSettings.forceToolBarVisibleWhenLoading
            }

            CheckBox {
                id: handlersCheckbox

                text: qsTr("Use custom URL handlers")
                checked: qmlBrowserSettings.useCustomURLHandlers
            }

            Button {
                text: qsTr("Add custom URL handler")
                onClicked: {
                    loader.sourceComponent = handlerDialog;
                    loader.item.open();
                }
            }

            Label {
                text: qsTr("Content")
            }

            Button {
                text: qsTr("Clear browsing history")
                enabled: webHistory.count > 0
                onClicked: {
                    webHistory.clear();
                    webHistory.save();
                }
            }

            CheckBox {
                id: privateCheckbox

                text: qsTr("Enable private browsing")
                checked: qmlBrowserSettings.privateBrowsingEnabled
            }

            CheckBox {
                id: imagesCheckbox

                text: qsTr("Load images automatically")
                checked: qmlBrowserSettings.autoLoadImages
            }

            CheckBox {
                id: jsCheckbox

                text: qsTr("Enable JavaScript")
                checked: qmlBrowserSettings.javaScriptEnabled
            }

            CheckBox {
                id: zoomTextCheckbox

                text: qsTr("Apply zoom to text only")
                checked: qmlBrowserSettings.zoomTextOnly
            }

            ValueButton {
                id: fontButton

                text: qsTr("Text size")
                valueText: fontSelector.sizes[fontSelector.currentIndex].display
                selector: ListSelector {
                    id: fontSelector

                    property variant sizes: [
                        { "display": qsTr("Normal"), "value": 16 },
                        { "display": qsTr("Large"), "value": 20 },
                        { "display": qsTr("Very large"), "value": 24 }
                    ]

                    function indexOf(value) {
                        for (var i = 0; i < sizes.length; i++) {
                            if (sizes[i].value === value) {
                                return i;
                            }
                        }

                        return 0;
                    }

                    model: sizes
                    currentIndex: indexOf(qmlBrowserSettings.defaultFontSize)
                }
            }

            ValueButton {
                id: encodingButton

                text: qsTr("Encoding")
                valueText: encodingSelector.encodings[encodingSelector.currentIndex].display
                selector: ListSelector {
                    id: encodingSelector

                    property variant encodings: [
                        { "display": qsTr("Central European") + " (ISO 8859-2)", "value": "ISO 8859-2" },
                        { "display": qsTr("Central European") + " (Windows-1250)", "value": "Windows-1250" },
                        { "display": qsTr("Chinese, Simplified") + " (GB18030)", "value": "GB18030" },
                        { "display": qsTr("Chinese, Simplified") + " (ISO-2022-CN)", "value": "ISO-2022-CN" },
                        { "display": qsTr("Chinese, Traditional") + " (Big5 I/II)", "value": "Big5" },
                        { "display": qsTr("Chinese, Traditional") + " (EUC-TW)", "value": "EUC-TW" },
                        { "display": qsTr("Cyrillic") + " (KOI-8R)", "value": "KOI-8R" },
                        { "display": qsTr("Cryillic") + " (Windows-1251)", "value": "Windows-1251" },
                        { "display": qsTr("Greek") + " (ISO 8859-7)", "value": "ISO 8859-7" },
                        { "display": qsTr("Greek") + " (Windows-1253)", "value": "Windows-1253" },
                        { "display": qsTr("Latin") + " (ISO 8859-1)", "value": "ISO 8859-1" },
                        { "display": qsTr("Latin extended") + " (ISO 8859-15)", "value": "ISO 8859-15" },
                        { "display": qsTr("Turkish") + " (ISO 8859-9)", "value": "ISO 8859-9" },
                        { "display": qsTr("Turkish") + " (Windows-1254)", "value": "Windows-1254" },
                        { "display": qsTr("Unicode") + " (UTF-16)", "value": "UTF-16" },
                        { "display": qsTr("Unicode") + " (UTF-8)", "value": "UTF-8" }
                    ]

                    function indexOf(value) {
                        for (var i = 0; i < encodings.length; i++) {
                            if (encodings[i].value === value) {
                                return i;
                            }
                        }

                        return 0;
                    }

                    model: encodings
                    currentIndex: indexOf(qmlBrowserSettings.defaultTextEncoding)
                }
            }

            Label {
                text: qsTr("User-Agent string")
            }

            TextField {
                id: userAgentInput

                text: qmlBrowserSettings.userAgentString
            }
        }
    }

    buttons: Button {
        text: qsTr("Save")
        onClicked: root.accept()
    }

    onVisibleChanged: if (visible) flicker.contentY = 0;
    onAccepted: {
        screen.orientationLock = (rotationCheckbox.checked ? Screen.AutoOrientation : Screen.LandscapeOrientation);

        if (volumeKeysCheckbox.checked != qmlBrowserSettings.zoomWithVolumeKeys) {
            if (window) {
                if (volumeKeysCheckbox.checked) {
                    volumeKeys.grab(window);
                }
                else {
                    volumeKeys.release(window);
                }
            }
        }

        qmlBrowserSettings.rotationEnabled = rotationCheckbox.checked;
        qmlBrowserSettings.zoomWithVolumeKeys = volumeKeysCheckbox.checked;
        qmlBrowserSettings.openBrowserWindowsInFullScreen = fullScreenCheckbox.checked;
        qmlBrowserSettings.forceToolBarVisibleWhenLoading = forceToolbarCheckbox.checked;
        qmlBrowserSettings.useCustomURLHandlers = handlersCheckbox.checked;
        qmlBrowserSettings.privateBrowsingEnabled = privateCheckbox.checked;
        qmlBrowserSettings.autoLoadImages = imagesCheckbox.checked;
        qmlBrowserSettings.javaScriptEnabled = jsCheckbox.checked;
        qmlBrowserSettings.zoomTextOnly = zoomTextCheckbox.checked;
        qmlBrowserSettings.defaultFontSize = fontSelector.sizes[fontSelector.currentIndex].value;
        qmlBrowserSettings.defaultTextEncoding = encodingSelector.encodings[encodingSelector.currentIndex].value;
        qmlBrowserSettings.userAgentString = userAgentInput.text;
    }
    onRejected: {
        rotationCheckbox.checked = qmlBrowserSettings.rotationEnabled;
        volumeKeysCheckbox.checked = qmlBrowserSettings.zoomWithVolumeKeys;
        fullScreenCheckbox.checked = qmlBrowserSettings.openBrowserWindowsInFullScreen;
        forceToolbarCheckbox.checked = qmlBrowserSettings.forceToolBarVisibleWhenLoading;
        handlersCheckbox.checked = qmlBrowserSettings.useCustomURLHandlers;
        privateCheckbox.checked = qmlBrowserSettings.privateBrowsingEnabled;
        imagesCheckbox.checked = qmlBrowserSettings.autoLoadImages;
        jsCheckbox.checked = qmlBrowserSettings.javaScriptEnabled;
        zoomTextCheckbox.checked = qmlBrowserSettings.zoomTextOnly;
        fontSelector.currentIndex = fontSelector.indexOf(qmlBrowserSettings.defaultFontSize);
        encodingSelector.currentIndex = encodingSelector.indexOf(qmlBrowserSettings.defaultTextEncoding);
        userAgentInput.text = qmlBrowserSettings.userAgentString;
    }

    Loader {
        id: loader
    }
    
    Component {
        id: handlerDialog
        
        NewUrlHandlerDialog {}
    }
}
