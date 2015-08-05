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

ListItem {
    id: root

    Image {
        id: image
        
        width: 100
        height: 60
        anchors {
            left: parent.left
            leftMargin: platformStyle.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        source: thumbnail
        smooth: true
    }
    
    Label {
        id: titleLabel
        
        anchors {
            left: image.right
            leftMargin: platformStyle.paddingMedium
            right: parent.right
            rightMargin: platformStyle.paddingMedium
            top: image.top
        }
        verticalAlignment: Text.AlignTop
        elide: Text.ElideRight
        text: title
    }
    
    Label {
        id: urlLabel
        
        anchors {
            left: titleLabel.left
            right: titleLabel.right
            bottom: image.bottom
        }
        verticalAlignment: Text.AlignBottom
        font.pointSize: platformStyle.fontSizeSmall
        color: platformStyle.secondaryTextColor
        elide: Text.ElideRight
        text: url
    }
}
