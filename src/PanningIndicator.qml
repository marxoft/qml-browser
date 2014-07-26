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

Item {
    id: root

    property bool panningOn: false

    signal clicked

    width: 64
    height: 64
    anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
    }

    Rectangle {
        x: -10
        width: 74
        height: 64
        color: "black"
        opacity: 0.5
        radius: 10
        smooth: true
    }

    Image {
        id: icon

        width: 64
        height: 64
        anchors.centerIn: parent
        source: "file:///usr/share/icons/hicolor/64x64/hildon/browser_panning_mode_" + (root.panningOn ? "on" : "off") + ".png"
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onClicked: root.clicked()
    }
}
