/*
 * Copyright (C) 2014 Stuart Howarth <showarth@marxoft.co.uk>
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms and conditions of the GNU General Public License,
 * version 3, as published by the Free Software Foundation.
 *
 * This program is distributed in the hope it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 1.0
import org.hildon.webkit 1.0

Item {
    id: root

    width: 80
    height: 80

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.5
        radius: 10
        smooth: true
    }

    Image {
        width: 64
        height: 64
        anchors.centerIn: parent
        source: "image://icon/general_fullsize"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: window.fullScreen ? window.showNormal() : window.showFullScreen()
    }
}
