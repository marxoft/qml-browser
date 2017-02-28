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

ListItem { 
    id: root
    
    Label {
        id: nameLabel
        
        anchors {
            left: parent.left
            right: progressBar.left
            top: parent.top
            margins: platformStyle.paddingMedium
        }
        elide: Text.ElideRight
        text: name
    }
    
    Label {
        id: sizeLabel
        anchors {
            left: parent.left
            right: progressBar.left
            bottom: parent.bottom
            margins: platformStyle.paddingMedium
        }
        elide: Text.ElideRight
        color: error == Download.NoError ? platformStyle.secondaryTextColor : platformStyle.attentionColor
        font.pointSize: platformStyle.fontSizeSmall
        text: error == Download.NoError ? (running ? qsTr("Downloading") : qsTr("Waiting")) + ": "
        + qmlBrowserUtils.formatBytes(bytesReceived) + " / "
        + qmlBrowserUtils.formatBytes(size)
        : qsTr("Failed")
    }
    
    ProgressBar {
        id: progressBar
        
        anchors {
            right: parent.right
            rightMargin: platformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        width: 150
        textVisible: true
        text: progress + "%"
    }    
}
