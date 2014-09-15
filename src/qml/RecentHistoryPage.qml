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
            margins: platformStyle.paddingMedium
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
            model: window.history.items
            delegate: ListItem {
                width: 400
                height: view.height

                ListItemImage {
                    id: image

                    height: 240
                    anchors {
                        left: parent.left
                        leftMargin: platformStyle.paddingMedium
                        right: parent.right
                        rightMargin: platformStyle.paddingMedium
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
                        visible: window.history.currentIndex === row
                    }
                }

                ListItemLabel {
                    id: title
                    
                    height: 32
                    anchors {
                        left: image.left
                        right: image.right
                        top: image.bottom
                        topMargin: platformStyle.paddingMedium
                    }
                    text: modelData.title
                }
                
                ListItemLabel {
                    id: url
                    
                    height: 32
                    anchors {
                        left: image.left
                        right: image.right
                        top: title.bottom
                    }
                    color: platformStyle.secondaryTextColor
                    font.pixelSize: platformStyle.fontSizeSmall
                    text: modelData.url
                }
            }

            onClicked: {
                var i = QModelIndex.row(view.currentIndex);

                if (i !== window.history.currentIndex) {
                    window.history.currentIndex = i;
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
        color: platformStyle.disabledTextColor
        text: qsTr("(No recent history)")
        visible: window.history.count === 0
    }
}
