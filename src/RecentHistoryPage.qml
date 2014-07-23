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

    windowTitle: qsTr("Recent history")

    Column {
        id: column

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 10
        }

        ToolButton {
            id: toolButton

            toolButtonStyle: Qt.ToolButtonTextBesideIcon
            icon: "browser_full_history"
            text: qsTr("Complete browsing history")
            onClicked: pageStack.push(Qt.resolvedUrl("FullHistoryPage.qml"), {})
        }

        ListView {
            id: view

            width: column.width
            height: column.height - toolButton.height - column.spacing
            flow: ListView.LeftToRight
            verticalScrollMode: ListView.ScrollPerItem
            verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
            model: window.viewHistory.items
            delegate: ListItem {
                width: 480
                height: view.height

                ListItemImage {
                    id: image

                    height: 250
                    anchors {
                        left: parent.left
                        leftMargin: 10
                        right: parent.right
                        rightMargin: 10
                        top: parent.top
                    }
                    fillMode: ListItemImage.PreserveAspectCrop
                    source: "file:///home/user/.config/QMLBrowser/.cache/" + Qt.md5(modelData.url) + ".jpg"
                    smooth: true

                    ListItemRectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border {
                            width: 5
                            color: platformStyle.selectionColor
                        }
                        visible: window.viewHistory.currentIndex === row
                    }
                }

                ListItemText {
                    anchors {
                        left: image.left
                        right: image.right
                        top: image.bottom
                        bottom: parent.bottom
                    }
                    text: modelData.title + "\n" + modelData.url
                }
            }

            onClicked: {
                var i = QModelIndex.row(view.currentIndex);

                if (i !== window.viewHistory.currentIndex) {
                    window.viewHistory.currentIndex = i;
                }

                pageStack.pop(window);
            }
        }
    }

    Label {
        anchors {
            fill: parent
            margins: 100
        }
        alignment: Qt.AlignCenter
        font {
            bold: true
            pixelSize: 40
        }
        color: platformStyle.secondaryTextColor
        text: qsTr("No recent history")
        visible: window.viewHistory.count === 0
    }
}
