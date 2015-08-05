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

TextField {
    id: root

    property bool showProgressIndicator: false
    property real progress
    property alias comboboxEnabled: combobox.enabled

    signal comboboxTriggered

    function setUrl(url) {
        if (url) {
            text = url;
            cursorPosition = 0;
        }
    }

    function urlFromTextInput(url) {
        if (url === "") {
            return url;
        }
        if (url[0] === "/") {
            return "file://" + url;
        }
        if (url.indexOf(":") < 0) {
            if ((url.indexOf(".") < 0) || (url.indexOf(" ") >= 0)) {
                if (searchEngines.count > 1) {
                    return searchEngines.data(0, SearchEngineModel.UrlRole).toString()
                                             .replace(/%QUERY%/ig, url.replace(/\s+/g, "+"));
                }

                return "https://duckduckgo.com?q=" + url.replace(/\s+/g, "+");
            }
            else {
                return "http://" + url;
            }
        }

        return url;
    }

    height: parent.height
    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
    style: TextFieldStyle {
        paddingRight: 70
    }

    Image {
        id: combobox

        width: 60
        height: 70
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }

        source: "image://theme/ComboBoxButton" + (mouseArea.pressed ? "Pressed" : enabled ? "Normal" : "Disabled")

        MouseArea {
            id: mouseArea

            z: 1000
            width: 60
            height: 70
            anchors.centerIn: parent
            onClicked: root.comboboxTriggered()
        }
    }

    Image {
        id: progressIndicator

        width: visible ? Math.floor((parent.width - 80) * root.progress / 100) : 0
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: 20
        }
        source: "image://theme/TextInputProgress"
        visible: (root.showProgressIndicator) && (root.progress < 100)
    }
}
