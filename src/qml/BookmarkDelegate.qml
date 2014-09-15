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

ListItem {
    id: root
    
    height: 70
    width: view.width
    
    ListItemImage {
        id: highlight
        
        anchors.fill: parent
        source: "image://theme/TouchListBackground" + (isCurrentItem ? "Pressed" : "Normal")
    }
    
    ListItemImage {
        id: thumbnail
        
        width: 100
        height: 60
        anchors {
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        source: modelData.thumbnail
        smooth: true
    }
    
    ListItemLabel {
        id: title
        
        height: 32
        anchors {
            left: thumbnail.right
            leftMargin: platformStyle.paddingMedium
            right: parent.right
            rightMargin: platformStyle.paddingMedium
            top: thumbnail.top
        }
        alignment: Qt.AlignTop
        text: modelData.title
    }
    
    ListItemLabel {
        id: url
        
        height: 32
        anchors {
            left: title.left
            right: title.right
            bottom: thumbnail.bottom
        }
        alignment: Qt.AlignBottom
        font.pixelSize: platformStyle.fontSizeSmall
        color: platformStyle.secondaryTextColor
        text: modelData.url
    }
}
