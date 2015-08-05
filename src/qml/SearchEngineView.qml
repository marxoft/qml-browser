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

ListView {
    id: view

    property string query

    anchors.fill: parent
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    boundsBehavior: ListView.StopAtBounds
    clip: true
    model: searchEngines
    delegate: ListItem {
        Label {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: image.left
                margins: platformStyle.paddingMedium
            }
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            text: name + (index == searchEngines.count - 1 ? "" : " " + qsTr("Search") + ": '" + view.query + "'")
        }

        Image {
            id: image

            width: 48
            height: 48
            anchors {
                right: parent.right
                rightMargin: platformStyle.paddingMedium
                verticalCenter: parent.verticalCenter
            }
            source: "file://" + icon
            smooth: true
        }
        
        onClicked: {
            if (index == searchEngines.count - 1) {
                dialogs.showSearchEngineDialog();
            }
            else {
                window.loadBrowserWindow(searchEngines.data(index, SearchEngineModel.UrlRole).toString()
                                                           .replace(/%QUERY%/ig, query.replace(/\s+/g, "+")));
                urlInput.clear();
            }
            
            viewLoader.sourceComponent = undefined
        }
    }
    
    onFocusChanged: if ((!focus) && (!urlInput.focus)) viewLoader.sourceComponent = undefined;
}
