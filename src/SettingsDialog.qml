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
import org.hildon.utils 1.0

Dialog {
    id: root

    height: window.inPortrait ? 420 : 320
    windowTitle: qsTr("Settings")
    content: Column {
        anchors.fill: parent

        Label {
            text: qsTr("General")
        }

        CheckBox {
            id: handlersCheckbox

            text: qsTr("Use custom URL handlers")
            checked: qmlBrowserSettings.useCustomURLHandlers
        }

        Button {
            text: qsTr("Add custom URL handler")
            onClicked: {
                loader.source = Qt.resolvedUrl("NewUrlHandlerDialog.qml");
                loader.item.open();
            }
        }

        Label {
            text: qsTr("Content")
        }

        CheckBox {
            id: jsCheckbox

            text: qsTr("Enable JavaScript")
            checked: qmlBrowserSettings.javaScriptEnabled
        }
    }

    buttons: Button {
        text: qsTr("Save")
        onClicked: root.accept()
    }

    onAccepted: {
        qmlBrowserSettings.useCustomURLHandlers = handlersCheckbox.checked;
        qmlBrowserSettings.javaScriptEnabled = jsCheckbox.checked;
    }
    onRejected: {
        handlersCheckbox = qmlBrowserSettings.useCustomURLHandlers;
        jsCheckbox.checked = qmlBrowserSettings.javaScriptEnabled;
    }

    Loader {
        id: loader
    }
}
