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
                                             .replace(/%q/ig, url.replace(/\s+/g, "+"));
                }

                return "https://duckduckgo.com?q=" + url.replace(/\s+/g, "+");
            }
            else {
                return "http://" + url;
            }
        }

        return url;
    }

    height: 75
    inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
    
    Loader {
        id: progressLoader
        
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: 20
        }
        sourceComponent: (root.showProgressIndicator) && (root.progress < 100) ? progressIndicator : undefined
    }

    Component {
        id: progressIndicator
        
        Image {            
            width: Math.floor((root.width - 80) * root.progress / 100)
            source: "image://theme/TextInputProgress"
        }
    }
}
