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

Window {
    id: root

    title: qsTr("Recent history")

    ToolButton {
        id: toolButton

        anchors {
            left: parent.left
            top: parent.top
            margins: platformStyle.paddingMedium
        }
        width: 400
        style: ToolButtonStyle {
            toolButtonStyle: Qt.ToolButtonTextBesideIcon
        }
        iconName: "browser_full_history"
        text: qsTr("Complete browsing history")
        onClicked: windowStack.push(Qt.resolvedUrl("FullHistoryWindow.qml"))
    }

    ListView {
        id: view

        anchors {
            left: parent.left
            right: parent.right
            top: toolButton.bottom
            topMargin: platformStyle.paddingMedium
            bottom: parent.bottom
        }
        orientation: ListView.Horizontal
        highlightMoveDuration: 0
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOff
        model: window.history.items
        delegate: ListItem {
            width: 400
            height: view.height
            style: ListItemStyle {
                background: ""
                backgroundPressed: ""
                backgroundSelected: ""
            }
            
            Column {
                id: column
                
                anchors {
                    left: parent.left
                    leftMargin: platformStyle.paddingMedium
                    right: parent.right
                    rightMargin: platformStyle.paddingMedium
                    top: parent.top
                }
                spacing: platformStyle.paddingMedium
                
                Rectangle {
                    width: parent.width
                    height: 240
                    color: "transparent"
                    border {
                        width: window.history.currentIndex == index ? 5 : 0
                        color: platformStyle.selectionColor
                    }
                    
                    Image {
                        id: image

                        z: -1
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        source: "file:///home/user/.config/QMLBrowser/.cache/" + Qt.md5(modelData.url) + ".jpg"
                        smooth: true                
                    }
                }

                Label {
                    id: titleLabel
                
                    width: parent.width
                    elide: Text.ElideRight
                    text: modelData.title
                }
            
                Label {
                    id: urlLabel
                
                    width: parent.width
                    color: platformStyle.secondaryTextColor
                    font.pointSize: platformStyle.fontSizeSmall
                    elide: Text.ElideRight
                    text: modelData.url
                }
            }
            
            onClicked: {
                if (index !== window.history.currentIndex) {
                    window.history.currentIndex = index;
                }
                
                windowStack.pop(window);
            }
        }
        
        Component.onCompleted: positionViewAtIndex(window.history.currentIndex, ListView.Center)
    }

    Label {
        anchors {
            fill: parent
            margins: platformStyle.paddingMedium
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: platformStyle.disabledTextColor
        text: qsTr("(No recent history)")
        visible: window.history.count === 0
    }
}
