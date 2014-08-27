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

Page {
    id: root

    windowTitle: qsTr("Complete browsing history")

    ListView {
        id: view

        anchors.fill: parent
        horizontalScrollMode: ListView.ScrollPerItem
        horizontalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: webHistory.urls
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
                    right: parent.right
                    margins: 10
                }
                alignment: Qt.AlignLeft | Qt.AlignVCenter
                text: modelData.display
            }
        }
        onActivated: {
            window.url = webHistory.urls[QModelIndex.row(view.currentIndex)];
            pageStack.pop(window);
        }
    }

    Label {
        anchors {
            fill: parent
            margins: 10
        }
        alignment: Qt.AlignCenter
        font {
            bold: true
            pixelSize: 40
        }
        color: platformStyle.disabledTextColor
        text: qsTr("No history")
        visible: webHistory.urls.length === 0
    }
}
