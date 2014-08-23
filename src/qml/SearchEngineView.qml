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
import org.hildon.browser 1.0

ListView {
    id: view

    property string query

    anchors {
        left: parent.left
        leftMargin: 10
        right: parent.right
        rightMargin: 10
        bottom: toolBar.top
    }
    focus: true
    height: Math.min(searchEngines.count * 70, 280)
    autoFillBackground: true
    model: searchEngines
    horizontalScrollMode: ListView.ScrollPerItem
    horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
    delegate: ListItem {
        width: view.width
        height: 70

        ListItemImage {
            anchors.fill: parent
            source: isCurrentItem ? "file:///etc/hildon/theme/images/TouchListBackgroundPressed.png"
                                  : "file:///etc/hildon/theme/images/TouchListBackgroundNormal.png"
        }

        ListItemText {
            anchors {
                top: parent.top
                bottom: parent.bottom
                left: parent.left
                right: image.left
                margins: 10
            }
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            text: modelData.name + (row === searchEngines.count - 1 ? "" : " " + qsTr("Search") + ": '" + view.query + "'")
        }

        ListItemImage {
            id: image

            width: 48
            height: 48
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            source: "file://" + modelData.icon
            smooth: true
        }
    }
    onFocusChanged: if ((!focus) && (!urlInput.focus)) viewLoader.source = "";
    onQueryChanged: {
        // Hotfix to ensure the delegate paint() method is called.
        if (visible) {
            height += 1;
            height -= 1;
        }
    }
    onActivated: {
        switch (QModelIndex.row(currentIndex)) {
        case searchEngines.count - 1:
        {
            loader.source = Qt.resolvedUrl("NewSearchEngineDialog.qml");
            loader.item.open();
            break;
        }
        default:
        {
            window.loadBrowserWindow(searchEngines.data(currentIndex, SearchEngineModel.UrlRole).toString().replace(/%QUERY%/ig, query.replace(/\s+/g, "+")));
            urlInput.clear();
            break;
        }
        }
    }
}
