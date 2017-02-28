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

Dialog {
    id: root

    height: screen.currentOrientation == Qt.WA_Maemo5PortraitOrientation ? 680 : 360
    title: qsTr("Downloads")
    
    ListView {
        id: view

        anchors.fill: parent
        model: downloads
        delegate: DownloadDelegate {
            onPressAndHold: popupManager.open(contextMenu, root)
        }
    }
    
    Label {
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: platformStyle.disabledTextColor
        text: qsTr("(no files downloading)")
        visible: downloads.count == 0
    }
    
    Component {
        id: contextMenu
        
        Menu {            
            MenuItem {
                text: downloads.data(view.currentIndex, DownloadModel.IsRunningRole) === true ? qsTr("Pause")
                : qsTr("Resume")
                onTriggered: downloads.get(view.currentIndex).pause()
            }
            
            MenuItem {
                text: qsTr("Delete")
                onTriggered: downloads.get(view.currentIndex).cancel()
            }
        }
    }
}
