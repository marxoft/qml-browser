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

Dialog {
    id: root

    height: column.height + platformStyle.paddingMedium
    title: qsTr("Settings")
    
    Flickable {
        id: flicker

        anchors {
            left: parent.left
            right: acceptButton.left
            rightMargin: platformStyle.paddingMedium
            top: parent.top
            bottom: parent.bottom
        }
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        contentHeight: column.height

        Column {
            id: column

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            spacing: platformStyle.paddingMedium

            Label {
                width: parent.width
                text: qsTr("General")
            }

            CheckBox {
                id: rotationCheckbox

                width: parent.width
                text: qsTr("Enable rotation")
                checked: qmlBrowserSettings.rotationEnabled
            }

            CheckBox {
                id: volumeKeysCheckbox

                width: parent.width
                text: qsTr("Use volume keys to zoom")
                checked: qmlBrowserSettings.zoomWithVolumeKeys
            }

            CheckBox {
                id: fullScreenCheckbox

                width: parent.width
                text: qsTr("Open browser windows in fullscreen")
                checked: qmlBrowserSettings.openBrowserWindowsInFullScreen
            }

            CheckBox {
                id: forceToolbarCheckbox
                
                width: parent.width
                text: qsTr("ToolBar always visible when loading")
                checked: qmlBrowserSettings.forceToolBarVisibleWhenLoading
            }

            CheckBox {
                id: handlersCheckbox
                
                width: parent.width
                text: qsTr("Use custom URL handlers")
                checked: qmlBrowserSettings.useCustomURLHandlers
            }

            Button {
                width: parent.width
                text: qsTr("Add custom URL handler")
                onClicked: dialogs.showHandlerDialog()
            }

            Label {
                width: parent.width
                text: qsTr("Content")
            }

            Button {
                width: parent.width
                text: qsTr("Clear browsing history")
                enabled: webHistory.count > 0
                onClicked: {
                    webHistory.clear();
                    webHistory.save();
                }
            }

            CheckBox {
                id: privateCheckbox

                width: parent.width
                text: qsTr("Enable private browsing")
                checked: qmlBrowserSettings.privateBrowsingEnabled
            }

            CheckBox {
                id: imagesCheckbox

                width: parent.width
                text: qsTr("Load images automatically")
                checked: qmlBrowserSettings.autoLoadImages
            }

            CheckBox {
                id: jsCheckbox

                width: parent.width
                text: qsTr("Enable JavaScript")
                checked: qmlBrowserSettings.javaScriptEnabled
            }

            CheckBox {
                id: zoomTextCheckbox

                width: parent.width
                text: qsTr("Apply zoom to text only")
                checked: qmlBrowserSettings.zoomTextOnly
            }

            ValueButton {
                id: fontButton

                width: parent.width
                text: qsTr("Text size")
                pickSelector: fontSelector
            }

            ValueButton {
                id: encodingButton

                width: parent.width
                text: qsTr("Encoding")
                pickSelector: encodingSelector
            }

            Label {
                width: parent.width
                text: qsTr("User-Agent string")
            }

            TextField {
                id: userAgentInput

                width: parent.width
                text: qmlBrowserSettings.userAgentString
            }
        }
    }
    
    Button {
        id: acceptButton
        
        anchors {
            right: parent.right
            bottom: parent.bottom
        }
        text: qsTr("Save")
        onClicked: root.accept()
    }
    
    ListPickSelector {
        id: fontSelector
        
        model: FontSizeModel {
            id: fontSizeModel
        }
        textRole: "name"
        currentIndex: fontSizeModel.match("value", qmlBrowserSettings.defaultFontSize)
    }
    
    ListPickSelector {
        id: encodingSelector
        
        model: EncodingModel {
            id: encodingModel
        }
        textRole: "name"
        currentIndex: encodingModel.match("value", qmlBrowserSettings.defaultTextEncoding)
    }
    
    StateGroup {
        states: State {
            name: "Portrait"
            when: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation
            
            PropertyChanges {
                target: root
                height: column.height + acceptButton.height + platformStyle.paddingMedium
            }
        
            AnchorChanges {
                target: flicker
                anchors {
                    right: parent.right
                    bottom: button.top
                }
            }
        
            PropertyChanges {
                target: flicker
                anchors {
                    rightMargin: 0
                    bottomMargin: platformStyle.paddingMedium
                }
            }
        
            PropertyChanges {
                target: acceptButton
                width: parent.width
            }
        }
    }

    onStatusChanged: if (status == DialogStatus.Open) flicker.contentY = 0;
    onAccepted: {
        screen.orientationLock = (rotationCheckbox.checked ? Qt.WA_Maemo5AutoOrientation
                                                           : Qt.WA_Maemo5LandscapeOrientation);

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
        qmlBrowserSettings.defaultFontSize = fontSizeModel.data(fontSelector.currentIndex, "value");
        qmlBrowserSettings.defaultTextEncoding = encodingModel.data(encodingSelector.currentIndex, "value");
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
        fontSelector.currentIndex = fontSizeModel.match("value", qmlBrowserSettings.defaultFontSize);
        encodingSelector.currentIndex = encodingModel.match("value", qmlBrowserSettings.defaultTextEncoding);
        userAgentInput.text = qmlBrowserSettings.userAgentString;
    }

    QtObject {
        id: dialogs
        
        property NewUrlHandlerDialog handlerDialog
        
        function showHandlerDialog() {
            if (!handlerDialog) {
                handlerDialog = handlerDialogComponent.createObject(root);
            }
            
            handlerDialog.open();
        }
    }
    
    Component {
        id: handlerDialogComponent
        
        NewUrlHandlerDialog {}
    }
}
