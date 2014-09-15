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

Dialog {
    id: root

    height: window.inPortrait ? 680 : 360
    windowTitle: qsTr("Downloads")
    content: TableView {
        id: view

        anchors.fill: parent
        selectionBehavior: TableView.SelectRows
        showRowNumbers: false
        showGrid: false
        model: downloads
        header: HeaderView {
            id: header

            anchors {
                left: parent.left
                right: parent.right
            }
            defaultAlignment: Qt.AlignLeft | Qt.AlignTop
            stretchLastSection: true
            clickable: false
            sections: [
                HeaderSection {
                    text: qsTr("Name")
                    width: window.inPortrait ? 200 : 300
                },

                HeaderSection {
                    text: qsTr("Size")
                    width: 150
                },

                HeaderSection {
                    text: qsTr("Received")
                }
            ]
        }

        Label {
            anchors.top: header.bottom
            color: platformStyle.disabledTextColor
            text: qsTr("(no files downloading)")
            visible: downloads.count == 0
        }
    }

    buttons: [
        Button {
            text: downloads.data(view.currentIndex, DownloadModel.IsRunningRole) === true ? qsTr("Pause") : qsTr("Resume")
            enabled: QModelIndex.isValid(view.currentIndex)
            visible: downloads.count > 0
            onClicked: downloads.get(view.currentIndex).pause()
        },

        Button {
            text: qsTr("Delete")
            enabled: QModelIndex.isValid(view.currentIndex)
            visible: downloads.count > 0
            onClicked: {
                loader.sourceComponent = deleteDialog;
                loader.item.open();
            }
        }
    ]
    
    Loader {
        id: loader
    }

    Component {
        id: deleteDialog
        
        QueryDialog {
            windowTitle: qsTr("Delete?")
            message: qsTr("Delete download") + " '" + downloads.data(view.currentIndex, DownloadModel.NameRole) + "'?"
            acceptButtonText: qsTr("Yes")
            rejectButtonText: qsTr("No")
            onAccepted: downloads.get(view.currentIndex).cancel()
        }
    }
}
