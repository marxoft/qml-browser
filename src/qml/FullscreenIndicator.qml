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

Item {
    id: root

    visible: (!toolBar.visible) && (!findToolBar.visible) && ((webView.moving) || (webView.atYBeginning) || (webView.status != WebView.Ready) || (!timer.timedOut))
    width: 80
    height: 80
    anchors {
        right: parent.right
        bottom: parent.bottom
        margins: -10
    }

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
        source: "file:///usr/share/icons/hicolor/64x64/hildon/general_fullsize.png"
    }

    MouseArea {
        anchors.fill: parent
        preventStealing: true
        onClicked: window.fullScreen = !window.fullScreen
    }

    Timer {
        id: timer

        property bool timedOut: false

        interval: 2000
        running: (!toolBar.visible) && (!findToolBar.visible) && (!webView.moving) && (!webView.atYBeginning) && (webView.status == WebView.Ready)
        onRunningChanged: if (running) timedOut = false;
        onTriggered: timedOut = true
    }
}
